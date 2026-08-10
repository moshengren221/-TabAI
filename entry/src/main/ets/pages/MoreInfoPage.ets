import { router } from '@kit.ArkUI'
import { ChatSession } from '../model/ChatSession'
import { PreferencesUtil } from '../common/PreferencesUtil'
import { Constants } from '../common/Constants'

interface RouterParams {
  sessionId: string
}

@Entry
@Component
struct MoreInfoPage {
  @State modelName: string = ''
  @State apiUrl: string = ''
  @State apiKey: string = ''
  @State apiCallCount: number = 0
  private sessionId: string = ''
  private safeTop: number = AppStorage.get<number>('safeTop') ?? 0

  @Builder
  InfoRow(
    icon: Resource,
    iconBg: string,
    title: string,
    value: string,
    showArrow: boolean = false,
    onClick: () => void = () => {}
  ) {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        SymbolGlyph(icon)
          .fontSize(17)
          .fontColor(['#FFFFFF'])
      }
      .width(30).height(30)
      .borderRadius(8)
      .backgroundColor(iconBg)

      Blank().width(12)

      Text(title)
        .fontSize(16)
        .fontColor('#000000')
        .maxLines(1)

      Text(value)
        .fontSize(14)
        .fontColor('#999999')
        .layoutWeight(1)
        .textAlign(TextAlign.End)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (showArrow) {
        SymbolGlyph($r('sys.symbol.chevron_forward'))
          .fontSize(14)
          .fontColor(['#C0C0C0'])
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .height(54)
    .padding({ left: 16, right: 16 })
    .onClick(() => onClick())
  }

  @Builder
  InfoDivider() {
    Divider()
      .color('#F0F0F0')
      .margin({ left: 58, right: 0 })
  }

  async aboutToAppear(): Promise<void> {
    try {
      const params: RouterParams = router.getParams() as RouterParams
      this.sessionId = params.sessionId || ''
      await this.loadSession()
    } catch (e) {
      console.error('aboutToAppear failed:', JSON.stringify(e))
    }
  }

  private async loadSession(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      const json: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
      const sessions: ChatSession[] = JSON.parse(json) as ChatSession[]
      const session: ChatSession | undefined = sessions.find((s: ChatSession) => s.id === this.sessionId)
      if (session) {
        this.modelName = session.modelName || '未配置'
        this.apiUrl = session.apiUrl || '未配置'
        this.apiKey = session.apiKey ? '••••••••' : '未配置'
        this.apiCallCount = session.apiCallCount || 0
      }
    } catch (e) {
      console.error('Load more info failed:', JSON.stringify(e))
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize(24).fontColor(['#000000'])
        }
        .type(ButtonType.Circle).backgroundColor('transparent')
        .width(40).height(40)
        .onClick(() => router.back())

        Text('更多信息')
          .fontSize(20).fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Row().width(40)
      }
      .width('100%')
      .height(56 + this.safeTop)
      .padding({ left: 12, right: 12, top: this.safeTop })
      .backgroundColor('#F5F5F5')

      List({ space: 12 }) {
        // 配置信息卡片
        ListItem() {
          Column() {
            this.InfoRow(
              $r('sys.symbol.gearshape_fill'),
              '#007AFF',
              '模型名称',
              this.modelName
            )

            this.InfoDivider()

            this.InfoRow(
              $r('sys.symbol.link'),
              '#FF9500',
              'API 地址',
              this.apiUrl
            )

            this.InfoDivider()

            this.InfoRow(
              $r('sys.symbol.lock_fill'),
              '#34C759',
              'API 密钥',
              this.apiKey
            )
          }
          .width('100%')
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .clip(true)
        }
        .padding({ left: 16, right: 16 })

        // 调用统计卡片
        ListItem() {
          Column() {
            this.InfoRow(
              $r('sys.symbol.list_bullet'),
              '#5856D6',
              'API 调用次数',
              `${this.apiCallCount}次`
            )
          }
          .width('100%')
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .clip(true)
        }
        .padding({ left: 16, right: 16 })

        // 底部提示
        ListItem() {
          Text('调用次数为本联系人发送消息后成功调用 API 的总次数')
            .fontSize(13)
            .fontColor('#999999')
            .padding({ left: 16, right: 16 })
        }

        // 底部留白
        ListItem().height(20)
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F5F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}