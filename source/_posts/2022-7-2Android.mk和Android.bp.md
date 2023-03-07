---
uuid: 105c28f5-bcd3-11ed-abae-3fce2bc8128b
title: Android.mk和Android.bp
date: 2022-7-2
tags: [Android]
---

Android.mk和Android.bp

<!--more-->

## Android.bp和Android.mk

### 格式转换
通过`Kati`将`Android.mk`转换成`ninja`格式的文件
通过`Blueprint + Soong`将`Android.bp`转换成`ninja`格式的文件
通过`androidmk`将将`Android.mk`转换成`Android.bp`，但针对没有分支、循环等流程控制的`Android.mk`才有效

### 说明
1. `ninja`是一个编译框架，会根据相应的`ninja`格式的配置文件进行编译，但是`ninja`文件一般不会手动修改，而是通过将 `Android.bp`文件转换成`ninja`格文件来编译
2. `Android.bp`是纯粹的配置，没有分支、循环等流程控制，不能做算数逻辑运算。如果需要控制逻辑，那么只能通过`Go`语言编写
3. `Soong`类似于之前的`Makefile`编译系统的核心，负责提供`Android.bp`语义解析，并将之转换成`Ninja`文件。`Soong`还会编译生成一个`androidmk`命令，用于将`Android.mk`文件转换为`Android.bp`文件
4. `Blueprint`是生成、解析`Android.bp`的工具，是`Soong`的一部分。`Soong`负责`Android`编译而设计的工具，而`Blueprint`只是解析文件格式，`Soong`解析内容的具体含义。`Blueprint`和`Soong`都是由`Golang`写的项目，从`Android 7.0`，`prebuilts/go/`目录下新增`Golang`所需的运行环境，在编译时使用
5. `kati`是专为`Android`开发的一个基于`Golang`和`C++`的工具，主要功能是把`Android`中的`Android.mk`文件转换成Ninja文件。代码路径是`build/kati/`，编译后的产物是`ckati`

> Android.mk -> Android.bp
> Android.mk 转换为 `Android.bp,Google`提供了官方工具`androidmk`，只针对简单的mk文件转换，涉及分支，循环等控制转换并不准确
> androidmk使用 ：`androidmk android.mk > android.bp`

### 调用流程
`Makefile-> build/core/main.mk -> build/core/config.mk -> build/core/envsetup.mk -> build/core/product_config.mk`


## Android.mk常用变量
```bash
PRODUCT_OUT
TARGET_OUT_VENDOR
TARGET_COPY_OUT_VENDOR
TARGET_COPY_OUT_PRODUCT
TARGET_COPY_OUT_SYSTEM_EXT
```


## inherit-product和include区别
```bash
include device/mediatek/mt2712/device.mk
$(call inherit-product, device/mediatek/mt2712/device.mk)
$(call inherit-product-if-exists, device/mediatek/mt2712/device.mk)

从注释中可以看到，inherit-product 函数除了会执行通过其参数传入的 Makefile 文件之外，还会额外做 3 件事：
    1、继承通过参数传入的 Makefile 文件中的所有变量（A继承B）；
    2、在 .INHERITS_FROM 变量中记录下这些继承关系；
    3、在 ALL_PRODUCTS 变量中标识出当前操作的 Makefile 文件已经被访问过了（以免重复访问）
```


## include $(call `all-subdir-makefiles`)和include $(call `all-makefiles-under`,$(LOCAL_PATH))区别
```bash
    include $(call all-subdir-makefiles)是直接包含子目录，不管当前目录
        当一级的内容是include $(call all-subdir-makefiles)时候，$(LOCAL_PATH)指向的还是一级目录的路径
    include $(call all-makefiles-under,$(LOCAL_PATH))是包含子目录和当前目录
```
