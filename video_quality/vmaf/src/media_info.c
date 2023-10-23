
#include <stdio.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/log.h>
#include <libavutil/display.h>

int is_damaged = 0;
int ret = 0;
char message[1024];

int return_error(char *msg, int ret) {
  printf("%d\n%s\n", ret, msg);
  return ret;
}

void custom_log_callback(void *ptr, int level, const char *fmt, va_list vl) {
  if (level != AV_LOG_ERROR) {
    return;
  }
  if (!is_damaged) {
    sprintf(message, fmt, vl);
    is_damaged = 1;
  }
}

int common_extract_video(AVFormatContext *format_context, const char *path) {
  AVCodecContext *codec_context = NULL;
  ret = avformat_find_stream_info(format_context, NULL);
  if (ret < 0) {
    sprintf(message, "Error finding stream info: %s", av_err2str(ret));
    ret = -3;
    goto CLOSE;
  }
  int video_stream_index = av_find_best_stream(format_context, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
  if (video_stream_index == AVERROR_STREAM_NOT_FOUND) {
    sprintf(message, "Error finding the video stream");
    ret = -4;
    goto CLOSE;
  }
  AVCodecParameters *codec_params = format_context->streams[video_stream_index]->codecpar;
  int width = codec_params->width;
  int height = codec_params->height;
  AVStream *video_stream = format_context->streams[video_stream_index];
  AVDictionaryEntry *m = NULL;
  int has_rotation = 0;
  double rotation = 0.0;
  m = av_dict_get(video_stream->metadata, "rotate", m, AV_DICT_MATCH_CASE);
  if (m) {
    rotation = atof(m->value);
    has_rotation = 1;
  }
  if (!has_rotation && video_stream->nb_side_data) {
    for (int i = 0; i < video_stream->nb_side_data; i++) {
      const AVPacketSideData *sd = &video_stream->side_data[i];
      if (sd->type == AV_PKT_DATA_DISPLAYMATRIX && sd->size >= 9*4) {
        double r = av_display_rotation_get((int32_t *)sd->data);
        if (!isnan(r)) {
          rotation = r;
        }
        break;
      }
    }
  }
  int rotate = (int)(rotation);
  rotate = (rotate + 360) % 360;
  int temp_width = width;
  if (rotate == 90 || rotate == 270) {
    width = height;
    height = temp_width;
  }
  int fps = av_q2d(video_stream->avg_frame_rate);
  printf("%d\n%d\n%d\n", width, height, fps);
  goto CLOSE;

CLOSE:
  if (codec_context) {
    avcodec_close(codec_context);
    codec_context = NULL;
  }
  if (format_context) {
    avformat_close_input(&format_context);
    format_context = NULL;
  }
  if (ret != 0) {
    return return_error(message, ret);
  }
  return ret;
}

int extract_video_file(const char *path) {
  is_damaged = 0;
  ret = 0;
  av_log_set_callback(custom_log_callback);
  AVFormatContext *format_context = avformat_alloc_context();
  ret = avformat_open_input(&format_context, path, NULL, NULL);
  if (ret < 0) {
    sprintf(message, "Error opening input file: %s, ret=%s", path, av_err2str(ret));
    ret = -2;
    goto CLOSE;
  }
  return common_extract_video(format_context, path);
CLOSE:
  if (format_context) {
    avformat_close_input(&format_context);
    format_context = NULL;
  }
  if (ret != 0) {
    return return_error(message, ret);
  }
  return ret;
}

int main(int argc, char **argv) {
  if (argc < 2) {
    return -1;
  }
  return extract_video_file(argv[1]);
}