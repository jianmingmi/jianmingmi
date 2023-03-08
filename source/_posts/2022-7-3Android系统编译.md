---
uuid: 105c28f7-bcd3-11ed-abae-3fce2bc8128b
title: Android系统编译
date: 2022-7-3
tags:
  - Android
categories:
  - Android
abbrlink: 135a8f34
---

Android系统编译

<!--more-->

## 1 概要
  在 Android 7.0 之前，Android 编译系统使用 GNU Make 描述和shell来构建编译规则，模块定义都使用Android.mk进行定义，Android.mk的本质就是Makefile，但是随着Android的工程越来越大，模块越来越多，Makefile组织的项目编译时间越来越长。这样下去Google工程师觉得不行，得要优化。

  因此，在Android7.0开始，Google采用ninja来代取代之前使用的make，由于之前的Android.mk数据实在巨大，因此Google加入了一个kati工具，用于将Android.mk转换成ninja的构建规则文件buildxxx.ninja,再使用ninja来进行构建工作。

  ninja的网址：https://ninja-build.org

  编译速度快了一些，但是既然要干， 那就干个大的，最终目标要把make都取代，于是从Android8.0开始，Google为了进一步淘汰Makefile，因此引入了Android.bp文件来替换之前的Android.mk。

  Android.bp只是一个纯粹的配置文件，不包括分支、循环语句等控制流程，本质上就是一个json配置文件。Android.bp  通过Blueprint+soong转换成ninja的构建规则文件build.ninja，再使用ninja来进行构建工作。

  Android10.0上，mk和bp编译的列表可以从 \out\.module_paths中的Android.bp.list、Android.mk.list中看到，Android10.0还有400多个mk文件没有被替换完，Google任重道远。

## 2.Android编译演进过程
 Android编译演进过程：

Android7.0之前 使用GNU Make

Android7.0 引入ninja、kati、Android.bp和soong构建系统

Android8.0 默认打开Android.bp

Android9.0 强制使用Android.bp

 Google在 Android 7.0之后，引入了Soong构建系统，旨在取代make，它利用 Kati GNU Make 克隆工具和 Ninja 构建系统组件来加速 Android 的构建。

 Make 构建系统得到了广泛的支持和使用，但在 Android 层面变得缓慢、容易出错、无法扩展且难以测试。Soong 构建系统正好提供了 Android build 所需的灵活性。

Android系统的编译历程：

![](/images/2022-7-3Android系统编译/2022-7-3Android系统编译_1.jpg)

## 3 编译流程
### 3.1 编译目录
Android的编译目录在/build 中，看一下Android 10源码中的build目录，现在是这个样子：

![](/images/2022-7-3Android系统编译/2022-7-3Android系统编译_2.png)

   这个目录中可以看到core文件夹被link到了make/core，envsetup.sh被link到make/envsetup.sh，这主要是为了对使用者屏蔽切换编译系统的差异。

   这里重点看四个文件夹：blueprint、kati、make、soong

   blueprint：用于处理Android.bp，编译生成*.ninja文件，用于做ninja的处理

   kati：用于处理Android.mk，编译生成*.ninja文件，用于做ninja的处理

   make：文件夹还是原始的make那一套流程，比如envsetup.sh

   soong：构建系统，核心编译为soong_ui.bash

### 3.2 soong编译构成
  在编译过程中，Android.bp会被收集到out/soong/build.ninja.d,blueprint以此为基础，生成out/soong/build.ninja

  Android.mk会由kati/ckati生成为out/build-aosp_arm.ninja

  两个ninja文件会被整合进入out/combined-aosp_arm.ninja

  Soong编译构成：

![](/images/2022-7-3Android系统编译/2022-7-3Android系统编译_3.png)

### 3.3 soong 编译过程
  soong的编译过程如下图所示：

![](/images/2022-7-3Android系统编译/2022-7-3Android系统编译_4.png)

## 4 编译步骤
编译时通常需要执行的编译命令：

```bash
source build/envsetup.sh
lunch aosp_arm-eng // 或者 m PRODUCT-aosp_x86_64-eng  ，Android10.0不一定需要lunch命令
make -j8      //编译模块也可以直接用 m libart
```

![](/images/2022-7-3Android系统编译/2022-7-3Android系统编译_5.png)

### 4.1 编译环境初始化
#### 4.1.1 envsetup
envsetup.sh 主要做了下面几个事情：

![](/images/2022-7-3Android系统编译/2022-7-3Android系统编译_6.png)

在source build/envsetup.sh后，输入hmm可以看到envsetup支持的一些接口：

|  命令   | 说明  |
|  ----  | ----  |
| lunch | lunch <product_name>-<build_variant>。选择<product_name>作为要构建的产品，<build_variant>作为要构建的变体，并将这些选择存储在环境中，以便后续调用“m”等读取。 |
| tapas | 交互方式：tapas [<App1> <App2> ...] [arm|x86|mips|arm64|x86_64|mips64] [eng|userdebug|user] |
| croot | 将目录更改到树的顶部或其子目录。 |
| m | 编译整个源码，可以不用切换到根目录 |
| mm | 编译当前目录下的源码，不包含他们的依赖模块 |
| mmm | 编译指定目录下的所有模块，不包含他们的依赖模块   例如：mmm dir/:target1,target2. |
| mma | 编译当前目录下的源码，包含他们的依赖模块 |
| mmma | 编译指定目录下的所模块，包含他们的依赖模块 |
| provision | 具有所有必需分区的闪存设备。选项将传递给fastboot。 |
| cgrep | 对系统本地所有的C/C++ 文件执行grep命令 |
| ggrep | 对系统本地所有的Gradle文件执行grep命令 |
| jgrep | 对系统本地所有的Java文件执行grep命令 |
| resgrep | 对系统本地所有的res目录下的xml文件执行grep命令 |
| mangrep | 对系统本地所有的AndroidManifest.xml文件执行grep命令 |
| mgrep | 对系统本地所有的Makefiles文件执行grep命令 |
| sepgrep | 对系统本地所有的sepolicy文件执行grep命令 |
| sgrep | 对系统本地所有的source文件执行grep命令 |
| godir | 根据godir后的参数文件名在整个目录下查找，并且切换目录 |
| allmod | 列出所有模块 |
| gomod | 转到包含模块的目录 |
| pathmod | 获取包含模块的目录 |
| refreshmod | 刷新allmod/gomod的模块列表 |

### 4.2 Lunch 说明
  环境变量初始化完成后，我们需要选择一个编译目标。lunch 主要作用是根据用户输入或者选择的产品名来设置与具体产品相关的环境变量。

  如果你不知道想要编译的目标是什么，直接执行一个lunch命令，会列出所有的目标，直接回车，会默认使用aosp_arm-eng这个目标。

![](/images/2022-7-3Android系统编译/2022-7-3Android系统编译_7.png)

执行命令：lunch 1， 可以看到配置的一些环境变量
这些环境变量的含义如下：

| lunch结果 | 说明 |
| ---- | ---- |
| PLATFORM_VERSION_CODENAME=REL | 表示平台版本的名称 | 
| PLATFORM_VERSION=10 | Android平台的版本号 | 
| TARGET_PRODUCT=aosp_arm | 所编译的产品名称 | 
| TARGET_BUILD_VARIANT=userdebug | 所编译产品的类型 | 
| TARGET_BUILD_TYPE=release | 编译的类型，debug和release | 
| TARGET_ARCH=arm | 表示编译目标的CPU架构 | 
| TARGET_ARCH_VARIANT=armv7-a-neon | 表示编译目标的CPU架构版本 | 
| TARGET_CPU_VARIANT=generic | 表示编译目标的CPU代号 | 
| HOST_ARCH=x86_64 | 表示编译平台的架构 | 
| HOST_2ND_ARCH=x86 | 表示编译平台的第二CPU架构 | 
| HOST_OS=linux | 表示编译平台的操作系统 | 
| HOST_OS_EXTRA=Linux-4.15.0-112-generic-x86_64-Ubuntu-16.04.6-LTS | 编译系统之外的额外信息 | 
| HOST_CROSS_OS=windows | 
| HOST_CROSS_ARCH=x86 | 
| HOST_CROSS_2ND_ARCH=x86_64 | 
| HOST_BUILD_TYPE=release | 编译类型 | 
| BUILD_ID=QQ1D.200205.002 | BUILD_ID会出现在版本信息中，可以利用 | 
| OUT_DIR=out | 编译结果输出的路径 | 


### 4.3 Make
  执行完lunch命令后，就可以使用make命令来执行编译Build。

  Android10.0上是通过soong执行编译构建，这里执行make命令时，main.mk文件把一些环境变量和目标都配置好后，会执行envsetup.sh中的make()进行编译

  如果找到“build/soong/soong_ui.bash”，就使用soong_ui.bash 来进行编译，否则使用原始的make命令进行编译。

  [build/soong/soong_ui.bash]配置一些资源环境，得到一些函数命令，例如：soong_build_go,最终回退到根目录，执行out/soong_ui --make-mode进行真正的构建

  soong_build_go soong_ui android/soong/cmd/soong_ui  是通过编译android/soong/cmd/soong_ui/main.go来编译生成soong_ui.

  根据[3.3]的图所示，执行runKatiBuild时，有个重要的步骤，就是加载build/make/core/main.mk，main.mk文件是Android Build系统的主控文件。从main.mk开始，将通过include命令将其所有需要的.mk文件包含进来，最终在内存中形成一个包括所有编译脚本的集合，这个相当于一个巨大Makefile文件。Makefile文件看上去很庞大，其实主要由三种内容构成: 变量定义、函数定义和目标依赖规则，此外mk文件之间的包含也很重要。

  main.mk的包含关系如下图所示：

![](/images/2022-7-3Android系统编译/2022-7-3Android系统编译_8.png)

## 5 编译链说明
  Android10.0的编译系统中，涉及以下一些工具链，由这些工具链相辅相成，才最终编译出了我们所需要的镜像版本。

  Android10.0编译工具链:

  soong\kati\blueprint\ninja  

 

### 5.1.Soong说明
  Soong 构建系统是在 Android 7.0 (Nougat) 中引入的，旨在取代 Make。它利用 Kati GNU Make 克隆工具和 Ninja 构建系统组件来加速 Android 的构建。

  Soong是由Go语言写的一个项目，从Android 7.0开始，在prebuilts/go/目录下新增了Go语言所需的运行环境，Soong在编译时使用，解析Android.bp，将之转化为Ninja文件，完成Android的选择编译，解析配置工作等。故Soong相当于Makefile编译系统的核心，即build/make/core下面的内容。

  另外Soong还会编译产生一个androidmk命令，可以用来手动将Android.mk转换成Android.bp文件。不过这只对无选择、循环等复杂流程控制的Android.mk生效。

soong脚本和代码目录：/build/soong

 

### 5.2.kati说明
  kati是一个基于Makefile来生成ninja.build的小项目。主要用于把Makefiel转成成ninja file，自身没有编译能力，转换后使用Ninja编译。

  在编译过程中，kati负责把既有的Makefile、Android.mk文件，转换成Ninja文件。在Android 8.0以后，它与Soong一起，成为Ninja文件的两大来源。Kati更像是Google过渡使用的一个工具，等所有Android.mk都被替换成Android.bp之后，Kati有可能退出Android编译过程.

  在单独使用时，它对普通的小项目还能勉强生效。面对复杂的、多嵌套的Makefile时，它往往无法支持，会出现各种各样的问题。当然，也可以理解为，它只为Android而设计。

  kati脚本和代码目录：/build/kati

  详细说明请参考：

  Kati详解-Android10.0编译系统（五）

### 5.3.blueprint说明
  Blueprint由Go语言编写，是生成、解析Android.bp的工具，是Soong的一部分。Soong则是专为Android编译而设计的工具，Blueprint只是解析文件的形式，而Soong则解释内容的含义。

在Android编译最开始的准备阶段，会执行build/soong/soong_ui.bash进行环境准备。 

对blueprint项目编译完成之后会在out/soong/host/linux-x86/bin目录下生成soong编译需要的5个执行文件(bpfix,bpfmt,bpmodify,microfatory,bpmodify)。

  Soong是与Android强关联的一个项目，而Blueprint则相对比较独立，可以单独编译、使用。

  blueprint代码目录：/build/blueprint

     详细说明请参考：

    Blueprint简介-Android10.0编译系统（六）

 

### 5.4.ninja说明
  最开始，Ninja 是用于Chromium 浏览器中，Android 在SDK 7.0 中也引入了Ninja。

Ninja是一个致力于速度的小型编译系统（类似于Make），如果把其他编译系统比做高级语言的话，Ninja就是汇编语言。通常使用Kati或soong把makefile转换成Ninja files，然后用Ninja编译。

  主要两个特点：

  1)可以通过其他高级的编译系统生成其输入文件；

  2)它的设计就是为了更快的编译；

  ninja核心是由C/C++编写的，同时有一部分辅助功能由python和shell实现。由于其开源性，所以可以利用ninja的开源代码进行各种个性化的编译定制。

  详细说明请参考：

  Ninja简介-Android10.0编译系统（九）

 

### 5.5 编译工具链的关系
 Android.mk文件、Android.bp、kati、Soong、Blueprint、Ninja之间的关系如下：

  Android.bp --> Blueprint --> Soong --> Ninja 

 Makefile or Android.mk --> kati --> Ninja 

  (Android.mk --> Soong --> Blueprint --> Android.bp)

  Android.bp通过Blueprint工具链进行解析，通过Soong流程编译成build.ninja

Android.mk通过kati\ckati工具链进行解析编译，生成out/build-<product_name>.ninja。

  然后Soong的编译流程会把生成的几个ninja文件组合成为out/combined-<product_name>.ninja。

  最后通过Ninja工具，来解析out/combined-<product_name>.ninja执行最终的编译。

## 6.Ninja提升编译速度方法
### 6.1编译分析
在每次启动编译的时候，soong都要重新收集所有的文件、.mk、.bp的修改，然后重新生成build.ninja，在合并成combined-aosp_arm.ninja，这要花费大量的时间。

  如下图所示整个编译过程，准备过程非常冗长。

![](/images/2022-7-3Android系统编译/2022-7-3Android系统编译_9.png)

    大部分情况下，研发的工作是不断的修改.c .h .cpp .java 然后增量，此时真正的编译工作是非常少的，这样相对而言，准备工作往往是占大头的，所以我们可以考虑舍弃combined-aosp_arm.ninja之前的准备过程。

 

### 6.2 qninja提升编译速度
   根据上一节分析到，舍弃combined-aosp_arm.ninja的准备过程，直接指向ninja可以提升速率，因此我们可以开发一个快速的编译命令，来提升研发的编译效率。

    我们可以在修改build/make/envsetup.sh，新增一个qninja函数。

```
function qninja()
{
    local cmdline="time prebuilts/build-tools/linux-x86/bin/ninja -v -d keepdepfile $@ -f out/combined-aosp_arm.ninja -w dupbuild=warn"
    echo $cmdline
    $cmdline
}
```

只是修改了某个模块中的.c .h .cpp .java后，进行增量，编译命令如下：

```
source build/envsetup.sh
qninja init_system
```

最终的编译时间仅仅花费了5秒：

```
real    0m5.351s
user    0m14.752s
sys     0m3.201s
```
 
## 7.总结
    Android10.0的编译系统到这基本上做了大体的简要说明，Android编译系统非常庞杂和细致，还有比如最新的VINTF的manifest编译，内核新增的GKI Kernel编译等，这些都需要在工作中花费大量的时间去研究，但是现在最终的流程都绕不过 blueprint\kati\soong\ninja的编译流程，所以掌握好基础的知识，才能更快的理解新的编译模块及流程。

## 参考

[Android10.0编译系统](https://blog.csdn.net/yiranfeng/article/details/109708105)