---
uuid: 105c28f6-bcd3-11ed-abae-3fce2bc8128b
title: source和lunch做了什么
date: 2022-7-2
tags: [Android]
---

source和lunch做了什么

<!--more-->

> Android的优势就在于其开源，手机和平板生产商可以根据自己的硬件进行个性定制自己的手机
> 在我们在对Android的源码进行定制的时候，很有必要了解下，Android的编译过程。

> 如果你从来没有做过Android代码的编译，那么最官方的编译过程就是查看Android的官方网站：`http://source.android.com/source/building.html`

---

按照`google`给出的编译步骤如下：
1. `source build/envsetup.sh`: 加载命令
2. `lunch`：选择平台编译选项
3. `make`：执行编译

## 1. source build/envsetup.sh
这个命令是用来将`envsetup.sh`里的所有用到的命令加载到环境变量里去，我们来分析下它。

### `envsetup.sh`主要方法

* `hmm`显示帮助信息
* `build_build_var_cache`
* `destroy_build_var_cache`
* `get_abs_build_var`获取绝对变量
* `get_build_var`获取绝对变量
* `check_product`检查product
* `check_variant`检查变量
* `setpaths` 设置文件路径
* `printconfig`打印配置
* `set_stuff_for_environment`设置环境变量
* `set_sequence_number`设置序号
* `should_add_completion`
* `addcompletions`
* `choosetype`设置type
* `chooseproduct`设置product
* `choosevariant`设置variant
* `choosecombo`设置编译参数
* `add_lunch_combo`添加lunch项目
* `print_lunch_menu`打印lunch列表
* `lunch`配置lunch
* `_lunch`
* `tapas`功能同choosecombo
* `gettop`
* `m`make from top
* `findmakefile`查找makefile
* `mm`make from current directory
* `mmm`make the supplied directories
* `mma`Builds all of the modules in the current directory, and their dependencies.
* `mmma`Builds all of the modules in the supplied directories, and their dependencies.
* `croot`Changes directory to the top of the tree, or a subdirectory thereof.
* `_croot`
* `cproj`
* `qpid`
* `coredump_setup`
* `coredump_enable`
* `core`
* `systemstack`
* `is64bit`
* `sgrep`Greps on all local source files.
* `gettargetarch`
* `ggrep`Greps on all local Gradle files.
* `jgrep`Greps on all local Java files.
* `cgrep`Greps on all local C/C++ files.
* `resgrep`Greps on all local res/*.xml files.
* `mangrep`Greps on all local AndroidManifest.xml files.
* `sepgrep`Greps on all local sepolicy files.
* `rcgrep`
* `mgrep`Greps on all local Makefiles files.
* `treegrep`
* `getprebuilt`
* `tracedmdump`
* `runhat`
* `getbugreports`
* `getsdcardpath`
* `getscreenshotpath`
* `getlastscreenshot`
* `startviewserver`
* `stopviewserver`
* `isviewserverstarted`
* `key_home`
* `key_back`
* `key_menu`
* `smoketest`
* `runtest`
* `godir`Go to the directory containing a file.
* `refreshmod`Refresh list of modules for allmod/gomod.
* `allmod`List all modules.
* `pathmod`Get the directory containing a module.
* `gomod`Go to the directory containing a module.
* `_complete_android_module_names`
* `pez`
* `get_make_command`
* `_wrap_build`
* `make`
* `provision`
* `enable_zsh_completion`
* `validate_current_shell`
* `check_type`
* `source_vendorsetup`

### `envsetup.sh`其主要作用如下：

1. 加载了编译时使用到的函数命令，如：`help，lunch，m，mm，mmm`等
2. 添加了两个编译选项：`generic-eng`和`simulator`，这两个选项是系统默认选项
3. 查找`vendor/<-厂商目录>/`和`vendor/<厂商目录>/build/`目录下的`vendorsetup.sh`，如果存在的话，加载执行它，添加厂商自己定义产品的编译选项

其实，上述第3条是向编译系统添加了厂商自己定义产品的编译选项，里面的代码就是：`add_lunch_combo xxx-xxx`。

根据上面的内容，可以推测出，如果要想定义自己的产品编译项，简单的办法是直接在`envsetup.sh`最后，添加上`add_lunch_combo myProduct-eng`，当然这么做，不太符合上面代码最后的本意，我们还是老实的在`vendor`目录下创建自己公司名字，然后在公司目录下创建一个新的`vendorsetup.sh`，在里面添加上自己的产品编译项

```bash
#mkdir vendor/<厂商目录>/
#touch vendor/<厂商目录>/vendorsetup.sh
#echo "add_lunch_combo fs100-eng" > vendor/<厂商目录>/vendorsetup.sh
```

这样，当我们在执行`source build/envsetup.sh`命令的时候，可以在`shell`上看到下面的信息：
`including vendor/farsight/vendorsetup.sh`

## 2.lunch

按照`android`官网的步骤，开始执行`lunch full-eng`

当然如果你按上述命令执行，它编译的还是通用的eng版本系统，不是我们个性系统，我们可以执行`lunch`命令，它会打印出一个选择菜单，列出可用的编译选项

如果你按照第一步中添加了`vendorsetup.sh`那么，你的选项中会出现：

```bash
You're building on Linux
generic-eng simulator fs100-eng
Lunch menu... pick a combo:
  1. generic-eng
  2. simulator
  3. fs100-eng
```

其中第3项是我们自己添加的编译项。

`lunch`命令是`envsetup.sh`里定义的一个命令，用来让用户选择编译项，来定义`Product`和编译过程中用到的全局变量。

我们一直没有说明前面的`fs100-eng`是什么意思，现在来说明下，`fs100`是我定义的产品的名字，`eng`是产品的编译类型，除了eng外，还有`user, userdebug`，分别表示：

* eng: 工程机，
* user:最终用户机
* userdebug:调试测试机
* tests:测试机


那么这四个类型是干什么用的呢？其实，在`main.mk`里有说明，在Android的源码里，每一个目标（也可以看成工程）目录都有一个`Android.mk`的`makefile`，每个目标的Android.mk中有一个类型声明：`LOCAL_MODULE_TAGS`，这个`TAGS`就是用来指定，当前的目标编译完了属于哪个分类里。

PS:`Android.mk`和`Linux`里的`makefile`不太一样，它是`Android`编译系统自己定义的一个`makefile`来方便编译成：c,c++的动态、静态库或可执行程序，或`java`库或`android`的程序，

好了，我们来分析下lunch命令干了什么？

```bash
function lunch()
{
    local answer
    if [ "$1" ] ; then
    
       # lunch后面直接带参数
        answer=$1
    else
       # lunch后面不带参数，则打印处所有的target product和variant菜单提供用户选择
        print_lunch_menu  
        echo -n "Which would you like? [generic-eng] "
        read answer
    fi
    
    local selection=
    if [ -z "$answer" ]
    then
           # 如果用户在菜单中没有选择，直接回车，则为系统缺省的generic-eng
        selection=generic-eng
    elif [ "$answer" = "simulator" ]
    then
        # 如果是模拟器
        selection=simulator
    elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$")
    then
        # 如果answer是选择菜单的数字，则获取该数字对应的字符串
        if [ $answer -le ${#LUNCH_MENU_CHOICES[@]} ]
        then
            selection=${LUNCH_MENU_CHOICES[$(($answer-$_arrayoffset))]}
        fi
        # 如果 answer字符串匹配 *-*模式(*的开头不能为-)
    elif (echo -n $answer | grep -q -e "^[^\-][^\-]*-[^\-][^\-]*$")
    then
        selection=$answer
    fi
    
    if [ -z "$selection" ]
    then
        echo
        echo "Invalid lunch combo: $answer"
        return 1
    fi
    # special case the simulator
    if [ "$selection" = "simulator" ]
    then
        # 模拟器模式
        export TARGET_PRODUCT=sim
        export TARGET_BUILD_VARIANT=eng
        export TARGET_SIMULATOR=true
        export TARGET_BUILD_TYPE=debug
    else
    
        # 将 product-variant模式中的product分离出来
        local product=$(echo -n $selection | sed -e "s/-.*$//")
    
        # 检查之，调用关系 check_product()->get_build_var()->build/core/config.mk比较罗嗦，不展开了
        check_product $product
        if [ $? -ne 0 ]
        then
            echo
            echo "** Don't have a product spec for: '$product'"
            echo "** Do you have the right repo manifest?"
            product=
        fi
    
        # 将 product-variant模式中的variant分离出来
        local variant=$(echo -n $selection | sed -e "s/^[^\-]*-//")
    
        # 检查之，看看是否在 (user userdebug eng) 范围内
        check_variant $variant
        if [ $? -ne 0 ]
        then
            echo
            echo "** Invalid variant: '$variant'"
            echo "** Must be one of ${VARIANT_CHOICES[@]}"
            variant=
        fi
    
        if [ -z "$product" -o -z "$variant" ]
        then
            echo
            return 1
        fi
    #  导出环境变量，这里很重要，因为后面的编译系统都是依赖于这里定义的几个变量的
        export TARGET_PRODUCT=$product
        export TARGET_BUILD_VARIANT=$variant
        export TARGET_SIMULATOR=false
        export TARGET_BUILD_TYPE=release
    fi # !simulator
    
    echo
    
    # 设置到环境变量，比较多，不再一一列出，最简单的方法 set >env.txt 可获得
    set_stuff_for_environment
    # 打印一些主要的变量, 调用关系 printconfig()->get_build_var()->build/core/config.mk->build/core/envsetup.mk 比较罗嗦，不展开了
    printconfig
}
```

由上面分析可知，lunch命令可以带参数和不带参数，最终导出一些重要的环境变量，从而影响编译系统的编译结果。导出的变量如下（以实际运行情况为例）

TARGET_PRODUCT=fs100
TARGET_BUILD_VARIANT=eng
TARGET_SIMULATOR=false
TARGET_BUILD_TYPE=release


## 参考

[Android编译详解之lunch命令](https://blog.51cto.com/u_15127616/4235691)