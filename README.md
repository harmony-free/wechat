# wechat

#### 介绍 [English](README.en.md)

这是鸿蒙版本基于微信第三方简化封装的库，分享文字、分享图片、分享网页、分享小程序、打开小程序、打开微信

#### 软件架构

这是鸿蒙版本基于微信开放平台

#### 安装教程

`ohpm install @free/wechat`

#### 使用说明

1、初始化，配置wxId以及handle监听方法
```
WXUtil.install.setConfig({wxId:"wxc4daXXXXXXXXXXX",handleWant:want});
```
2、配置基础分享配置(可选)
```
let mConfig:MessageConfig = {
    title:call.argument("title"),
    description:call.argument("desc"),
    thumb:$r("app.media.app_icon_store"),
    onResp:(resp)=>{
        result.success(resp);
    }
};
```

3、分享文字
```
WeChat.install.shareText("text",{onResp:(resp)=>{}})
```
4、分享图片
```
WeChat.install.shareImage("https://img.ixintu.com/download/jpg/201911/e25b904bc42a74d7d77aed81e66d772c.jpg!con",{onResp:(resp)=>{}})
```
5、分享网页
```
WeChat.install.shareWeb("https://developer.huawei.com/consumer/cn/",{onResp:(resp)=>{}})
```
6、分享小程序
```
WeChat.install.shareMini("username","path",{onResp:(resp)=>{}})
```
7、打开微信
```
WeChat.install.openWX("weixin://dl/business/?t=YODfF8dNclo",{onResp:(resp)=>{}})
```
8、打开小程序
```
WeChat.install.openMini("username","path",{onResp:(resp)=>{}})
```

#### 参与贡献

1. Fork 本仓库
2. 新建 Feat_xxx 分支
3. 提交代码
4. 新建 Pull Request

#### 特技

1. 使用 Readme\_XXX.md 来支持不同的语言，例如 Readme\_en.md, Readme\_zh.md
2. Gitee 官方博客 [blog.gitee.com](https://blog.gitee.com)
3. 你可以 [https://gitee.com/explore](https://gitee.com/explore) 这个地址来了解 Gitee 上的优秀开源项目
4. [GVP](https://gitee.com/gvp) 全称是 Gitee 最有价值开源项目，是综合评定出的优秀开源项目
5. Gitee 官方提供的使用手册 [https://gitee.com/help](https://gitee.com/help)
6. Gitee 封面人物是一档用来展示 Gitee 会员风采的栏目 [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
