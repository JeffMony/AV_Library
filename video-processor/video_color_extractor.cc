
#include "video_color_extractor.h"
#include "common.h"
#include <vector>

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
    , codec_context_(NULL) {
    video_url_.clear();
    video_url_.append(video_url);
    is_damaged = false;
    av_log_set_callback(custom_log_callback);
}

VideoColorExtractor::~VideoColorExtractor() {
    if (codec_context_) {
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
    printf("key_frame_times=%lu\n", key_frame_times.size());
    for (int index = 0; index < key_frame_times.size(); index++) {
        printf("index=%d, key_frame_times value=%lld\n", index, key_frame_times.at(index));
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
    int key_frame_index = 0;
    while (true) {
        if (key_frame_index >= key_frame_times.size()) {
            break;
        }
        int64_t seek_pos = key_frame_times[key_frame_index++] * 1000;
        ret = avformat_seek_file(format_context_, -1, INT64_MIN, seek_pos, INT64_MAX, AVSEEK_FLAG_BACKWARD);
        if (ret < 0) {
            ret = -10;
            break;
        }
        ret = av_read_frame(format_context_, packet);
        if (ret == 0) {
            printf("####\n");
        } else if (ret == AVERROR_EOF) {
            av_packet_unref(packet);
        } else {
            av_packet_unref(packet);
        }
    }
    av_packet_free(&packet);
    return 0;
}