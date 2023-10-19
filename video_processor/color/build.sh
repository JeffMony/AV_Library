
g++ -std=c++11 \
-o video_color_extractor \
main.cc video_color_extractor.cc \
`pkg-config --cflags --libs opencv4` \
`pkg-config --cflags --libs libavcodec libavformat libswscale libavutil`