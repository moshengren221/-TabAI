import { router } from '@kit.ArkUI'
import { ChatSession } from '../model/ChatSession'
import { PreferencesUtil } from '../common/PreferencesUtil'
import { Constants } from '../common/Constants'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { fileIo } from '@kit.CoreFileKit'

interface RouterParams {
  sessionId: string
}

@Entry
@Component
struct ContactInfoPage {
  @State title: string = ''
  @State customAvatar: string = ''
  @State createdAt: string = ''
  @State showEditDialog: boolean = false
  @State editInput: string = ''
  @State showThinking: boolean = false
  private sessionId: string = ''
  private safeTop: number = AppStorage.get<number>('safeTop') ?? 0

  @Builder
  MenuRow(
    icon: Resource,
    iconBg: string,
    title: string,
    subtitle: string = '',
    hasArrow: boolean = true,
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
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (subtitle && subtitle.length > 0) {
        Text(subtitle)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ left: 8 })
      }

      if (hasArrow) {
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
  MenuDivider() {
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
        this.title = session.title || '未命名'
        this.customAvatar = session.customAvatar || ''
        this.showThinking = session.showThinking || false
        this.createdAt = this.formatCreationTime(this.sessionId)
      }
    } catch (e) {
      console.error('Load contact info failed:', JSON.stringify(e))
    }
  }

  private formatCreationTime(id: string): string {
    try {
      const match: RegExpMatchArray | null = id.match(/^(\d+)/)
      if (!match) return '未知'
      const numStr: string = match[1]
      const truncated: string = numStr.length > 13 ? numStr.substring(0, 13) : numStr
      const timestamp: number = parseInt(truncated)
      if (isNaN(timestamp) || timestamp <= 0) return '未知'
      const d: Date = new Date(timestamp)
      const year: number = d.getFullYear()
      if (year < 1970 || year > 2100) return '未知'
      const month: string = (d.getMonth() + 1).toString().padStart(2, '0')
      const day: string = d.getDate().toString().padStart(2, '0')
      const hours: string = d.getHours().toString().padStart(2, '0')
      const minutes: string = d.getMinutes().toString().padStart(2, '0')
      return `${year}年${month}月${day}日 ${hours}:${minutes}`
    } catch (e) {
      return '未知'
    }
  }

  private async copyToLocal(srcUri: string, prefix: string): Promise<string> {
    const fileName: string = prefix + '_' + Date.now() + '.jpg'
    const ctx: Context = getContext(this)
    const destPath: string = ctx.filesDir + '/' + fileName

    let srcFd: number = -1
    let destFd: number = -1
    try {
      srcFd = fileIo.openSync(srcUri, fileIo.OpenMode.READ_ONLY).fd
      destFd = fileIo.openSync(destPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE).fd
      const bufSize: number = 4096
      let bytesRead: number = 0
      let totalWritten: number = 0
      do {
        const buf: ArrayBuffer = new ArrayBuffer(bufSize)
        bytesRead = fileIo.readSync(srcFd, buf)
        if (bytesRead > 0) {
          const writeBuf: ArrayBuffer = buf.slice(0, bytesRead)
          fileIo.writeSync(destFd, writeBuf)
          totalWritten += bytesRead
        }
      } while (bytesRead > 0)
      console.info('copyToLocal done: ' + destPath + ' size=' + totalWritten)
    } catch (e) {
      console.error('copyToLocal failed:', JSON.stringify(e))
    } finally {
      try { if (srcFd >= 0) fileIo.closeSync(srcFd) } catch (ce) { /* ignore */ }
      try { if (destFd >= 0) fileIo.closeSync(destFd) } catch (ce) { /* ignore */ }
    }
    return destPath
  }

  private async pickAvatar(): Promise<void> {
    try {
      const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker()
      const options: photoAccessHelper.PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = 1
      const result: photoAccessHelper.PhotoSelectResult = await picker.select(options)
      if (result.photoUris && result.photoUris.length > 0) {
        const localPath: string = await this.copyToLocal(result.photoUris[0], 'avatar')
        this.customAvatar = 'file://' + localPath
        await this.saveSilent()
      }
    } catch (e) {
      console.error('选择头像失败:', JSON.stringify(e))
    }
  }

  private async saveSilent(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      const json: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
      const sessions: ChatSession[] = JSON.parse(json) as ChatSession[]
      const idx: number = sessions.findIndex((s: ChatSession) => s.id === this.sessionId)
      if (idx >= 0) {
        sessions[idx].title = this.title
        sessions[idx].customAvatar = this.customAvatar
        sessions[idx].showThinking = this.showThinking
        await PreferencesUtil.getInstance().put(ctx, Constants.PREF_SESSIONS, 'list', JSON.stringify(sessions))
      }
    } catch (e) {
      console.error('Save silent failed:', JSON.stringify(e))
    }
  }

  private async save(): Promise<void> {
    try { await this.saveSilent() } catch (e) { console.error('Save failed:', JSON.stringify(e)) }
    router.back()
  }

  private async saveToggle(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      const json: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
      const sessions: ChatSession[] = JSON.parse(json) as ChatSession[]
      const idx: number = sessions.findIndex((s: ChatSession) => s.id === this.sessionId)
      if (idx >= 0) {
        sessions[idx].showThinking = this.showThinking
        await PreferencesUtil.getInstance().put(ctx, Constants.PREF_SESSIONS, 'list', JSON.stringify(sessions))
      }
    } catch (e) {
      console.error('Save toggle failed:', JSON.stringify(e))
    }
  }

  private openEditDialog(): void {
    this.editInput = this.title
    this.showEditDialog = true
  }

  private confirmEdit(): void {
    this.title = this.editInput
    this.showEditDialog = false
    this.save()
  }

  build() {
    Stack() {
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

          Text('联系人详情')
            .fontSize(20).fontWeight(FontWeight.Bold)
            .layoutWeight(1).textAlign(TextAlign.Center)

          Row().width(40)
        }
        .width('100%')
        .height(56 + this.safeTop)
        .padding({ left: 12, right: 12, top: this.safeTop })
        .backgroundColor('#F5F5F5')

        List({ space: 12 }) {
          // 头像卡片
          ListItem() {
            Column({ space: 10 }) {
              if (this.customAvatar && this.customAvatar.length > 0) {
                Image(this.customAvatar)
                  .width(64).height(64).borderRadius(8).objectFit(ImageFit.Cover)
              } else {
                Image($r('app.media.touxiang'))
                  .width(64).height(64).borderRadius(8).objectFit(ImageFit.Cover)
              }
              Text(this.title)
                .fontSize(18).fontWeight(FontWeight.Medium).fontColor('#000000').maxLines(1)
              Text(this.createdAt)
                .fontSize(13).fontColor('#999999')
            }
            .width('100%')
            .padding({ top: 20, bottom: 20 })
            .alignItems(HorizontalAlign.Center)
            .borderRadius(16)
            .backgroundColor('#FFFFFF')
          }
          .padding({ left: 16, right: 16 })

          // 分组1：操作
          ListItem() {
            Column() {
              this.MenuRow(
                $r('sys.symbol.message_fill'),
                '#007AFF',
                '发消息',
                '',
                true,
                () => router.back()
              )
              this.MenuDivider()
              this.MenuRow(
                $r('sys.symbol.person_fill'),
                '#FF9500',
                '设置备注和标签',
                '',
                true,
                () => this.openEditDialog()
              )
              this.MenuDivider()
              this.MenuRow(
                $r('sys.symbol.camera_fill'),
                '#34C759',
                '修改头像',
                '',
                true,
                () => this.pickAvatar()
              )
              this.MenuDivider()

              // AI简短想法（Toggle）
              Row() {
                Stack({ alignContent: Alignment.Center }) {
                  SymbolGlyph($r('sys.symbol.lightbulb_fill'))
                    .fontSize(17).fontColor(['#FFFFFF'])
                }
                .width(30).height(30).borderRadius(8).backgroundColor('#FF2D55')

                Blank().width(12)

                Text('AI简短想法')
                  .fontSize(16).fontColor('#000000')
                  .layoutWeight(1).maxLines(1)

                Toggle({ type: ToggleType.Switch, isOn: this.showThinking })
                  .onChange((isOn: boolean) => {
                    this.showThinking = isOn
                    this.saveToggle()
                  })
              }
              .width('100%')
              .height(54)
              .padding({ left: 16, right: 16 })

              this.MenuDivider()

              this.MenuRow(
                $r('sys.symbol.camera_fill'),
                '#5856D6',
                '聊天背景',
                '灰度测试中',
                true,
                () => promptAction.showToast({ message: '正在灰度测试中，请等待正式公测', duration: 2000 })
              )
            }
            .width('100%')
            .borderRadius(16)
            .backgroundColor('#FFFFFF')
            .clip(true)
          }
          .padding({ left: 16, right: 16 })

          // 分组2：信息
          ListItem() {
            Column() {
              // 创建时间（特殊布局）
              Row() {
                Stack({ alignContent: Alignment.Center }) {
                  SymbolGlyph($r('sys.symbol.clock_fill'))
                    .fontSize(17).fontColor(['#FFFFFF'])
                }
                .width(30).height(30).borderRadius(8).backgroundColor('#8E8E93')

                Blank().width(12)

                Text('创建时间')
                  .fontSize(16).fontColor('#000000')
                  .layoutWeight(1).maxLines(1)

                Text(this.createdAt)
                  .fontSize(14).fontColor('#999999').maxLines(1)
              }
              .width('100%')
              .height(54)
              .padding({ left: 16, right: 16 })

              this.MenuDivider()

              this.MenuRow(
                $r('sys.symbol.info_circle_fill'),
                '#007AFF',
                '更多信息',
                '',
                true,
                () => {
                  try {
                    router.pushUrl({ url: 'pages/MoreInfoPage', params: { sessionId: this.sessionId } })
                  } catch (e) {
                    console.error('跳转更多信息失败:', JSON.stringify(e))
                  }
                }
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
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
      }
      .width('100%').height('100%')
      .backgroundColor('#F5F5F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      // 编辑备注弹窗
      if (this.showEditDialog) {
        Column() {
          Column({ space: 20 }) {
            Text('设置备注').fontSize(18).fontWeight(FontWeight.Medium).fontColor('#000000')
            TextInput({ text: this.editInput, placeholder: '请输入备注名' })
              .width('100%').height(44).backgroundColor('#F5F5F5').borderRadius(8)
              .onChange((value: string) => this.editInput = value)
            Row({ space: 16 }) {
              Button('取消').width('40%').height(40).fontSize(16).fontColor('#333333')
                .backgroundColor('#F5F5F5').borderRadius(8).onClick(() => this.showEditDialog = false)
              Button('保存').width('40%').height(40).fontSize(16).fontColor('#FFFFFF')
                .backgroundColor('#0A59F7').borderRadius(8).onClick(() => this.confirmEdit())
            }
            .width('100%').justifyContent(FlexAlign.Center)
          }
          .width('80%').padding(24).backgroundColor('#FFFFFF').borderRadius(12)
        }
        .width('100%').height('100%').backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.showEditDialog = false)
        .zIndex(100)
      }
    }
    .width('100%').height('100%')
  }
}