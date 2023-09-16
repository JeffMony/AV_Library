
#include "video_color_extractor.h"

extern "C" {
#include <stdio.h>
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Please input two argument, the second argument is video url\n");
        return -1;
    }
    char *url = argv[1];
    VideoColorExtractor *extractor = new VideoColorExtractor(url);
    int ret = extractor->Start();
    if (ret != 0) {
        printf("Video extractor failed, ret=%d\n", ret);
        delete extractor;
        return ret;
    }
    delete extractor;
    return 0;
}