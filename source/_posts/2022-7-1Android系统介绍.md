---
uuid: 105c28f2-bcd3-11ed-abae-3fce2bc8128b
title: Android系统介绍
date: 2022-7-1
tags:
  - Android
abbrlink: b46e62ef
---

Android系统介绍

<!--more-->

## 单编
* make clean（清理）
* make update-api（更新api和doc一致）
* make systemimage（单编 system.img，make snod）
* make bootimage（单编 boot.img，由kernel, dtb, ramdisk组成）
* make userdataimage-nodeps（单编 userdata.img）
* make aboot（单编 abl.elf，也是bootloader，uboot）
* make target-files-package	编target-files

## 启动流程
`bootloader.img -> boot.img -> system.img`
`Android` 在启动的时候，会由 `UBOOT` 传入一个 `init` 参数，这个`init` 参数指定了开机的时候第一个运行的程序，默认就是 `init` 程序，这个程序在 `ramdisk.img`中。
可以分析一下它的代码，看看在其中到底做了一些什么样的初始化任务，它的源文件在`system/core/init/init.c` 中。
它会调用到 `init.rc`初始化文件，这个文件在 `out/target/product/generic/root` 下，我们在启动以后，会发现根目录是只读属性的，
而且 `sdcard` 的 `owner` 是`system`，就是在这个文件中做了些手脚，可以将它改过来，实现根目录的可读写。

通过分析这几个文件，还可以发现，`android` 启动时首先加载 `ramdisk.img` 镜像，并挂载到`/`目录下，并进行了一系列的初始化动作，
包括创建各种需要的目录，初始化 `console`，开启服务等。
`System.img`是在 `init.rc`中指定一些脚本命令，通过 `init.c` 进行解析并挂载到根目录下的`/system` 目录下的。

## 镜像介绍
1. ramdisk.img : 一个分区镜像文件，它会在`kernel` 启动的时候，以只读的方式被 `mount` ， 这个文件中只是包含了 `/init` 以及一些配置文件，这个`ramdisk` 被用来调用`init`，以及把真正的`root file system mount` 起来。
2. system.img：是包含了整个系统，`android` 的`framework`，`application` 等等，会被挂接到 “`/`” 上，包含了系统中所有的二进制文件
3. userdata.img： 将会被挂接到 `/data` 下，包含了所有应用相关的配置文件，以及用户相关的数据 。
4. boot.img：包括 `boot header，kernel， ramdisk`
`boot`镜像不是普通意义上的文件系统，而是一种特殊的`Android`定制格式，由文件头信息`boot header`，压缩的内核，
文件系统数据`ramdisk`以及`second stage loader`（可选）组成，它们之间非页面对齐部分用0填充
5. update.img：将所有的img文件，通过指定打包工具，制作`update.img`，批量生产中常用到此镜像文件

## 分区
### Modem分区
```
实现手机必需的通信功能，大家通常所的刷RADIO就是刷写modem分区，在所有适配的ROM中这部分是不动，否则会造成通话不稳定
```

### bootloader分区
```
1.bootloader的primary bootloader部分，主要执行硬件检测，确保硬件能正常工作，然后将second bootloader拷贝到内存(RAM)开始执行
2.Second bootloader会进行一些硬件初始化工作，获取内存大小信息等，然后根据用户的按键进入到某种启动模式。
    比如说大家所熟知的通过电源键和其它一些按键的组合，可以进入到recovery，fastboot或者选择启动模式的启动界面等。
3.区分
    高通分为xbl.elf和abl.elf
        bootable/bootloader/edk2
    mtk分为preloader和lk，后者是一些接口，调用前者的实现
        vendor/mediatek/proprietary/bootable/bootloader/lk
        vendor/mediatek/proprietary/bootable/bootloader/preloader

    fastboot模式：fastboot是android定义的一种简单的刷机协议，用户可以通过fastboot命令行工具来进行刷机。
    比如说fastboot flash boot boot.img这个命令就是把boot.img的内容刷写到boot分区中。
    一般的手机厂商不直接提供fastboot模式刷机，总是会提供自己专有的刷机工具和刷机方法。比如说三星的Odin，摩托的RSD，华为的粉屏等等。
    但是其本质实际上是相同的，都是将软件直接flash到各个分区中。这种通常称为线刷，是比较原始的方法。当手机处于开不了机的情况下，可以使用此厂家提供的工具进行刷入
```

### boot分区
```
当我们只是按下电源键开机时，会进入正常启动模式。
Secondarystagebootloader会从boot分区开始启动。Boot分区的格式是固定的，首先是一个头部，然后是Linux内核，最后是用作根文件系统的ramdisk。
当Linux内核启动完毕后，就开始执行根文件系统中的init程序，
init程序会读取启动脚本文件(init.rc和init.xxxx.rc),执行脚本中指定的动作和命令，脚本中的一部分是运行system分区的程序
```

### recoverty分区
```
recovery模式：recovery是android定义的一个标准刷机协议。
当进入recovery模式时，second bootloader从recovery分区开始启动，recovery分区实际上是一个简单的Linux系统，
当内核启动完毕后，开始执行第一个程序init(init程序是Linux系统所有程序的老祖宗)。
init会启动一个叫做recovery的程序（recovery模式的名称也由此而来）。
通过recovery程序，用户可以执行清除数据，安装刷机包等操作。
一般的手机厂商都提供一个简单的recovery刷机，多只能进行upate的操作。不能进行卡刷；如果想要自已卡刷，则需要事先刷入第三方的Recovery，然后选择刷机包。
```

### system分区
```
除linux Kernel部分位于boot分区外，在其上的Library、runtime、framework、core application都是处于system分区
1、/system/priv-app
    特权App，比system_app权限还要高，其不仅System_app标识是true，同时还置了Priv-app标识。
2、/system/app
    核心应用程序档(*.apk: Android应用程序包)，都是放在这。像是Phone、Alarm Clock, Browser, Contacts 等等。
3、/system/framework
    这里放 Android 系统的核心程序库，就是上图中application framework部分的库。像是core.jar, framework-res.apk, framework.jar等等。
4、system/lib
    存放Library部分的库，存放的是所有动态链接库(.so文件)，这些.SO是JNI层，Dalvik虚拟机，本地库，HAL层所需要的，
    因为系统应用/system/app下的apk是不会解压的SO到程序的目录下，所以其相应用的SO，都应放在/system/lib 下面。
    当一个系统apk的SO加载时，会从此目录下寻找对应用的SO文件；
5、/system/media/audio/(notification, alarms, ringtones, ui)
    这里放系统的声音档，像是闹铃声，来电铃声等等。这些声音档，多是 ogg 格式。
6、/system/bin
    存放的是一些可执行文件，基本上是由C/C++编写的。其中有一个重要的命令叫app_process。一般大家称之为Zygote。
    （Zygote是卵的意思，所有的Android进程都是由它生出来的)。Zygote首先会加载dalvik虚拟机，然后产生一个叫做system_server的进程。
    system_server顾名思义被称作Android的系统服务程序，它主要管理整个android系统。
    system_server启动完成后开始寻找一个叫做启动器的程序，找到之后由zygote开始启动执行启动器，这就是我们常见到的桌面程序。
7、system/xbin
    存放的是一些扩展的可执行文件，既该目录可以为空。大家常用的busybox就放在该目录下。Busybox所建立的各种符号链接命令都是放在该目录。
8、system/build.prop
    build.prop和上节说得根文件系统中的default.prop文件格式一样，都称为属性配置文件。它们都定义了一些属性值，代码可以读取或者修改这些属性值。属性值有一些命名规范：
    　　ro开头的表示只读属性，即这些属性的值代码是无法修改的。
    　　persist开头的表示这些属性值会保存在文件中，这样重新启动之后这些值还保留。
    　　其它的属性一般以所属的类别开头，这些属性是可读可写的，但是对它们的修改重启之后不会保留。
9、system/etc
    目录存放一些配置文件，和属性配置文件不一样，这下面的配置文件可能稍微没那么的有规律。
    一般来说，一些脚本程序，还有大家所熟悉GPS配置文件(gps.conf)和APN配置文件(apns-conf.xml)放在这个目录。
    像HTC将相机特效所使用的一些文件也放在这个目录下。
```

### data分区
```
当我们开机进入桌面程序后，一般来说我们都会下载安装一些APP，这些APP都安装在data/app目录下。所有的Android程序生成的数据基本上都保存在data/data目录下。
wipedata实质上就是格式化data分区，这样我们安装的所有APP和程序数据就都丢失了。
1、/data/app
    放的是使用者自己安装的应用程式执行档(*.apk)。
2、/data/data/
    当你在程式中用Context.openFileOutput() 所建立的档案，都放在这个目录下的files 子目录内。而用Context.getSharedPreferences() 所建立的preferences 档(*.xml) ，则是放在shared_pref 这个子目录中。
3、/data/anr/traces.txt
    当你的应用程式发生ANR (Application is Not Responding) 错误时，Android 会自动将问题点的code stack list 写在这个档案内，你直接用cat 命令就可以看他的内容。
4、/data/system/dropbox/***.txt
    主要是系统内apk发生crash时写的日志文件，主要有system_app_crash、data_app_crash等日志。
5、/data/location/gps
    是给GPS location provider 用的。其中的 properties 档案的内容如下：
6、/data/system/location/location.gps
    一般文字档。主要是记录最后的经纬度座标。 LocationManager.getLastKnownLocation() 就在来这抓值的。
7、/data/property/persist.sys.timezone
    这个档案也是个一般文字档。主要是记录目前系统所使用的时区。在我的模拟器上，他记录着Asia/Taipei 这个字串。
```

### cache分区
```
此分区是安卓系统缓存区，他保存系统最常访问的数据和应用程序。
擦除这个分区，不会影响个人数据，只是删除了这个分区中已经保存的缓存内容，缓存内容会在后续手机使用过程中重新自动生成。
```

### misc分区
```
misc分区中有Bootloader Control Block（BCB），主要是用于存放Recovery引导信息。
```

### vbmeta分区
```
验证启动（Verified Boot）是Android一个重要的安全功能，主要是为了访问启动镜像被篡改，提高系统的抗攻击能力，简单描述做法就是在启动过程中增加一条校验链，即 ROM code 校验 BootLoader，确保 BootLoader 的合法性和完整性，BootLoader 则需要校验 boot image，确保 Kernel 启动所需 image 的合法性和完整性，而 Kernel 则负责校验 System 分区和 vendor 分区。
由于 ROM code 和 BootLoader 通常都是由设备厂商 OEM 提供，而各家实际做法和研发能力不尽相同，为了让设备厂商更方便的引入 Verified boot 功能，Google 在 Android O上推出了一个统一的验证启动框架 Android verified boot 2.0，好处是既保证了基于该框架开发的verified boot 功能能够满足 CDD 要求，也保留了各家 OEM 定制启动校验流程的弹性。
由于 ROM code 校验 BootLoader 的功能通常与 IC的设计相关，所以 AVB 2.0 关注的重点在 BootLoader 之后的校验流程。BootLoader 之后系统启动所涉及的关键镜像通常包括 boot.img，system.img，Android O 的 treble Project 还引入了 dtbo 和 vendor.img。这些 image 挨个校验可以说费时费力，而 AVB 2.0 的做法事实上十分简单，引入一个新的分区：vbmeta.img（verified boot metadata），然后把所有需要校验的内容在编译时就计算好打包到这个分区，那么启动过程中 BootLoader 只需要校验 vbmeta.img，就能确认 vbmeta 内的数据是否可信。再用 vbmeta 中的数据去比对 bootimg，dtbo，system,img，vendor.img 即可。至于 OEM 是还需要放什么其他东西到 vbmeta 中，则可以由 OEM 自由定制，可以说保留了很好的客制化空间。
除了最基本的验证启动之外，AVB 2.0 还提供防止回滚的功能和对AB分区备份的支持，具体的可以看README文档（安卓源码external/avb/README.md）。
生成过程：
    vbmeta.img 这个镜像不是编译生成的，它是依赖avbtool 工具生成，这个其实是一个python脚本，详细原理可以参阅external/avb/avbtool 源码，这里我们只整理Android源码下的生成流程，用最原始的方法追踪生成流程（事实证明是最直接、最有效的 ），安卓代码编译之后，在编译log只能看到一句log：
```

### dtbo分区
```
dt或者dto镜像在这里Google把它笼统地称作dtbo镜像，他们的格式是一样的，都是把多个dtc编译出来的dtb二进制或者dto二进制打包到一个image
每个硬件设备对应一个dtb和dto，把多个dtb或者dto按照图示的格式打包成对应的dt.img和dto.img，这样软件可以做到共镜像，方便了厂商对产品的维护工作
```
