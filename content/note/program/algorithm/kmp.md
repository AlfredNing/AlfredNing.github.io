---
title: "Kmp"
date: 2023-01-09
tags: ["算法"]
disableShare: true # 底部不显示分享栏
comments: true
showToc: true # 显示目录
---
# 使用场景

多用于**子串**匹配问题

# 流程

在暴力解的过程当中有加速

定义： 在该位置之前的前缀与后缀的长度，但不能取到字符串的整体长度，定义为指标信息

解释：

![image-20230110084144145](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230110084144145.png)

## 对匹配串建立上述指标信息

![image-20230110122628047](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230110122628047.png)

## 匹配过程

![image-20230110234743404](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230110234743404.png)

# 求解证明

![image-20230110223423970](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230110223423970.png)

1. x-r 与 y-r'是相同，从i位置匹配match串等同于从match的q位置进行匹配

2. **i位置到r位置一定不能匹配match**

   **验证：**假设i位置到r位置，有个k位置能够匹配match串，那就说明从k位置到x位置是相同的，也就是match串y位置之前字符串的一个后缀，此时，与next的数组定义违反，出现了一个更长的。假设不成立。

# next数组生成

**match长度为M,时间复杂度为O(M)**

next[0] = -1;

next[1]  = 0;

next[2] = 0位置和1位置决定;

求i位置的next[i]时候，前面所有位置都已经准备好

![image-20230111004958162](https://nq-bucket.oss-cn-shanghai.aliyuncs.com/note_img/image-20230111004958162.png)

## next证明

**来到i位置next[i]最大为next[i+1]+1**

假设next[i]>next[i-1] + 1,

那么说明next[i-1]求解错误，矛盾，不成立

# 代码实现

```java
public class Kmp {
    public static int getIndexOf(String s, String match) {
        if (s == null || match == null || match.length() < 1 || s.length() < match.length()) {
            return -1;
        }
        char[] strs = s.toCharArray();
        char[] matchs = match.toCharArray();
        int x = 0;// strs中当前匹配位置
        int y = 0; // match中当前匹配位置、
        int[] next = getNextArray(matchs);
        while (x < strs.length && y < matchs.length) {
            if (strs[x] == matchs[y]) {
                x++;
                y++;
            } else if (next[y] == -1) { // y已经来到开头 或者写成y==0
                x++;
            } else {
                y = next[y];
            }
        }
        return y == matchs.length ? x - y : -1;
    }

    public static int[] getNextArray(char[] matchs) {
        if (matchs.length == 1) {
            return new int[]{-1};
        }
        int[] next = new int[matchs.length];
        next[0] = -1; // 人为规定
        next[1] = 0; // 人为规定
        int i = 2; // 从2开始
        int cn = 0; // 和i-1位置比较的字符
        while (i < matchs.length) {
            if (matchs[i - 1] == matchs[cn]) {
                next[i++] = ++cn;
            } else if (cn > 0) { // 往前跳
                cn = next[cn];
            } else { // 匹配不到
                next[i++] = 0;
            }
        }
        return next;
    }
}
```





# 时间复杂度-O(N)

对于上述代码的while循环处理

|            | x[最大到N] | x-y[最大到N] |
| ---------- | ---------- | ------------ |
| 第一个分支 | 变大       | 不变         |
| 第二个分支 | 变大       | 变大         |
| 第三个分支 | 不变       | 变大         |

最大为2N,复杂度为O(N)