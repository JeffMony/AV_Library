#include "video_color_extractor.h"

extern "C" {
#include <stdio.h>
}

int main(int argc, char **argv) {
    if (argc < 2) {
        return -1;
    }
    char *url = argv[1];
    VideoColorExtractor *extractor = new VideoColorExtractor(url);
    int ret = extractor->Start();
    if (ret != 0) {
        delete extractor;
        return ret;
    }
    extractor->PrintDarkColor();
    delete extractor;
    return 0;
}
