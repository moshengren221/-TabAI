import { router } from '@kit.ArkUI'
import { PreferencesUtil } from '../common/PreferencesUtil'
import { Constants } from '../common/Constants'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct PersonalizePage {
  @State aiNickname: string = 'TabAI'
  @State bubbleUserColor: string = '#95EC69'
  @State bubbleAiColor: string = '#FFFFFF'
  @State chatBgUri: string = ''
  @State bgBlur: string = '0'
  @State userColorInput: string = '#95EC69'
  @State aiColorInput: string = '#FFFFFF'
  private safeTop: number = AppStorage.get<number>('safeTop') ?? 0

  @Builder
  MenuRow(
    icon: Resource,
    iconBg: string,
    title: string,
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

  @Builder
  ColorCard(
    icon: Resource,
    iconBg: string,
    label: string,
    colorValue: string,
    colorInput: string,
    previewColor: string,
    onInputChange: (value: string) => void,
    onApply: () => void
  ) {
    Column({ space: 0 }) {
      // 标题行
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

        Text(label)
          .fontSize(16)
          .fontColor('#000000')
          .maxLines(1)
      }
      .width('100%')
      .height(54)
      .padding({ left: 16, right: 16 })

      this.MenuDivider()

      // 颜色预览 + 输入
      Row() {
        // 预览色块
        Stack({ alignContent: Alignment.Center }) {
          Stack()
            .width(48).height(48)
            .borderRadius(12)
            .backgroundColor(previewColor)
            .border({ width: 1, color: '#E0E0E0' })
        }

        Blank().width(16)

        // 输入框
        TextInput({ text: colorInput, placeholder: '#RRGGBB' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .padding({ left: 12, right: 12 })
          .fontSize(15)
          .fontColor('#333333')
          .placeholderColor('#BBBBBB')
          .fontFamily('monospace')
          .onChange((value: string) => onInputChange(value))
      }
      .width('100%')
      .height(72)
      .padding({ left: 16, right: 16 })

      // 按钮行
      Row({ space: 12 }) {
        Button('预览')
          .fontSize(15)
          .fontColor('#007AFF')
          .backgroundColor('#F0F5FF')
          .borderRadius(10)
          .height(40)
          .layoutWeight(1)
          .onClick(() => onApply())

        Button('应用')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#007AFF')
          .borderRadius(10)
          .height(40)
          .layoutWeight(1)
          .onClick(() => onApply())
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16, top: 4, bottom: 8 })
    }
  }

  async aboutToAppear(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      const pref: PreferencesUtil = PreferencesUtil.getInstance()
      this.aiNickname = await pref.get(ctx, Constants.PREF_PERSONALIZE, 'aiNickname', 'TabAI') as string
      this.bubbleUserColor = await pref.get(ctx, Constants.PREF_PERSONALIZE, 'bubbleUserColor', '#95EC69') as string
      this.bubbleAiColor = await pref.get(ctx, Constants.PREF_PERSONALIZE, 'bubbleAiColor', '#FFFFFF') as string
      this.chatBgUri = await pref.get(ctx, Constants.PREF_PERSONALIZE, 'chatBgUri', '') as string
      this.bgBlur = await pref.get(ctx, Constants.PREF_PERSONALIZE, 'bgBlur', '0') as string
      this.userColorInput = this.bubbleUserColor
      this.aiColorInput = this.bubbleAiColor
    } catch (e) {
      console.error('Load personalize failed:', JSON.stringify(e))
    }
  }

  private isValidHex(color: string): boolean {
    return /^#[0-9A-Fa-f]{6}$/.test(color)
  }

  private applyUserColor(): void {
    if (!this.isValidHex(this.userColorInput)) {
      promptAction.showToast({ message: '请输入正确的颜色值，例如 #95EC69', duration: 2000 })
      return
    }
    this.bubbleUserColor = this.userColorInput.toUpperCase()
  }

  private applyAiColor(): void {
    if (!this.isValidHex(this.aiColorInput)) {
      promptAction.showToast({ message: '请输入正确的颜色值，例如 #FFFFFF', duration: 2000 })
      return
    }
    this.bubbleAiColor = this.aiColorInput.toUpperCase()
  }

  private async save(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      const pref: PreferencesUtil = PreferencesUtil.getInstance()
      await pref.put(ctx, Constants.PREF_PERSONALIZE, 'aiNickname', this.aiNickname)
      await pref.put(ctx, Constants.PREF_PERSONALIZE, 'bubbleUserColor', this.bubbleUserColor)
      await pref.put(ctx, Constants.PREF_PERSONALIZE, 'bubbleAiColor', this.bubbleAiColor)
      await pref.put(ctx, Constants.PREF_PERSONALIZE, 'chatBgUri', this.chatBgUri)
      await pref.put(ctx, Constants.PREF_PERSONALIZE, 'bgBlur', this.bgBlur)
      promptAction.showToast({ message: '保存成功', duration: 1500 })
      setTimeout(() => router.back(), 1000)
    } catch (e) {
      console.error('Save personalize failed:', JSON.stringify(e))
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

        Text('个性化')
          .fontSize(20).fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button('保存')
          .fontSize(15)
          .fontColor('#007AFF')
          .backgroundColor('transparent')
          .height(40)
          .onClick(() => this.save())
      }
      .width('100%')
      .height(56 + this.safeTop)
      .padding({ left: 12, right: 12, top: this.safeTop })
      .backgroundColor('#F5F5F5')

      List({ space: 12 }) {
        // 昵称卡片
        ListItem() {
          Column({ space: 0 }) {
            Row() {
              Stack({ alignContent: Alignment.Center }) {
                SymbolGlyph($r('sys.symbol.person_fill'))
                  .fontSize(17).fontColor(['#FFFFFF'])
              }
              .width(30).height(30).borderRadius(8).backgroundColor('#007AFF')

              Blank().width(12)

              Text('AI 昵称')
                .fontSize(16).fontColor('#000000')

              TextInput({ text: this.aiNickname, placeholder: '请输入AI昵称' })
                .layoutWeight(1)
                .height(40)
                .backgroundColor('#F5F5F5')
                .borderRadius(10)
                .padding({ left: 12, right: 12 })
                .fontSize(15)
                .fontColor('#333333')
                .placeholderColor('#BBBBBB')
                .onChange((value: string) => this.aiNickname = value)
            }
            .width('100%')
            .height(54)
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .clip(true)
        }
        .padding({ left: 16, right: 16 })

        // 我的气泡颜色卡片
        ListItem() {
          Column() {
            this.ColorCard(
              $r('sys.symbol.person_crop_circle_fill'),
              '#FF9500',
              '我的气泡颜色',
              this.bubbleUserColor,
              this.userColorInput,
              this.bubbleUserColor,
              (value: string) => { this.userColorInput = value },
              () => this.applyUserColor()
            )
          }
          .width('100%')
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .clip(true)
        }
        .padding({ left: 16, right: 16 })

        // AI气泡颜色卡片
        ListItem() {
          Column() {
            this.ColorCard(
              $r('sys.symbol.message_fill'),
              '#5856D6',
              'AI气泡颜色',
              this.bubbleAiColor,
              this.aiColorInput,
              this.bubbleAiColor,
              (value: string) => { this.aiColorInput = value },
              () => this.applyAiColor()
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
          Text('输入十六进制颜色值（如 #95EC69），点击"预览"可即时查看效果')
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