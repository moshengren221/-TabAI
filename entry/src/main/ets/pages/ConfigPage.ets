import { router } from '@kit.ArkUI'
import { PreferencesUtil } from '../common/PreferencesUtil'
import { Constants } from '../common/Constants'
import { ChatSession } from '../model/ChatSession'

@Entry
@Component
struct ConfigPage {
  @State modelName: string = ''
  @State apiUrl: string = ''
  @State apiKey: string = ''
  @State systemPrompt: string = 'You are a helpful assistant.'
  private sessionId: string = ''
  private isNewContact: boolean = false
  private safeTop: number = AppStorage.get<number>('safeTop') ?? 0

  async aboutToAppear(): Promise<void> {
    const params: Record<string, string> = router.getParams() as Record<string, string>
    this.sessionId = params['sessionId'] || ''
    this.isNewContact = params['isNewContact'] === 'true'

    if (this.sessionId) {
      try {
        const ctx: Context = getContext(this)
        const json: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
        const sessions: ChatSession[] = JSON.parse(json) as ChatSession[]
        const session: ChatSession | undefined = sessions.find((s: ChatSession) => s.id === this.sessionId)
        if (session) {
          this.modelName = session.modelName || ''
          this.apiUrl = session.apiUrl || ''
          this.apiKey = session.apiKey || ''
          this.systemPrompt = session.systemPrompt || 'You are a helpful assistant.'
        }
      } catch (e) {
        console.error('Load session config failed:', JSON.stringify(e))
      }
    }
  }

  private async save(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      const json: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
      const sessions: ChatSession[] = JSON.parse(json) as ChatSession[]
      const idx: number = sessions.findIndex((s: ChatSession) => s.id === this.sessionId)
      if (idx >= 0) {
        sessions[idx].modelName = this.modelName
        sessions[idx].apiUrl = this.apiUrl
        sessions[idx].apiKey = this.apiKey
        sessions[idx].systemPrompt = this.systemPrompt
        await PreferencesUtil.getInstance().put(ctx, Constants.PREF_SESSIONS, 'list', JSON.stringify(sessions))
      }
    } catch (e) {
      console.error('Save session config failed:', JSON.stringify(e))
    }

    if (this.isNewContact) {
      router.replaceUrl({
        url: 'pages/ChatDetailPage',
        params: { sessionId: this.sessionId }
      })
    } else {
      router.replaceUrl({ url: 'pages/ChatPage' })
    }
  }

  private goBack(): void {
    router.replaceUrl({ url: 'pages/ChatPage' })
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize(24)
            .fontColor(['#333333'])
        }
        .type(ButtonType.Circle)
        .backgroundColor('transparent')
        .width(40)
        .height(40)
        .onClick(() => this.goBack())

        Text('API配置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('保存')
          .fontSize(16)
          .fontColor('#007DFF')
          .backgroundColor('transparent')
          .onClick(() => this.save())
      }
      .width('100%')
      .height(56 + this.safeTop)
      .padding({ left: 12, right: 12, top: this.safeTop })
      .backgroundBlurStyle(BlurStyle.Regular)
      .backdropBlur(20)
      .position({ x: 0, y: 0 })
      .zIndex(100)

      // 表单
      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 6 }) {
            Text('模型名称')
              .fontSize(14)
              .fontColor('#666666')
            TextInput({ text: $$this.modelName, placeholder: '如: gpt-4o' })
              .height(48)
              .backgroundColor('#F5F5F5')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          Column({ space: 6 }) {
            Text('API地址')
              .fontSize(14)
              .fontColor('#666666')
            TextInput({ text: $$this.apiUrl, placeholder: '如: https://api.openai.com' })
              .height(48)
              .backgroundColor('#F5F5F5')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          Column({ space: 6 }) {
            Text('API密钥')
              .fontSize(14)
              .fontColor('#666666')
            TextInput({ text: $$this.apiKey, placeholder: '输入API Key' })
              .height(48)
              .backgroundColor('#F5F5F5')
              .type(InputType.Password)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          Column({ space: 6 }) {
            Text('系统提示词')
              .fontSize(14)
              .fontColor('#666666')
            TextArea({ text: $$this.systemPrompt })
              .height(120)
              .backgroundColor('#F5F5F5')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
      .padding({ top: 56 + this.safeTop })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}