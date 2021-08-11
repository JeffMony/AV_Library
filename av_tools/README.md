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
配置环境变量ANROID_NDK，这儿我选择的编辑版本是android-ndk-r14b

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
没办法，继续注释掉错误的代码.



### 4.编译libx264
执行init_libx264.sh<br>
libx264源码下载到./sources/libx264目录下<br>
进入./sources目录，执行./compile_libx264.sh all

### 5.编译ffmpeg
执行init_ffmpeg.sh<br>
ffmpeg源码下载到./sources/ffmpeg目录下<br>
进入./sources目录，执行./compile_ffmpeg.sh all