#!/usr/bin/python
# -*- coding: UTF-8 -*-

from FasterVQA.vqa import get_vqa_score

def get_vqa_result(video_url) :
    return get_vqa_score('FasterVQA', video_url)
