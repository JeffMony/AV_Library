#!/bin/bash

# compile ffmpeg config about audio

# filter 相关
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-all"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-swscale"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-network"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-postproc"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-avdevice"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --target-os=android"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-runtime-cpudetect"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-programs"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-ffmpeg"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-ffplay"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-ffprobe"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-debug"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-avfilter"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-small"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-pic"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-avcodec"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-avformat"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-avutil"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-swresample"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --disable-everything"

# 解码格式
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-decoder=mp3"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-decoder=aac"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-decoder=aac_latm"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-decoder=h264"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-decoder=pcm_s16le"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-decoder=pcm_s16le_planar"

# 解封装
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-demuxer=mp3"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-demuxer=mov"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-demuxer=aac"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-demuxer=h264"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-demuxer=rawvideo"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-demuxer=flv"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-demuxer=mpegvideo"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-demuxer=wav"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-demuxer=mpegvideo"

# 封装
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-muxer=mp4"

# 格式
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-parser=aac"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-parser=h264"

# bsf
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-bsf=aac_adtstoasc"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-bsf=h264_mp4toannexb"
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-bsf=mp3_header_decompress"

# 协议
export COMMON_FFMPEG_CONFIG="${COMMON_FFMPEG_CONFIG} --enable-protocol=file"
