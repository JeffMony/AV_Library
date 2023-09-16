
g++ -o video_color_extractor \
main.cc video_color_extractor.cc \
`pkg-config --cflags --libs opencv4` \
`pkg-config --cflags --libs libavcodec libavformat libavutil`