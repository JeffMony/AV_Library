REFERENCE_VIDEO=$1
SOURCE_VIDEO=$2
MODLE_PATH=$(pwd)/model/vmaf_v0.6.1.json

ffmpeg \
-r 60 -i ${REFERENCE_VIDEO} \
-r 30 -i ${SOURCE_VIDEO} \
-lavfi "[0:v]setpts=PTS-STARTPTS[reference]; \
        [1:v]scale=1080:1440:flags=bicubic,setpts=PTS-STARTPTS[distorted]; \
        [distorted][reference]libvmaf=log_fmt=json:log_path=log.txt:model='path=${MODLE_PATH}':n_threads=4" \
-f null -
