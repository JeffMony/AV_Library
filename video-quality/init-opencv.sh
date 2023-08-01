# download opencv source

OPENCV_UPSTREAM=git@github.com:opencv/opencv.git

OPENCV_CONTRIB_UPSTREAM=git@github.com:opencv/opencv_contrib.git

TAG_NAME=4.8.0

pull_stream() {
    git clone $1

    cd opencv

    git checkout -b ${TAG_NAME} ${TAG_NAME}

    cd -
}

pull_stream ${OPENCV_UPSTREAM}

pull_stream ${OPENCV_CONTRIB_UPSTREAM}