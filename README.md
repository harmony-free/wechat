# wechat

#### 介绍 [English](README.en.md)

这是鸿蒙版本基于微信第三方简化封装的库，分享文字、分享图片、分享网页、分享小程序、打开小程序、打开微信

#### 软件架构

这是鸿蒙版本基于微信开放平台

#### 安装教程

`ohpm install @free/wechat`

#### 使用说明

注意：必须要保证AGC签名和微信上保持一致

1、初始化，配置wxId以及handle监听方法
```
WeChat.install.setConfig({wxId:"wxc4daXXXXXXXXXXX",handleWant:want});
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
WeChat.install.shareMini({username:"username",path:"path"},{onResp:(resp)=>{}})
```
7、打开微信
```
WeChat.install.openWX("weixin://dl/business/?t=YODfF8dNclo",{onResp:(resp)=>{}})
```
8、打开小程序
```
WeChat.install.openMini({username:"username",path:"path"},"path",{onResp:(resp)=>{}})
```

9、微信授权
```
WeChat.install.sendAuth({scope:"snsapi_userinfo",state:"session"},"path",{onResp:(resp)=>{}})
```

#### 插件明细

hello 各位同学，大家好！
今天我们来讲讲微信开放平台的三方库
相信很多同学在开发的时候都会遇到各种各样的坑
今天我就来帮各位同学排排微信三方平台SDK的坑

一、首先根据[微信开放平台](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/guideline/create.html)要求创建配置自己的鸿蒙应用

二、其次我们在使用第三方平台SDK的时候都要先引入三方库

1、微信引入三方库的方式
```
ohpm install @tencent/wechat_open_sdk
```

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtybbs/137/390/427/0080086000137390427.20250616112712.00572031913445407208392366538278:50001231000000:2800:40ACEB5775B272D1833A573E764162749B5FD1567D077B76645355E0B4370E71.png)

2、检测微信是否已安装，再 module.json5 里加入下方声明
"weixin""wxopensdk"

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtybbs/137/390/427/0080086000137390427.20250616140240.78133600179037207983460973292330:50001231000000:2800:B8D3B296E6572DCA2639EC350CE62E8A6CC465D78A456E4C40693C7DB179F442.png)

3、配置和微信约定的action **wxentity.action.open**

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtybbs/137/390/427/0080086000137390427.20250616140249.16453585133086318173980262063612:50001231000000:2800:6CB72A460E10AAB75FA97C3B9844D76ADEDA28BA0D9D42067387709E1AE7E40C.png)

三、实现微信相关功能

1、初始化（需要微信appid）

```arkts
// 微信id
private wxId: string = "wxXXXXXXXXXappid";
// 微信实例化对象
private wx: WXApi = WXAPIFactory.createWXAPI(this.wxId)
// 应用上下文
private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
```

2、微信消息监听


```arkts
// 初始化
this.wx.handleWant(appWant, WXShareEventHandler)
// 注册Resp事件
WXShareEventHandler.registerOnWXRespCallback(handler.onResp)
// 注销Resp事件
WXShareEventHandler.unregisterOnWXRespCallback(handler.onResp)
// 注册Req事件
WXShareEventHandler.registerOnWXReqCallback(handler.onReq)
// 注销Req事件
WXShareEventHandler.unregisterOnWXReqCallback(handler.onReq)

```

添加监听代码文件
```arkts
import { BaseReq, BaseResp, Log, WXApiEventHandler } from "@tencent/wechat_open_sdk"

const kTag = "SharePluginWXApiEventHandlerImpl"

export type OnWXReq = (req: BaseReq) => void

export type OnWXResp = (resp: BaseResp) => void

class WXApiEventHandlerImpl implements WXApiEventHandler {
  private onReqCallbacks: Map<OnWXReq, OnWXReq> = new Map
  private onRespCallbacks: Map<OnWXResp, OnWXResp> = new Map

  registerOnWXReqCallback(on: OnWXReq) {
    this.onReqCallbacks.set(on, on)
  }
  unregisterOnWXReqCallback(on: OnWXReq) {
    this.onReqCallbacks.delete(on)
  }

  registerOnWXRespCallback(on: OnWXResp) {
    this.onRespCallbacks.set(on, on)
  }
  unregisterOnWXRespCallback(on: OnWXResp) {
    this.onRespCallbacks.delete(on)
  }

  onReq(req: BaseReq): void {
    Log.i(kTag, "onReq:%s", JSON.stringify(req))
    this.onReqCallbacks.forEach((on) => {
      on(req)
    })
  }

  onResp(resp: BaseResp): void {
    Log.i(kTag, "onResp:%s", JSON.stringify(resp))
    this.onRespCallbacks.forEach((on) => {
      on(resp)
    })
  }
}
export const WXShareEventHandler = new WXApiEventHandlerImpl
```

3、微信分享

重点：把分享固定的要素封装 shareType 方法

参数1：shareType 分享类型

0：SendMessageToWXReq.WXSceneSession （好友）

1: SendMessageToWXReq.WXSceneTimeline （朋友圈）

参数2：object：分享对象

textObject：分享文案对象

imageObject：分享图片对象

webpageObject：网页分享对象

miniProgramObject：小程序分享对象

```arkts 
shareType(shareType:number,object:WXMediaMessage,handler?:HandlerAction):SendReqResultWrap{
    let req = new SendMessageToWXReq()
    req.scene = shareType
    
    let mediaMessage = new WXMediaMessage()
    mediaMessage.mediaObject = object
    mediaMessage.title = message.title
    mediaMessage.description = message.description
    
    req.message = message
    
    this.wx.sendReq(this.context,req)
}

```

文案分享
```arkts 
const textObject = new WXTextObject()
textObject.text = args
this.shareType(0,textObject)
```

图片分享
```arkts 
const imageObject = new WXImageObject()
imageObject.uri = fileUri.getUriFromPath("file://path");
this.shareType(0,imageObject)
```

网页分享
```arkts 
const webpageObject = new WXWebpageObject("https://xxxxxxx")
webpageObject.webpageUrl = args
this.shareType(0,webpageObject)
```

小程序分享
```arkts 
const miniProgramObject = new WXMiniProgramObject()
miniProgramObject.userName = "username"
miniProgramObject.path = "path"
this.shareType(0,miniProgramObject)
```

4、app拉起微信小程序

```arkts 
const req = new LaunchMiniProgramReq()
req.userName = "username"
req.path = "path"
this.wx.sendReq(this.context,req)
```

5、app拉起微信

```arkts 
let ctx = getContext(this) as common.UIAbilityContext
let want:Want = {
    uri:"uri",
    action: "ohos.want.action.viewData"
}
ctx.startAbility(want);
```

注意：完整代码我已提交到[鸿蒙三方库中](https://ohpm.openharmony.cn/)，使用一下命令安装

```
ohpm install @free/wechat
```
调用方式
```arkts 
// 分享文案
WeChat.install.shareText("text",{onResp:(resp)=>{}})
// 分享图片
WeChat.install.shareImage("https://xxx",{onResp:(resp)=>{}})
// 分享网页
WeChat.install.shareWeb("https://xxx",{onResp:(resp)=>{}})
// 分享小程序
WeChat.install.shareMini({username:"username",path:"path"},{onResp:(resp)=>{}})
// 打开微信小程序
WeChat.install.openMini({username:"username",path:"path"},{onResp:(resp)=>{}})
// 打开微信
WeChat.install.openWX("uri",{onResp:(resp)=>{}})
```

喜欢本篇内容的话给个小爱心！


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
