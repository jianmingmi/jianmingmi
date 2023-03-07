---
uuid: 105c01e2-bcd3-11ed-abae-3fce2bc8128b
title: git merge策略解析
date: 2022-6-26
tags: [Git]
---

git merge策略解析

<!--more-->

## 命令
``git merge BRANCH_NAME [-s, --strategy <strategy>] [-X, --strategy-option <option=value>]``

## git merge策略，参数：``-s``

- resolve
- recursive
- octopus
- ours
- subtree

### resolve

```
这使用的是三路合并算法。的三路合并算法会存在发现多个共同祖先的问题。
此策略会 “仔细地” 寻找其中一个共同祖先。
由于不需要递归合并出虚拟节点，所以此方法合并时会比较快速，但也可能会带来更多冲突。
不敢说带来更多冲突是好事还是坏事，因为自动合并成功并不一定意味着在代码含义上也算是正确的合并。
所以如果自动合并总是成功但代码含义上会失败，可以考虑此合并策略，这将让更多的冲突变成手工合并而不是自动合并。
```

### recursive

```
这是默认的合并策略，如果你不指定策略参数，那么将使用这个合并策略。这将直接使用递归三路合并算法进行合并。
```

### octopus

```
此策略允许合并多个 git 提交节点（分支）。
不过，如果会出现需要手工解决的冲突，那么此策略将不会执行。
此策略就是用来把多个分支聚集在一起的。
```

### ours

```
在合并的时候，无论有多少个合并分支，当前分支就直接是最终的合并结果。无论其他人有多少修改，在此次合并之后，都将不存在（当然历史里面还有）。

你可能觉得这种丢失改动的合并策略没有什么用。但如果你准备重新在你的仓库中进行开发（程序员最喜欢的重构），那么当你的修改与旧分支合并时，采用此合并策略就非常有用，你新的重构代码将完全不会被旧分支的改动所影响。

注意 recursive 策略中也有一个 ours 参数，与这个不同的。
```

### subtree

```
此策略使用的是修改后的递归三路合并算法。与 recursive 不同的是，此策略会将合并的两个分支的其中一个视为另一个的子树，就像 git subtree 中使用的子树一样。
```

## git merge策略的参数，参数：``-X``

- ours
- theirs
- ignore-space-change
- find-renames=0
- diff-algorithm={patience|minimal|histogram|myers}

### resolve

```
-X ours（使用我们的）
-X theirs（使用他们的）
-X ignore-space-change（空格改动的话就忽略）
-X find-renames=0（值越小，使文件越相同）
-X diff-algorithm={patience|minimal|histogram|myers}（指定一个差异算法，myers是默认的，具体算法差异可通过man手册来查看）
    此策略的名称叫 “耐心”，因为 git 将话费更多的时间来进行合并一些看起来不怎么重要的行，合并的结果也更加准确。当然，使用的算法是 recursive 即递归三路合并算法
```

## git merge其他参数

``git merge BRANCH_NAME``

- no-ff               强行关掉fast-forward，所以在使用这种方式后，分支合并后会生成一个新的commit（默认--ff）
- no-edit             不进入编辑页面，直接提交
- squash              创建一个单独的提交而不是做一次合并
- stat                show a diffstat at the end of the merge
- summary             (synonym to --stat)


## git merge方案

- 可使用``git merge-base -a [branch1] [branch2]``查看两个分支或节点共同祖先，可提炼出需要合入的修改有哪些
- 使用``git merge --no-ff -s recursive -X ignore-space-change  -m "Upgrade from xxx" --no-edit -q [BRANCH_NAME]``合入代码
- 使用``git ls-files -u``查看未合并的文件
- 提交到审查系统修改后统一合入
