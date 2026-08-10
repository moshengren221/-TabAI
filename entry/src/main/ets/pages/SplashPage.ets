import { router } from '@kit.ArkUI'

@Entry
@Component
struct SplashPage {
  private timer: number = -1

  aboutToAppear() {
    this.timer = setTimeout(() => {
      const r = this.getUIContext().getRouter()
      r.replaceUrl({ url: 'pages/ChatPage' })
    }, 1500)
  }

  aboutToDisappear() {
    clearTimeout(this.timer)
  }

  build() {
    Column() {
      Text('智识TabAI')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007DFF')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
  }
}