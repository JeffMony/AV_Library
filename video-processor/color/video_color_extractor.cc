#include "video_color_extractor.h"
#include "common.h"
#include <vector>
#include "opencv2/imgproc/imgproc.hpp"

extern "C" {
#include "libavutil/log.h"
#include "libavutil/display.h"
}

static bool is_damaged = false;
static char message[1024];

static void custom_log_callback(void *ptr, int level, const char *fmt, va_list vl);

static void custom_log_callback(void *ptr, int level, const char *fmt, va_list vl) {
  if (level != AV_LOG_ERROR) {
    return;
  }
  if (!is_damaged) {
    snprintf(message, 1024, fmt, vl);
    is_damaged = true;
  }
}

VideoColorExtractor::VideoColorExtractor(char *video_url) 
    : format_context_(NULL)
    , codec_context_(NULL)
    , sws_context_(NULL)
    , dark_color_(NULL) {
    video_url_.clear();
    video_url_.append(video_url);
    is_damaged = false;
    av_log_set_callback(custom_log_callback);
    dark_color_ = new Color();
    dark_color_->red = -1;
    dark_color_->green = -1;
    dark_color_->blue = -1;
    dark_color_->percent = 0.f;
}

VideoColorExtractor::~VideoColorExtractor() {
    if (dark_color_ != NULL) {
        delete dark_color_;
        dark_color_ = NULL;
    }
    if (sws_context_ != NULL) {
        sws_freeContext(sws_context_);
        sws_context_ = NULL;
    }
    if (codec_context_ != NULL) {
        avcodec_close(codec_context_);
        avcodec_free_context(&codec_context_);
        codec_context_ = NULL;
    }
    if (format_context_ != NULL) {
        avformat_close_input(&format_context_);
        avformat_free_context(format_context_);
        format_context_ = NULL;
    }
}

int VideoColorExtractor::Start() {
    format_context_ = avformat_alloc_context();
    int ret = avformat_open_input(&format_context_, video_url_.c_str(), NULL, NULL);
    if (ret < 0) {
        ret = -2;
        return ret;
    }
    ret = avformat_find_stream_info(format_context_, NULL);
    if (ret < 0) {
        ret = -3;
        return ret;
    }
    int video_stream_index = av_find_best_stream(format_context_, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if (video_stream_index == AVERROR_STREAM_NOT_FOUND) {
        ret = -4;
        return ret;
    }
    // Find the decoder for the video stream
    AVCodecParameters *codec_params = format_context_->streams[video_stream_index]->codecpar;
    const AVCodec *codec = avcodec_find_decoder(codec_params->codec_id);
    if (!codec) {
        ret = -5;
        return ret;
    }
    codec_context_ = avcodec_alloc_context3(codec);
    ret = avcodec_parameters_to_context(codec_context_, codec_params);
    if (ret < 0) {
        ret = -6;
        return ret;
    }
    ret = avcodec_open2(codec_context_, codec, NULL);
    if (ret < 0) {
        ret = -7;
        return ret;
    }
    std::vector<int64_t> key_frame_times;
    AVStream *video_stream = format_context_->streams[video_stream_index];
    int video_index_entries_count = avformat_index_get_entries_count(video_stream);
    for (int index = 0; index < video_index_entries_count; index++) {
        const AVIndexEntry *entry = avformat_index_get_entry(video_stream, index);
        if (entry->flags & AVINDEX_KEYFRAME) {
            int64_t pos = av_rescale_q(entry->timestamp, video_stream->time_base, AV_TIME_BASE_Q) / 1000;
            if (pos < 0) {
                pos = 0;
            }
             if (pos <= CHECK_DURATION) {
                key_frame_times.push_back(pos);
            }
        }
    }
    if (key_frame_times.size() < 1) {
        ret = -8;
        return ret;
    }
    AVPacket *packet = av_packet_alloc();
    if (packet == NULL) {
        ret = -9;
        return ret;
    }
    bool seek_req = false;
    int key_frame_index = 1;
    AVFrame *frame = av_frame_alloc();
    while (true) {
        if (seek_req) {
            avcodec_flush_buffers(codec_context_);
            if (key_frame_index >= key_frame_times.size()) {
                break;
            }
            int64_t seek_pos = key_frame_times[key_frame_index++] * 1000;
            ret = avformat_seek_file(format_context_, -1, INT64_MIN, seek_pos, INT64_MAX, AVSEEK_FLAG_BACKWARD);
            if (ret < 0) {
                ret = -10;
                break;
            }
            seek_req = false;
        }
        ret = av_read_frame(format_context_, packet);
        if (ret == 0) {
            if (packet->stream_index == video_stream_index) {
                ret = avcodec_send_packet(codec_context_, packet);
                if (ret == 0) {
                    while (true) {
                        ret = avcodec_receive_frame(codec_context_, frame);
                        if (ret == 0) {
                            seek_req = true;
                            ComputeFrameColor(frame);
                            break;
                        } else if (ret == AVERROR(EAGAIN)) {
                            ret = 0;
                            break;
                        } else {
                            ret = -12;
                            break;
                        }
                    }
                } else {
                    ret = -11;
                }
                av_packet_unref(packet);
                if (ret != 0) {
                    break;
                }
            } else {
                av_packet_unref(packet);
            }
        } else if (ret == AVERROR_EOF) {
            av_packet_unref(packet);
        } else {
            av_packet_unref(packet);
        }
    }
    av_packet_free(&packet);
    av_frame_free(&frame);
    return 0;
}

void VideoColorExtractor::PrintDarkColor() {
    if (dark_color_ != NULL) {
        printf("%d\n%d\n%d\n", dark_color_->red, dark_color_->green, dark_color_->blue);
    } else {
        printf("-1\n-1\n-1\n");
    }
}

cv::Mat VideoColorExtractor::ConvertAVFrameToMat(AVFrame *frame) {
    int width = frame->width;
    int height = frame->height;
    cv::Mat result_mat(height, width, CV_8UC3);
    int cv_linesize[1];
    cv_linesize[0] = result_mat.step1();
    if (sws_context_ == NULL) {
        sws_context_ = sws_getContext(
            width,
            height,
            AVPixelFormat::AV_PIX_FMT_YUV420P,
            width,
            height,
            AVPixelFormat::AV_PIX_FMT_BGR24,
            SWS_FAST_BILINEAR,
            NULL,
            NULL,
            NULL
        );
    }
    sws_scale(
        sws_context_,
        frame->data,
        frame->linesize,
        0,
        height,
        &result_mat.data,
        cv_linesize
    );
    return result_mat;
}

void VideoColorExtractor::ComputeFrameColor(AVFrame *frame) {
    cv::Mat result_mat = ConvertAVFrameToMat(frame);
    cv::Mat hist;
    int num_bins = 256;
    const int hist_size[] = { num_bins, num_bins, num_bins};
    float range[] = { 0, 256};
    const float* ranges[] = { range, range, range};
    int channels[] = { 0, 1, 2};
    calcHist(&result_mat, 1, channels, cv::Mat(), hist, 3, hist_size, ranges);

    float max_hist = 0;
    int max_b = 0;
    int max_g = 0;
    int max_r = 0;
    bool updated = false;
    for (int b = 0; b < 256; b++) {
        for (int g = 0; g < 256; g++) {
            for (int r = 0; r < 256; r++) {
                float bin_hist = hist.at<float>(b, g, r);
                if (b < DARK_COLOR && g < DARK_COLOR && r < DARK_COLOR) {
                    if (bin_hist > max_hist) {
                        max_b = b;
                        max_g = g;
                        max_r = r;
                        max_hist = bin_hist;
                        updated = true;
                    }
                }
            }
        }
    }
    float percent = max_hist / result_mat.cols / result_mat.rows / result_mat.channels();
#if PRINT_LOG
    printf("red=%d, green=%d, blue=%d, percent=%f\n", max_r, max_g, max_b, percent);
#endif
    if (updated) {
        if (percent > dark_color_->percent) {
            dark_color_->red = max_r;
            dark_color_->green = max_g;
            dark_color_->blue = max_b;
            dark_color_->percent = percent;
        }
    }
}
