#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys
import vqa_compute

count = len(sys.argv)

if count >= 2 :
    video_url = sys.argv[1]
    result = vqa_compute.get_vqa_result(video_url)
    print(result)