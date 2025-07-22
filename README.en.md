# wechat

#### Description [中文](README.md)

This is a library based on the Hongmeng version, which is a simplified and encapsulated version of the WeChat third-party functions. It enables sharing of text, sharing of images, share the webpage, sharing of mini-programs, opening of mini-programs, and opening of WeChat.
#### Software Architecture 

This is the Hongmeng version based on the WeChat Open Platform
#### Installation

`ohpm install @free/wechat`

#### Instructions


1、Initialization, configuration of wxId and handle listening methods
```
WeChat.install.setConfig({wxId:"wxc4daXXXXXXXXXXX",handleWant:want});
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

9、WeChat authorization
```
WeChat.install.sendAuth({scope:"snsapi_userinfo",state:"session"},"path",{onResp:(resp)=>{}})
```

#### Plugin Details

Hello, dear students! Good morning!
Today, we are going to talk about the third-party libraries of the WeChat Open Platform.
I believe that many of you have encountered various problems during the development process.
Today, I will help you all clear up the problems with the WeChat third-party platform SDK.

##### 1、First, according to the requirements of the [WeChat Open Platform](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/guideline/create.html), create the configuration for your own HarmonyOS application.

##### 2、Secondly, when using the SDK of third-party platforms, we must first import the third-party libraries.

1、The method of introducing third-party libraries in WeChat

```
ohpm install @tencent/wechat_open_sdk
```

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtybbs/137/390/427/0080086000137390427.20250616112712.00572031913445407208392366538278:50001231000000:2800:40ACEB5775B272D1833A573E764162749B5FD1567D077B76645355E0B4370E71.png)

2、Check if WeChat is installed, and then add the following declaration in module.json5 "weixin""wxopensdk"

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtybbs/137/390/427/0080086000137390427.20250616140240.78133600179037207983460973292330:50001231000000:2800:B8D3B296E6572DCA2639EC350CE62E8A6CC465D78A456E4C40693C7DB179F442.png)

3、Configuration and the action agreed upon with WeChat: **wxentity.action.open**

![](https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtybbs/137/390/427/0080086000137390427.20250616140249.16453585133086318173980262063612:50001231000000:2800:6CB72A460E10AAB75FA97C3B9844D76ADEDA28BA0D9D42067387709E1AE7E40C.png)

##### 3、Implement the related functions of WeChat

1、Initialization (requires WeChat app ID)

```arkts
// WeChat ID 
private wxId: string = "wxXXXXXXXXXappid";
// Instantiate the WeChat object 
private wx: WXApi = WXAPIFactory.createWXAPI(this.wxId)
// Application Context
private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
```

2、WeChat message monitoring


```arkts
// Initialization 
this.wx.handleWant(appWant, WXShareEventHandler)
// Register the Resp event WXShareEventHandler.registerOnWXRespCallback(handler.onResp)
// Cancel Resp event WXShareEventHandler.unregisterOnWXRespCallback(handler.onResp)
// Registration Request Event WXShareEventHandler.registerOnWXReqCallback(handler.onReq)
// Logout Req event
WXShareEventHandler.unregisterOnWXReqCallback(handler.onReq)

```

Add the listening code file

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

3、WeChat Sharing

Key point: Package the shared fixed elements into the "shareType" method

Parameter 1: shareType - Sharing Type

0: SendMessageToWXReq.WXSceneSession (Friend)

SendMessageToWXReq.WXSceneTimeline (Friend Circle)

Parameter 2: object: Sharing object

textObject: Sharing Content Object

imageObject: Sharing Image Object

webpageObject: Webpage Sharing Object

miniProgramObject: Mini Program Sharing Object

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

Copywriting Share
```arkts 
const textObject = new WXTextObject()
textObject.text = args
this.shareType(0,textObject)
```

Image sharing
```arkts 
const imageObject = new WXImageObject()
imageObject.uri = fileUri.getUriFromPath("file://path");
this.shareType(0,imageObject)
```

Webpage sharing
```arkts 
const webpageObject = new WXWebpageObject("https://xxxxxxx")
webpageObject.webpageUrl = args
this.shareType(0,webpageObject)
```

Mini-program sharing
```arkts 
const miniProgramObject = new WXMiniProgramObject()
miniProgramObject.userName = "username"
miniProgramObject.path = "path"
this.shareType(0,miniProgramObject)
```

4、Launch the WeChat mini-program from the app.

```arkts 
const req = new LaunchMiniProgramReq()
req.userName = "username"
req.path = "path"
this.wx.sendReq(this.context,req)
```

5、Tap to open WeChat

```arkts 
let ctx = getContext(this) as common.UIAbilityContext
let want:Want = {
    uri:"uri",
    action: "ohos.want.action.viewData"
}
ctx.startAbility(want);
```

Note: The complete code has been submitted to the [HarmonyOS Third-Party Library](https://ohpm.openharmony.cn/). Please use the following command to install it.

```
ohpm install @free/wechat
```

Calling method

```arkts 
// Share Content
WeChat.install.shareText("text",{onResp:(resp)=>{}})
// Share the picture
WeChat.install.shareImage("https://xxx",{onResp:(resp)=>{}})
// Share the webpage
WeChat.install.shareWeb("https://xxx",{onResp:(resp)=>{}})
// Share Mini Program
WeChat.install.shareMini({username:"username",path:"path"},{onResp:(resp)=>{}})
// Open the WeChat mini-program
WeChat.install.openMini({username:"username",path:"path"},{onResp:(resp)=>{}})
// Open WeChat
WeChat.install.openWX("uri",{onResp:(resp)=>{}})
```

If you like this content, please give a little heart!


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
