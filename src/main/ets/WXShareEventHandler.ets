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