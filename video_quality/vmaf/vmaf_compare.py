
#!/usr/bin/python
# -*- coding: UTF-8 -*-

import os
import platform
import subprocess
from subprocess import PIPE
import json
import time

class VideoInfo() :
    def __init__(self, url, width, height, fps) :
        self.url = url
        self.width = width
        self.height = height
        self.fps = fps

    def getUrl(self) :
        return self.url

    def getWidth(self) :
        return self.width

    def getHeight(self) :
        return self.height

    def getFps(self) :
        return self.fps

    def print(self) :
        print(self.__dict__)



def getVideoInfo(video_url) :
    path = os.path.dirname(__file__)
    os_system = platform.system()
    os_system = os_system.lower()
    cpu = platform.machine()
    cpu = cpu.lower()
    if os_system == 'darwin' :
        if cpu == 'arm64' :
            path = path + '/cmd/mac-mx'
        else :
            path = path + 'cmd/mac-intel'
    elif os_system == 'linux' :
        path = path + '/cmd/linux'
    else :
        print('无法支持当前系统')
        return None
    command = f'{path}/media_info {video_url}'
    pipe = subprocess.run(command, shell=True, encoding='utf-8', stdout=PIPE)
    ret = pipe.returncode
    lines = pipe.stdout.splitlines()
    if ret == 0 :
        if len(lines) < 3 :
            return None
        width = int(lines[0])
        height = int(lines[1])
        fps = int(lines[2])
        video_info = VideoInfo(video_url, width, height, fps)
        return video_info
    else :
        print(f'{lines[0]} {lines[1]}')
        return None

def generateVmafResult(reference_video_info, source_video_info) :
    path = os.path.dirname(__file__)
    time_mills = int(round(time.time() * 1000))
    log_path = path + '/' + str(time_mills) + '.txt'
    model_path = path + '/model/vmaf_v0.6.1.json'
    command = f'ffmpeg -r {reference_video_info.getFps()} -i {reference_video_info.getUrl()} -r {source_video_info.getFps()} -i {source_video_info.getUrl()} -lavfi \"[0:v]setpts=PTS-STARTPTS[reference];[1:v]scale={reference_video_info.getWidth()}:{reference_video_info.getHeight()}:flags=bicubic,setpts=PTS-STARTPTS[distorted];[distorted][reference]libvmaf=log_fmt=json:log_path={log_path}:model=\'path={model_path}\':n_threads=4\" -f null -'
    print(command)
    subprocess.run(command, shell=True, encoding='utf-8', stdout=PIPE)
    if os.path.exists(log_path) and os.access(log_path, os.R_OK) :
        return log_path
    return None

def getVmafValue(reference_url, video_url) :
    reference_video_info = getVideoInfo(reference_url)
    source_video_info = getVideoInfo(video_url)
    # reference_video_info.print()
    # source_video_info.print()
    if reference_video_info == None or source_video_info == None :
        return None
    vmaf_result_log_path = generateVmafResult(reference_video_info, source_video_info)
    try :
        with open(vmaf_result_log_path, 'r') as vmaf_result_file :
            vmaf_result = json.load(vmaf_result_file)
            if 'pooled_metrics' in vmaf_result :
                if 'vmaf' in vmaf_result['pooled_metrics'] :
                    if 'mean' in vmaf_result['pooled_metrics']['vmaf'] :
                        os.remove(vmaf_result_log_path)
                        return vmaf_result['pooled_metrics']['vmaf']['mean']
    except :
        print('打开文件失败')
    os.remove(vmaf_result_log_path)
    return None