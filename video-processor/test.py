#!/usr/bin/python
# -*- coding: UTF-8 -*-


import media_extractor
import sys

count = len(sys.argv)
if count == 2 :
    video_url = sys.argv[1]
    result = media_extractor.extract_video_color(video_url)
    print(result)
