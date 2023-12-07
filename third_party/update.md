  - [音视频相关库的编译文档](#音视频相关库的编译文档)
    - [1.编译前准备](#1编译前准备)
    - [2.编译openssl](#2编译openssl)
    - [3.编译fdk-aac](#3编译fdk-aac)
    - [4.编译libx264](#4编译libx264)
    - [5.编译ffmpeg](#5编译ffmpeg)
      - [5.1 openssl找不到](#51-openssl找不到)
      - [5.2 AACENC_InfoStruct缺失encoderDelay](#52-aacenc_infostruct缺失encoderdelay)
      - [5.3 libfdk_aac找不到](#53-libfdk_aac找不到)


## 音视频相关库的编译文档
我们在做音视频相关产品的时候，离不开一些重要的库，下面列举一下：
> * ffmpeg : 多媒体框架库，是音视频开发非常重要的一个库
> * fdk-aac : 音频库，可以定制aac-he
> * openssl : ssl库，和ffmpeg结合
> * libx264 : videolan提供的h264相关的库，比ffmpeg原生自带的库要好用
> * libx265 : videolan提供的hevc相关的库，压缩效率更加
> * soundtouch : 变声库，比sonic功能呢强大
> * libpng : 图片库
> * libyuv : yuv库，可以做裁剪，形变等工作

上面简单介绍了一下各个库，这些库如何编译了，下面一一介绍:


### 1.编译前准备
配置环境变量ANROID_NDK，这儿我选择的NDK版本是android-ndk-r14b<br>
选择NDK版本要慎重一点，因为有些NDK会成功，有些会失败<br>
首先要在环境变量中配置ANDROID_NDK

### 2.编译openssl
执行init_openssl.sh<br>
openssl源码下载到./sources/openssl目录下<br>
进入./sources目录，执行./compile_openssl.sh all

### 3.编译fdk-aac
执行init_fdkaac.sh<br>
fdk-aac源码下载到./sources/fdk-aac目录下<br>
进入./sources目录，执行./compile_fdkaac.sh all<br>
编译出现如下错误：<br>
```
libSBRdec/src/lpp_tran.cpp:122:21: fatal error: log/log.h: No such file or directory
 #include "log/log.h"
                     ^
compilation terminated.
make: *** [libSBRdec/src/lpp_tran.lo] Error 1
```
因为使用特定平台的API，所以要找到这个代码，注释掉，继续编译，发现还是出错:<br>
```
libSBRdec/src/lpp_tran.cpp: In function 'void lppTransposer(HANDLE_SBR_LPP_TRANS, QMF_SCALE_FACTOR*, FIXP_DBL**, FIXP_DBL*, FIXP_DBL**, int, int, int, int, int, int, int, INVF_MODE*, INVF_MODE*)':
libSBRdec/src/lpp_tran.cpp:342:50: error: 'android_errorWriteLog' was not declared in this scope
     android_errorWriteLog(0x534e4554, "112160868");
                                                  ^
libSBRdec/src/lpp_tran.cpp: In function 'void lppTransposerHBE(HANDLE_SBR_LPP_TRANS, HANDLE_HBE_TRANSPOSER, QMF_SCALE_FACTOR*, FIXP_DBL**, FIXP_DBL**, int, int, int, int, INVF_MODE*, INVF_MODE*)':
libSBRdec/src/lpp_tran.cpp:940:50: error: 'android_errorWriteLog' was not declared in this scope
     android_errorWriteLog(0x534e4554, "112160868");
                                                  ^
make: *** [libSBRdec/src/lpp_tran.lo] Error 1
```
没办法，继续注释掉错误的代码.<br>
可以编译成功了。


### 4.编译libx264
执行init_libx264.sh<br>
libx264源码下载到./sources/libx264目录下<br>
进入./sources目录，执行./compile_libx264.sh all

### 5.编译ffmpeg
执行init_ffmpeg.sh<br>
ffmpeg源码下载到./sources/ffmpeg目录下<br>
进入./sources目录，执行./compile_ffmpeg.sh all<br>
openssl、libfdk-aac、libx264是要集成到ffmpeg中的，所以在编译的时候需要链接进来。<br><br>
还是会发生一些编译错误的，下面一一例举我遇到的编译问题:

#### 5.1 openssl找不到
开始编译出现：
```
ERROR: openssl not found

```
解决方案是修改ffmpeg/configure中的check逻辑。<br>
找到configure文件中的6145行，将如下代码修改一下:
```
enabled openssl           && { check_pkg_config openssl openssl openssl/ssl.h OPENSSL_init_ssl ||
                               check_pkg_config openssl openssl openssl/ssl.h SSL_library_init ||
                               check_lib openssl openssl/ssl.h SSL_library_init -lssl -lcrypto ||
                               check_lib openssl openssl/ssl.h SSL_library_init -lssl32 -leay32 ||
                               check_lib openssl openssl/ssl.h SSL_library_init -lssl -lcrypto -lws2_32 -lgdi32 ||
                               die "ERROR: openssl not found"; }

```
修改后的代码: 修改了第二行
```
enabled openssl           && { check_pkg_config openssl openssl openssl/ssl.h OPENSSL_init_ssl ||
                               check_lib openssl openssl/ssl.h OPENSSL_init_ssl -lssl -lcrypto ||
                               check_lib openssl openssl/ssl.h SSL_library_init -lssl -lcrypto ||
                               check_lib openssl openssl/ssl.h SSL_library_init -lssl32 -leay32 ||
                               check_lib openssl openssl/ssl.h SSL_library_init -lssl -lcrypto -lws2_32 -lgdi32 ||
                               die "ERROR: openssl not found"; }

```
#### 5.2 AACENC_InfoStruct缺失encoderDelay
紧接着发生编译错误:
```
libavcodec/libfdk-aacenc.c: In function 'aac_encode_init':
libavcodec/libfdk-aacenc.c:292:34: error: 'AACENC_InfoStruct' has no member named 'encoderDelay'
     avctx->initial_padding = info.encoderDelay;
```
这个错误比较悲剧了，因为当前我们使用的fdk-aac版本是v2.2.0的，但是ffmpeg版本是n4.0.3，ffmpeg版本较低，<br>
这时候要么升级ffmpeg版本，要么降低fdk-aac版本，随便你选择，这儿我选择了降级fdk-aac版本，<br>
因为我们复用ijkplayer中ffmpeg，不太好降级ffmpeg<br><br>

fdk-aac降级到v0.1.6版本。<br>

#### 5.3 libfdk_aac找不到
已经降低了fdk-aac版本，但是又提示这个问题。这时候我们找到ffbuild/config.log，看看具体的问题.<br>
```
genericStds.cpp:(.text+0x360): undefined reference to `pow'
/Users/jeffli/github/JianYing/av_tools/sources/build/fdk-aac/arm64/lib/libfdk-aac.a(genericStds.o): In function `FDKsqrt':
genericStds.cpp:(.text+0x384): undefined reference to `sqrt'
/Users/jeffli/github/JianYing/av_tools/sources/build/fdk-aac/arm64/lib/libfdk-aac.a(genericStds.o): In function `FDKatan':
genericStds.cpp:(.text+0x390): undefined reference to `atan'
/Users/jeffli/github/JianYing/av_tools/sources/build/fdk-aac/arm64/lib/libfdk-aac.a(genericStds.o): In function `FDKlog':
genericStds.cpp:(.text+0x394): undefined reference to `log'
/Users/jeffli/github/JianYing/av_tools/sources/build/fdk-aac/arm64/lib/libfdk-aac.a(genericStds.o): In function `FDKsin':
genericStds.cpp:(.text+0x398): undefined reference to `sin'
/Users/jeffli/github/JianYing/av_tools/sources/build/fdk-aac/arm64/lib/libfdk-aac.a(genericStds.o): In function `FDKcos':
genericStds.cpp:(.text+0x39c): undefined reference to `cos'
/Users/jeffli/github/JianYing/av_tools/sources/build/fdk-aac/arm64/lib/libfdk-aac.a(genericStds.o): In function `FDKexp':
genericStds.cpp:(.text+0x3a0): undefined reference to `exp'
/Users/jeffli/github/JianYing/av_tools/sources/build/fdk-aac/arm64/lib/libfdk-aac.a(genericStds.o): In function `FDKatan2':
genericStds.cpp:(.text+0x3a4): undefined reference to `atan2'
/Users/jeffli/github/JianYing/av_tools/sources/build/fdk-aac/arm64/lib/libfdk-aac.a(genericStds.o): In function `FDKacos':
genericStds.cpp:(.text+0x3a8): undefined reference to `acos'
/Users/jeffli/github/JianYing/av_tools/sources/build/fdk-aac/arm64/lib/libfdk-aac.a(genericStds.o): In function `FDKtan':
genericStds.cpp:(.text+0x3ac): undefined reference to `tan'
collect2: error: ld returned 1 exit status
ERROR: libfdk_aac not found
```
这儿似乎是一些数学库函数找不到，那我们在编译的时候链接一些数据库就行了.如下:
```
EXTRA_LDFLAGS="${EXTRA_LDFLAGS} -L${FDKAAC_LIB_DIR}/lib -lfdk-aac -lm"

```
加上了-lm 编译正常了。


