---
title: Android APK签名
date: 2022-7-1
tags: [android, apk, 签名]
---

Android APK签名

<!--more-->

## 平台签名

### apk的签名

简单说开发者可以通过签名 对应用进行标识和更新。包名在一个设备上是唯一的，这样可以**避免被相同包名应用随意覆盖安装**。这是一个非常重要的安全功能。系统中的签名文件，也是对系统中应用进行签名，编译应用是可以指定签名类型。

### Android系统中的主要签名文件
`media.pk8，media.x509.pem；platform.pk8，platform.x509.pem；releasekey.pk8，releasekey.x509.pem；shared.pk8，shared.x509.pem；testkey.pk8，testkey.x509.pem`

### Android系统中的签名文件的路径
默认在`build/target/product/security`目录下。

### 编译时签名文件的配置
在`Android.mk`通过设置`LOCAL_CERTIFICATE`实现。如：`LOCAL_CERTIFICATE := platform`即选择`platform`来签名。

> 注：预置无源码的`apk`应用时，很多时候仍然使用原本第三方签名，`LOCAL_CERTIFICATE := PRESIGNED`。

### `.pk8`和`.x509.pem`的区别

`.pk8`就是私钥文件，用于对`apk`进行签名。这个私钥需要保密保存，不能公开。
`.x509.pem`是证书文件，相当于公钥。这个可以公开，主要用于验证某个`apk`是否由相应的私钥签名。

### 系统不同签名文件的区别
- sharedUserId
    - 每个apk或文件，系统都会分配属于自己的统一的用户ID（UID），创建沙箱保证其他应用的影响或影响其他应用。如：一般应用只能访问自己包名下的文件（/data/data/pkgname），不能反问其他包名下的，其他应用也访问不了自己包名下的文件。
    - sharedUserId,拥有同一user id的应用 之间就可以共享数据库和文件，相互访问。这些应用可以运行在同一进程，也可以运行不同进程。

- sharedUserId与签名文件
    - 只有拥有相同sharedUserId标签的，且拥有相同签名的 应用才能分配相同的用户ID，实现数据共享。如果仅仅拥有相同sharedUserId标签，是无法确保安全的，也很容易被非法利用。

- 系统中5类签名文件说明
    - platform:平台的核心应用签名，签名的apk是完成系统的核心功能。这些apk所在的进程UID是system。manifest节点中有添加android:sharedUserId="android.uid.system"。
    - media: 这个签名的apk是media/download的一部分。manifest节点中有添加android:sharedUserId="android.media"。
    - shared:这个签名的apk可以和home/contacts进程共享数据。manifest节点中有添加android:sharedUserId="android.uid.shared"。
    - testkey/releasekey:平台默认key。在编译中未指定LOCAL_CERTIFICATE的，默认是用testkey。因为testkey是公开的，任何人都可以获取，不安全，所以一般使用 自己创建releasekey作为默认key。

### 修改平台默认签名

```
build/core/config.mk路径下，修改下面变量为：
    DEFAULT_SYSTEM_DEV_CERTIFICATE := build/target/product/security/releasekey
    或者使用宏控选择。
system/sepolicy/private/keys.conf 和 system/sepolicy/prebuilts/api/{apilevel}/private/keys.conf下，修改：
    -ENG : $DEFAULT_SYSTEM_DEV_CERTIFICATE/testkey.x509.pem
    -USER : $DEFAULT_SYSTEM_DEV_CERTIFICATE/testkey.x509.pem
    -USERDEBUG : $DEFAULT_SYSTEM_DEV_CERTIFICATE/testkey.x509.pem
    +ENG : $DEFAULT_SYSTEM_DEV_CERTIFICATE/releasekey.x509.pem
    +USER : $DEFAULT_SYSTEM_DEV_CERTIFICATE/releasekey.x509.pem
    +USERDEBUG : $DEFAULT_SYSTEM_DEV_CERTIFICATE/releasekey.x509.pem
build/core/core/Makefile下修改变量为：
    BUILD_VERSION_TAGS = release-keys
    或者使用宏控选择。
```


## pk8和x509.pem生成和签名

### Android生成
`./development/tools/make_key releasekey '/C=CN/CT=Beijing/L=Beijing View/O=Android/CN=Android/emailAddress=jmm@org.com'`

### Apk生成
`keytool -genkey -v -keystore app.keystore -alias gundam_wing -keyalg RSA -validity 20000`

后续步骤如下
```bash
口令
口令
TechStone
Gundam
Gundam
Shanghai
Shanghai
zh
Y
回车
```
```
keytool -importkeystore -srckeystore app.keystore -destkeystore tmp.p12 -srcstoretype JKS -deststoretype PKCS12
openssl pkcs12 -in tmp.p12 -nodes -out tmp.rsa.pem
将 -----BEGIN PRIVATE KEY----- 到 -----END PRIVATE KEY----- 这一段（包含这两个tag）的文本复制出来，新建为文件my_private.rsa.pem
将 -----BEGIN CERTIFICATE----- 到 -----END CERTIFICATE----- 这一段（包含这两个tag）的文本复制出来，新建为文件my.x509.pem（签名时用到的公钥）
openssl pkcs8 -topk8 -outform DER -in my_private.rsa.pem -inform PEM -out my_private.pk8 -nocrypt
```

## 单独签名
`java -jar signapk.jar my.x509.pem my_private.pk8 my.apk my_signed.apk`