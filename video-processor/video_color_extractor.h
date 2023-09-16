

#include <string>

extern "C" {
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
}

class VideoColorExtractor {
public:
    explicit VideoColorExtractor(char *video_url);

    virtual ~VideoColorExtractor();

    int Start();

private:
    std::string video_url_;
    AVFormatContext *format_context_;
    AVCodecContext *codec_context_;

};