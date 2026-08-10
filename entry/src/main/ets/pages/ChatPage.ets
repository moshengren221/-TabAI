import { router, promptAction } from '@kit.ArkUI'
import { ChatSession } from '../model/ChatSession'
import { PreferencesUtil } from '../common/PreferencesUtil'
import { Constants } from '../common/Constants'
import { common } from '@kit.AbilityKit'

@Component
struct ContactItem {
  @Prop sessionId: string = ''
  @Prop title: string = ''
  @Prop lastMessage: string = ''
  @Prop updateTime: number = Date.now()
  @Prop isTop: boolean = false
  @Prop isBlacklisted: boolean = false
  @Prop customAvatar: string = ''

  private formatTime(ts: number): string {
    const d: Date = new Date(ts)
    const month: string = (d.getMonth() + 1).toString().padStart(2, '0')
    const day: string = d.getDate().toString().padStart(2, '0')
    const hours: string = d.getHours().toString().padStart(2, '0')
    const minutes: string = d.getMinutes().toString().padStart(2, '0')
    return `${month}/${day} ${hours}:${minutes}`
  }

  build() {
    Row({ space: 12 }) {
      if (this.customAvatar && this.customAvatar.length > 0) {
        Image(this.customAvatar)
          .width(44).height(44).borderRadius(10)
          .objectFit(ImageFit.Cover)
          .opacity(this.isBlacklisted ? 0.5 : 1)
      } else {
        Image($r('app.media.touxiang'))
          .width(44).height(44).borderRadius(10)
          .objectFit(ImageFit.Cover)
          .opacity(this.isBlacklisted ? 0.5 : 1)
      }

      Column({ space: 4 }) {
        Row({ space: 6 }) {
          if (this.isTop) {
            Text('置顶')
              .fontSize(10)
              .fontColor('#007AFF')
              .backgroundColor('#E8F0FE')
              .borderRadius(4)
              .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          }
          if (this.isBlacklisted) {
            Text('黑名单')
              .fontSize(10)
              .fontColor('#FF4444')
              .backgroundColor('#FFEBEE')
              .borderRadius(4)
              .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          }
          Text(this.title || '未命名')
            .fontSize(16)
            .fontColor(this.isBlacklisted ? '#999999' : '#000000')
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')

        Text(this.lastMessage || '暂无消息')
          .fontSize(13).fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.formatTime(this.updateTime))
        .fontSize(11).fontColor('#BBBBBB')
    }
    .width('100%')
    .height(70)
    .padding({ left: 16, right: 16 })
  }
}

@Entry
@Component
struct ChatPage {
  @State private allSessions: ChatSession[] = []
  @State private isRefreshing: boolean = false
  @State private showAgreement: boolean = false
  @StorageLink('safeTop') safeTop: number = 0

  @Builder
  SessionDivider() {
    Divider()
      .color('#F0F0F0')
      .margin({ left: 72, right: 16 })
  }

  async aboutToAppear(): Promise<void> {
    await this.loadAllSessions()
    await this.checkAgreement()
  }

  onPageShow(): void {
    this.loadAllSessions()
  }

  private async checkAgreement(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      const agreed: string = await PreferencesUtil.getInstance().get(ctx, 'app_settings', 'agreed_privacy', 'false') as string
      if (agreed !== 'true') {
        this.showAgreement = true
      }
    } catch (e) {
      this.showAgreement = true
    }
  }

  private async agreePrivacy(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      await PreferencesUtil.getInstance().put(ctx, 'app_settings', 'agreed_privacy', 'true')
      this.showAgreement = false
    } catch (e) {
      console.error('保存同意状态失败:', JSON.stringify(e))
    }
  }

  private disagreeAndExit(): void {
    try {
      const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
      ctx.terminateSelf()
    } catch (e) {
      console.error('退出失败:', JSON.stringify(e))
    }
  }

  private async loadAllSessions(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      const json: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
      let list: ChatSession[] = JSON.parse(json) as ChatSession[]

      list.forEach((s: ChatSession) => {
        if (s.isTop === undefined) s.isTop = false
        if (s.isBlacklisted === undefined) s.isBlacklisted = false
        if (s.lastMessage === undefined) s.lastMessage = ''
        if (s.modelName === undefined) s.modelName = ''
        if (s.apiUrl === undefined) s.apiUrl = ''
        if (s.apiKey === undefined) s.apiKey = ''
        if (s.systemPrompt === undefined) s.systemPrompt = 'You are a helpful assistant.'
        if (s.customAvatar === undefined) s.customAvatar = ''
        if (s.apiCallCount === undefined) s.apiCallCount = 0
        if (s.showThinking === undefined) s.showThinking = false
        if (s.chatBgUri === undefined) s.chatBgUri = ''
        if (s.bgBlur === undefined) s.bgBlur = 0
      })

      list.sort((a: ChatSession, b: ChatSession) => {
        if (a.isTop && !b.isTop) return -1
        if (!a.isTop && b.isTop) return 1
        return b.updateTime - a.updateTime
      })

      this.allSessions = list
    } catch (e) {
      console.error('加载会话失败:', e)
      this.allSessions = []
    }
  }

  private async saveSessions(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      await PreferencesUtil.getInstance().put(ctx, Constants.PREF_SESSIONS, 'list', JSON.stringify(this.allSessions))
    } catch (e) {
      console.error('保存会话失败:', e)
    }
  }

  private async onRefresh(): Promise<void> {
    this.isRefreshing = true
    await this.loadAllSessions()
    setTimeout(() => {
      this.isRefreshing = false
      promptAction.showToast({ message: '已刷新', duration: 1000 })
    }, 500)
  }

  private async deleteSession(id: string): Promise<void> {
    this.allSessions = this.allSessions.filter((s: ChatSession) => s.id !== id)
    await this.saveSessions()
    promptAction.showToast({ message: '已删除', duration: 1500 })
  }

  private async toggleTop(id: string): Promise<void> {
    const idx: number = this.allSessions.findIndex((s: ChatSession) => s.id === id)
    if (idx >= 0) {
      this.allSessions[idx].isTop = !this.allSessions[idx].isTop
      const list: ChatSession[] = [...this.allSessions]
      list.sort((a: ChatSession, b: ChatSession) => {
        if (a.isTop && !b.isTop) return -1
        if (!a.isTop && b.isTop) return 1
        return b.updateTime - a.updateTime
      })
      this.allSessions = list
      await this.saveSessions()
      promptAction.showToast({
        message: this.allSessions.find((s: ChatSession) => s.id === id)?.isTop ? '已置顶' : '已取消置顶',
        duration: 1500
      })
    }
  }

  private async toggleBlacklist(id: string): Promise<void> {
    const idx: number = this.allSessions.findIndex((s: ChatSession) => s.id === id)
    if (idx >= 0) {
      this.allSessions[idx].isBlacklisted = !this.allSessions[idx].isBlacklisted
      this.allSessions = [...this.allSessions]
      await this.saveSessions()
      promptAction.showToast({
        message: this.allSessions.find((s: ChatSession) => s.id === id)?.isBlacklisted ? '已拉入黑名单' : '已移出黑名单',
        duration: 1500
      })
    }
  }

  private enterChat(id: string): void {
    try {
      const session: ChatSession | undefined = this.allSessions.find((s: ChatSession) => s.id === id)
      if (session?.isBlacklisted) {
        promptAction.showToast({ message: '该联系人已在黑名单中，无法聊天', duration: 2000 })
        return
      }
      router.pushUrl({ url: 'pages/ChatDetailPage', params: { sessionId: id } }).catch((error: Error) => {
        console.error('路由跳转失败:', error)
      })
    } catch (e) {
      console.error('跳转异常:', e)
    }
  }

  private addNewContact(): void {
    try {
      const newSession: ChatSession = new ChatSession('新对话')
      this.allSessions.unshift(newSession)
      this.allSessions = [...this.allSessions]
      this.saveSessions()
      router.pushUrl({ url: 'pages/ConfigPage', params: { sessionId: newSession.id, isNewContact: 'true' } }).catch((error: Error) => {
        console.error('跳转到配置页失败:', error)
      })
    } catch (e) {
      console.error('添加联系人异常:', e)
    }
  }

  private openSettings(): void {
    try {
      router.pushUrl({ url: 'pages/SettingsPage' }).catch((error: Error) => {
        console.error('跳转设置页失败:', error)
      })
    } catch (e) {
      console.error('跳转设置页异常:', e)
    }
  }

  private showSessionOptions(session: ChatSession): void {
    const buttons: promptAction.Button[] = [
      { text: session.isTop ? '取消置顶' : '置顶', color: '#333333' },
      { text: session.isBlacklisted ? '移出黑名单' : '拉入黑名单', color: '#333333' },
      { text: '删除', color: '#FF4444' }
    ]

    promptAction.showDialog({
      title: session.title,
      message: '请选择操作',
      buttons: buttons
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 0) {
        this.toggleTop(session.id)
      } else if (result.index === 1) {
        this.toggleBlacklist(session.id)
      } else if (result.index === 2) {
        this.deleteSession(session.id)
      }
    }).catch(() => {
      // 用户取消，忽略
    })
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Text('聊天')
            .fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1)

          Button() {
            SymbolGlyph($r('sys.symbol.gearshape_fill')).fontSize(22).fontColor(['#333333'])
          }
          .type(ButtonType.Circle).backgroundColor('transparent').width(40).height(40)
          .onClick(() => this.openSettings())

          Button() {
            SymbolGlyph($r('sys.symbol.plus')).fontSize(24).fontColor(['#333333'])
          }
          .type(ButtonType.Circle).backgroundColor('transparent').width(40).height(40)
          .onClick(() => this.addNewContact())
        }
        .width('100%').height(56 + this.safeTop)
        .padding({ left: 16, right: 16, top: this.safeTop })
        .backgroundColor('#F5F5F5')

        // 内容区域
        if (this.allSessions.length === 0) {
          Column() {
            SymbolGlyph($r('sys.symbol.message')).fontSize(48).fontColor(['#CCCCCC'])
            Text('暂无联系人').fontSize(14).fontColor('#999999').margin({ top: 12 })
            Text('点击右上角 + 添加').fontSize(12).fontColor('#BBBBBB').margin({ top: 8 })
          }
          .width('100%').height('100%').justifyContent(FlexAlign.Center)
          .padding({ top: 0 })
        } else {
          Refresh({ refreshing: $$this.isRefreshing }) {
            List({ space: 12 }) {
              ListItem() {
                Column() {
                  ForEach(
                    this.allSessions,
                    (session: ChatSession, index: number) => {
                      ContactItem({
                        sessionId: session.id,
                        title: session.title,
                        lastMessage: session.lastMessage,
                        updateTime: session.updateTime,
                        isTop: session.isTop,
                        isBlacklisted: session.isBlacklisted,
                        customAvatar: session.customAvatar
                      })
                        .onClick(() => this.enterChat(session.id))
                        .gesture(
                          LongPressGesture({ repeat: false })
                            .onAction(() => this.showSessionOptions(session))
                        )

                      if (index < this.allSessions.length - 1) {
                        this.SessionDivider()
                      }
                    },
                    (session: ChatSession) => session.id
                  )
                }
                .width('100%')
                .borderRadius(16)
                .backgroundColor('#FFFFFF')
                .clip(true)
              }
              .padding({ left: 16, right: 16 })

              // 底部留白
              ListItem().height(20)
            }
            .width('100%').layoutWeight(1)
            .padding({ top: 8, bottom: 20 })
            .backgroundColor('#F5F5F5')
            .edgeEffect(EdgeEffect.Spring)
          }
          .onRefreshing(() => this.onRefresh())
        }
      }
      .width('100%').height('100%').backgroundColor('#F5F5F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      // 用户协议弹窗
      if (this.showAgreement) {
        Column() {
          Column({ space: 16 }) {
            Image($r('app.media.app_icon'))
              .width(64).height(64).borderRadius(16).objectFit(ImageFit.Cover)

            Text('服务协议与隐私政策')
              .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
              .textAlign(TextAlign.Center)

            Column({ space: 4 }) {
              Text('欢迎使用智识号AITools！在使用前，请您仔细阅读并充分了解以下条款：')
                .fontSize(14).fontColor('#666666')
                .width('100%').lineHeight(22)

              Row({ space: 4 }) {
                Text('《隐私政策》')
                  .fontSize(14).fontColor('#07C160')
                  .onClick(() => {
                    try {
                      const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
                      ctx.openLink('https://agreement-drcn.hispace.dbankcloud.cn/index.html?lang=zh&agreementId=2007596305831991616')
                    } catch (e) {
                      console.error('跳转失败:', JSON.stringify(e))
                    }
                  })
              }
              .width('100%')

              Text('我们将严格按照政策内容保护您的个人信息安全。点击"同意"即表示您已阅读并同意全部条款。')
                .fontSize(14).fontColor('#666666')
                .width('100%').lineHeight(22)
            }
            .width('100%')

            Column({ space: 12 }) {
              Button('同意')
                .width('100%').height(44)
                .fontSize(16).fontColor('#FFFFFF')
                .backgroundColor('#07C160')
                .borderRadius(22)
                .onClick(() => this.agreePrivacy())

              Button('不同意并退出')
                .width('100%').height(44)
                .fontSize(16).fontColor('#999999')
                .backgroundColor('transparent')
                .borderRadius(22)
                .onClick(() => this.disagreeAndExit())
            }
            .width('100%')
            .margin({ top: 8 })
          }
          .width('85%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 30, color: 'rgba(0,0,0,0.15)', offsetX: 0, offsetY: 8 })
        }
        .width('100%').height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.Center)
        .zIndex(200)
      }
    }
    .width('100%').height('100%')
  }
}