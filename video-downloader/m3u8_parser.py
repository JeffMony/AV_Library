#!/usr/bin/python

import requests
import sys

def is_m3u8(content_type) :
    if content_type == None or content_type == '' :
        return False
    if content_type == 'application/x-mpegURL' or content_type == 'application/vnd.apple.mpegurl' or content_type == 'vnd.apple.mpegurl' or content_type == 'applicationnd.apple.mpegurl' :
        return True
    return False

def parse_video(video_url) :
    headers = {
        "User-Agent":"FFmpeg"
    }
    r = requests.get(video_url, headers = headers, timeout = 10)
    print(r.status_code)
    if r.status_code == 200 or r.status_code == 206 :
        content_type = r.headers['Content-Type']
        if is_m3u8(content_type) :
            print(r.text)

if __name__ == '__main__':
    length = len(sys.argv)
    if length < 2 :
        print('请输入url')
    else :
        url = sys.argv[1]
        parse_video(url)

