#include <string>
#include "opencv2/opencv.hpp"

extern "C" {
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
}

typedef struct Color {
    int red;
    int green;
    int blue;
    float percent;
} Color;

class VideoColorExtractor {
public:
    explicit VideoColorExtractor(char *video_url);

    virtual ~VideoColorExtractor();

    int Start();

    void PrintDarkColor();

private:

    cv::Mat ConvertAVFrameToMat(AVFrame *frame);

    void ComputeFrameColor(AVFrame *frame);

private:
    std::string video_url_;
    AVFormatContext *format_context_;
    AVCodecContext *codec_context_;
    SwsContext *sws_context_;
    Color *dark_color_;    

};
