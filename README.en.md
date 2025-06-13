# wechat

#### Description [中文](README.md)

This is a library based on the Hongmeng version, which is a simplified and encapsulated version of the WeChat third-party functions. It enables sharing of text, sharing of images, sharing of mini-programs, opening of mini-programs, and opening of WeChat.
#### Software Architecture 

This is the Hongmeng version based on the WeChat Open Platform
#### Installation

`ohpm install @free/wechat`

#### Instructions


1、Initialization, configuration of wxId and handle listening methods
```
WXUtil.wxId = "wxc4da9d6e527ea9b5";
WXUtil.handleWant = baseWant;
```

2、Configure basic sharing settings (optional)
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

3、Share the text
```
WeChat.install.shareText("text",{onResp:(resp)=>{}})
```

4、Share the image
```
WeChat.install.shareImage("https://img.ixintu.com/download/jpg/201911/e25b904bc42a74d7d77aed81e66d772c.jpg!con",{onResp:(resp)=>{}})
```

5、Share the web
```
WeChat.install.shareWeb("https://developer.huawei.com/consumer/cn/",{onResp:(resp)=>{}})
```

6、Share Mini Program
```
WeChat.install.shareMini("username","path",{onResp:(resp)=>{}})
```

7、Open WeChat
```
WeChat.install.openWX("weixin://dl/business/?t=YODfF8dNclo",{onResp:(resp)=>{}})
```

8、Open the mini program
```
WeChat.install.openMini("username","path",{onResp:(resp)=>{}})
```


#### Contribution

1.  Fork the repository
2.  Create Feat_xxx branch
3.  Commit your code
4.  Create Pull Request


#### Gitee Feature

1.  You can use Readme\_XXX.md to support different languages, such as Readme\_en.md, Readme\_zh.md
2.  Gitee blog [blog.gitee.com](https://blog.gitee.com)
3.  Explore open source project [https://gitee.com/explore](https://gitee.com/explore)
4.  The most valuable open source project [GVP](https://gitee.com/gvp)
5.  The manual of Gitee [https://gitee.com/help](https://gitee.com/help)
6.  The most popular members  [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
