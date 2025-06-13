import {
  BaseReq,
  BaseResp,
  IMediaObject,
  LaunchMiniProgramReq,
  SendAuthReq,
  SendAuthResp,
  SendMessageToWXReq,
  SendReqResultWrap,
  WXApi, WXAPIFactory, WXImageObject, WXMediaMessage,
  WXMiniProgramObject,
  WXTextObject,
  WXWebpageObject } from '@tencent/wechat_open_sdk';
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WXShareEventHandler } from './WXShareEventHandler';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';
import { http } from '@kit.NetworkKit';
import { image } from '@kit.ImageKit';

interface HandlerAction{
  onResp?: (req: BaseResp) => void
  onReq?: (req: BaseReq) => void
}

interface MessageConfig extends HandlerAction{
  title?: string
  description?: string
  thumb?: Resource | string
  shareType?: number

}

interface MiniConfig{
  username: string
  path: string
  /**
   * 小程序的类型，0-正式版 1-开发版 2-体验版，
   * 可不填，不填则默认为0
   */
  miniType?: number
}

interface LoginConfig{
  scope: string
  state?: string
}

interface LoginFace{
  accessToken: string
  expiresIn: number
  refreshToken: string
  openId: string
  scope: string
  unionId?: string
}

class LoginModel implements LoginFace{
  accessToken: string
  expiresIn: number
  refreshToken: string
  openId: string
  scope: string
  unionId?: string
  constructor(args:object) {
    this.accessToken = args['access_token']
    this.expiresIn = args['expires_in']
    this.refreshToken = args['refresh_token']
    this.openId = args['openid']
    this.scope = args['scope']
    this.unionId = args['unionid']
  }
}

interface PayConfig{
  timeStamp: string,
  mchId: string,
  prepayId: string,
  package?: string,
  nonceStr: string,
  sign: string,
}

interface WXFace{
  wxId: string;
  wx?: WXApi;
  secret?: string;
  handleWant?: Want
}

export class WeChat{

  static wxId: string = "wxc4da9d6e527ea9b5";
  static secret: string = "wxc4da9d6e527ea9b5";
  static handleWant?: Want;
  static install:WeChat = new WeChat({wxId:WeChat.wxId});

  private wxId: string;
  private wx: WXApi ;
  private secret: string;
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  private readonly bundleName:string = "com.tencent.mm"

  constructor(face:WXFace) {
    this.wxId = face.wxId;
    this.secret = face.secret ?? WeChat.secret;
    if (face.wx) {
      this.wx =  face.wx;
    }else {
      this.wx = WXAPIFactory.createWXAPI(this.wxId)
    }
    if (face?.handleWant || WeChat.handleWant) {
      this.wx.handleWant(face?.handleWant ?? WeChat.handleWant, WXShareEventHandler)
    }
  }

  isInstall(){
    if (!this.wx.isWXAppInstalled()) {
      AlertDialog.show({
        message:"没有安装微信，请前往华为应用市场安装！",
        confirm:{value:"前往安装",action:()=>{
          let want: Want = {
            action: 'ohos.want.action.appdetail',
            uri: 'store://appgallery.huawei.com/app/detail?id=' + this.bundleName, //  BundleName is the package name of the application that needs to open the application details
          };
          this.context.startAbility(want).then(() => {
            console.info('Start Ability successfully.');
          }).catch((err: BusinessError) => {
            console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
          });
        }},
        cancel:()=>{

        }
      });
      throw Error("没有安装微信，请前往华为应用市场安装！");
    }
  }

  shareText(args:string,message?:MessageConfig){
    const textObject = new WXTextObject()
    textObject.text = args
    this.shareMessage(textObject,message);
  }

  async shareImage(args:string | fileIo.File | ArrayBuffer,message?:MessageConfig){
    if (typeof  args == "string") {
      if (args.startsWith("file")) {
        this.shareImageFile(args,message)
      }else if (args.startsWith("data")){
        this.shareImageBase64(args,message)
      }else if (args.startsWith("http")){
        this.shareImageHttp(args,message)
      }
    }else {
      this.shareImageFile(args,message)
    }
  }

  async shareImageHttp(args:string,message?:MessageConfig){
    let arr:ArrayBuffer = await this.netImg(args)
    this.shareImageFile(arr)
  }

  shareImageBase64(args:string,message?:MessageConfig){
    const imageObject = new WXImageObject()
    let buf: buffer.Buffer = buffer.from(args);
    imageObject.imageData = buf.toString('base64', 0, buf.length);
  }

  shareImageFile(args:string | fileIo.File | ArrayBuffer,message?:MessageConfig){
    const imageObject = new WXImageObject()
    if (typeof args == "string") {
      imageObject.uri = fileUri.getUriFromPath(args);
    }else if ( args instanceof ArrayBuffer) {
      imageObject.uri = fileUri.getUriFromPath(this.createFile(args).path);
    }else {
      imageObject.uri = fileUri.getUriFromPath(args.path);
    }
  }

  shareWeb(args:string,message?:MessageConfig){
    const webpageObject = new WXWebpageObject()
    webpageObject.webpageUrl = args
    this.shareMessage(webpageObject,message);
  }

  shareMini(args:MiniConfig,message?:MessageConfig){
    const miniProgramObject = new WXMiniProgramObject()
    miniProgramObject.userName = args.username
    miniProgramObject.path = args.path
    miniProgramObject.miniprogramType = args.miniType
    this.shareMessage(miniProgramObject,message);
  }

  async shareMessage(object:IMediaObject,message:MessageConfig = {}): Promise<SendReqResultWrap>{
    let mediaMessage = new WXMediaMessage()
    mediaMessage.mediaObject = object
    mediaMessage.title = message.title
    mediaMessage.description = message.description
    if (message.thumb){
      mediaMessage.thumbData = new Uint8Array(await this.createThumb(message.thumb))
    }
    if (message.shareType && message.shareType == SendMessageToWXReq.WXSceneTimeline) {
      return this.shareCommon(mediaMessage,{onResp:message.onResp,onReq:message.onReq});
    }else {
      return this.shareFriend(mediaMessage,{onResp:message.onResp,onReq:message.onReq});
    }
  }

  shareType(shareType:number,message:WXMediaMessage,handler?:HandlerAction):SendReqResultWrap{
    this.isInstall();
    if (handler && handler.onResp) {
      WXShareEventHandler.registerOnWXRespCallback(handler.onResp)
    }
    if (handler && handler.onReq) {
      WXShareEventHandler.registerOnWXReqCallback(handler.onReq)
    }
    let req = new SendMessageToWXReq()
    req.scene = shareType
    req.message = message
    return this.wx.sendReq(getContext(this) as common.UIAbilityContext,req)
  }

  shareFriend(message:WXMediaMessage,handler?:HandlerAction):SendReqResultWrap{
    return this.shareType(SendMessageToWXReq.WXSceneSession,message,handler);
  }

  shareCommon(message:WXMediaMessage,handler?:HandlerAction):SendReqResultWrap{
    return this.shareType(SendMessageToWXReq.WXSceneTimeline,message,handler);
  }

  openMini(args:MiniConfig,handler?:HandlerAction):SendReqResultWrap{
    this.isInstall();
    if (handler && handler.onResp) {
      WXShareEventHandler.registerOnWXRespCallback(handler.onResp)
    }
    if (handler && handler.onReq) {
      WXShareEventHandler.registerOnWXReqCallback(handler.onReq)
    }
    const req = new LaunchMiniProgramReq();
    req.userName = args.username;
    req.path = args.path;
    req.miniprogramType = args.miniType;
    return this.wx.sendReq(getContext(this) as common.UIAbilityContext, req);
  }

  private  openServiceChat(){
    // String url = kfUrl.getText().toString();
    // WXOpenCustomerServiceChat.Req req = new WXOpenCustomerServiceChat.Req();
    // req.corpId = "xxxx";							      // 企业ID
    // req.url = "https://work.weixin.qq.com/kfid/kfcxxxxx";	// 客服URL
    // api.sendReq(req);
  }

  openWX(args:string,handler?:HandlerAction): Promise<void>{
    this.isInstall();
    if (handler && handler.onResp) {
      WXShareEventHandler.registerOnWXRespCallback(handler.onResp)
    }
    if (handler && handler.onReq) {
      WXShareEventHandler.registerOnWXReqCallback(handler.onReq)
    }
    let ctx = getContext(this) as common.UIAbilityContext
    let want:Want = {
      uri:args,
      action: "ohos.want.action.viewData"
    }
    return ctx.startAbility(want);
  }

  miniPay(args:MiniConfig,handler?:HandlerAction){
    this.openMini(args,handler)
  }

  pay(args:PayConfig,handler?:HandlerAction){
    if (args.package == undefined) {
      args.package = 'Sign=WXPay'
    }
    // this.wx.miniapp.requestPayment({
    //   timeStamp: '1667792176',
    //   mchId: '1800009365',
    //   prepayId: 'wx07113616363804b19dde94884922030000',
    //   package: 'Sign=WXPay',
    //   nonceStr: '8ne443gjxxg',
    //   sign: '4FF5900870B5C5BCB089789BC004156426C46512CE566DB17C131747E09ADEBA',
    //   success: (res) => {
    //     console.warn('wx.miniapp.requestPayment success:', res)
    //   },
    //   fail: (res) => {
    //     console.error('wx.miniapp.requestPayment res:', res)
    //   },
    //   complete: (res) => {
    //     console.error('wx.miniapp.requestPayment res:', res)
    //   }
    // })

  }

  async login(args:LoginConfig,onResp:(req: LoginFace) => void): Promise<SendReqResultWrap>{
    if (await this.hasAccessToken("accessToken","openid")){
      this.refreshToken("refreshToken").then((v)=>{
        onResp(v);
      });
      return true;
    }else {
      return this.sendAuth(args,{onResp:(resp)=>{
        let r = new SendAuthResp();
        r.deserializeFrom(resp);
        if (r.code) {
          this.accessToken(r.code).then((v)=>{
            onResp(v);
          });
        }
      }})
    }
  }

  private sendAuth(args:LoginConfig,handler?:HandlerAction):SendReqResultWrap{
    this.isInstall();
    if (handler && handler.onResp) {
      WXShareEventHandler.registerOnWXRespCallback(handler.onResp)
    }
    if (handler && handler.onReq) {
      WXShareEventHandler.registerOnWXReqCallback(handler.onReq)
    }
    let req = new SendAuthReq();
    req.scope = args.scope;
    req.state = args.state;
    return this.wx.sendReq(getContext(this) as common.UIAbilityContext, req);
  }

  async hasAccessToken(accessToken:string,openid:string):Promise<boolean>{
    const accessUrl:string = `https://api.weixin.qq.com/sns/auth?access_token=${accessToken}&openid=${openid}`;
    return new Promise<boolean>((res,rej)=>{
      this.netUrl(accessUrl).catch((e:object)=>{
        if (e && e['errcode'] == 0) {
          res(true)
        }else {
          rej(false)
        }
      })
    });
  }

  async accessToken(code:string){
    const accessUrl:string = `https://api.weixin.qq.com/sns/oauth2/access_token?appid=${this.wxId}&secret=${this.secret}&code=${code}&grant_type=authorization_code`;
    return this.netUrl(accessUrl);
  }

  async refreshToken(refreshToken:string){
    const refreshUrl:string = `https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=${this.wxId}&grant_type=refresh_token&refresh_token=${refreshToken}`
    return this.netUrl(refreshUrl)
  }

  private createThumb(args:Resource | string):Promise<ArrayBuffer>{
    if (typeof args == "string") {
      return this.netImg(args)
    }else {
      const thumbData = getContext(this).resourceManager.getMediaContentSync(args)
      const thumbPixel = image.createImageSource(thumbData.buffer).createPixelMapSync()
      return image.createImagePacker().packToData(thumbPixel, { format: "image/png", quality: 100 })
    }
  }

  private createFile(arr:ArrayBuffer):fileIo.File{
    let context = getContext() as common.UIAbilityContext;
    let filePath = context.filesDir + `/original-${Date.now()}.jpg`;
    let file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.writeSync(file.fd, arr);
    fileIo.closeSync(file);
    return file
  }

  private async netUrl(url:string):Promise<LoginFace>{
    return new Promise<LoginFace>((res,rej)=>{
      let httpRequest = http.createHttp();
      httpRequest.request(
        url,{
        expectDataType:http.HttpDataType.OBJECT
      },
        (error, data) => {
          if (error) {
            rej(error)
            console.log("error code: " + error.code + ", msg: " + error.message)
          } else {
            if (200 == data.responseCode && data.result["openid"]) {
              res(data.result as LoginFace)
            } else {
              rej(data.result)
              console.log("error: " + data.result.toString())
            }
          }
        }
      )
    });
  }

  private async netImg(url:string):Promise<ArrayBuffer>{
    return new Promise((res,rej)=>{
      let httpRequest = http.createHttp();
      httpRequest.request(
        url,{
        expectDataType:http.HttpDataType.ARRAY_BUFFER
      },
        (error, data) => {
          if (error) {
            rej(error)
            console.log("error code: " + error.code + ", msg: " + error.message)
          } else {
            if (200 == data.responseCode && data.result instanceof ArrayBuffer) {
              res(data.result)
            } else {
              //通过获取到的uri创建图片源实例。
              if (typeof data.result == "string") {
                rej("不支持string类型的图像数据处理")
                console.log("不支持string类型的图像数据处理");
              }else{
                rej("response code: " + data.responseCode)
                console.log("response code: " + data.responseCode);
              }
            }
          }
        }
      )
    });
  }
}

//
// WXUtil.install.shareText("",{onResp:()=>{}})
// WXUtil.install.shareImage("",{onResp:()=>{}})
// WXUtil.install.shareWeb("",{onResp:()=>{}})
// WXUtil.install.shareMini({username:"",path:""},{onResp:()=>{}})
//
// WXUtil.install.openMini({username:"",path:""},{onResp:()=>{}})
// WXUtil.install.openWX("",{onResp:()=>{}})
//
// WXUtil.install.miniPay({username:"",path:""},{onResp:()=>{}})
// WXUtil.install.login({ scope: '' },(LoginFace)=>{})
// WXUtil.install.pay({});