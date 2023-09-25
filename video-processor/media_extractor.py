#!/usr/bin/python
# -*- coding: UTF-8 -*-

import os
import subprocess
from subprocess import PIPE

def extract_video_color(video_url) :
    path = os.path.dirname(__file__)
    command = f'{path}/color/video_color_extractor {video_url}'
    pipe = subprocess.run(command, shell=True, encoding='utf-8', stdout=PIPE)
    ret = pipe.returncode
    if ret == 0:
        lines = pipe.stdout.splitlines()
        red = int(lines[0])
        green = int(lines[1])
        blue = int(lines[2])
        resultColor = {}
        resultColor['red'] = red
        resultColor['green'] = green
        resultColor['blue'] = blue
        return resultColor
    return None
