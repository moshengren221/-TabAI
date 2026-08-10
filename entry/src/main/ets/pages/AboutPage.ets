import { router } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'

@Entry
@Component
struct AboutPage {
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
        .maxLines(1)

      if (subtitle && subtitle.length > 0) {
        Text(subtitle)
          .fontSize(14)
          .fontColor('#999999')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ left: 8 })
      } else {
        Blank().layoutWeight(1)
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

        Text('关于我们')
          .fontSize(20).fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Row().width(40)
      }
      .width('100%')
      .height(56 + this.safeTop)
      .padding({ left: 12, right: 12, top: this.safeTop })
      .backgroundColor('#F5F5F5')

      List({ space: 12 }) {
        // 应用信息卡片
        ListItem() {
          Column({ space: 8 }) {
            Image($r('app.media.startIcon'))
              .width(72).height(72)
              .borderRadius(16)

            Text('智识TabAI')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#000000')

            Text('你的AI智能助手')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .padding({ top: 24, bottom: 24 })
          .alignItems(HorizontalAlign.Center)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
        }
        .padding({ left: 16, right: 16 })

        // 版本和官网卡片
        ListItem() {
          Column() {
            this.MenuRow(
              $r('sys.symbol.info_circle_fill'),
              '#007AFF',
              '当前版本',
              'v1.0.1',
              false
            )

            this.MenuDivider()

            this.MenuRow(
              $r('sys.symbol.link'),
              '#FF9500',
              '官方网站',
              'www.lycbook.xyz/our',
              true,
              async () => {
                try {
                  const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
                  await ctx.openLink('https://lycbook.xyz')
                } catch (e) {
                  console.error('打开链接失败:', JSON.stringify(e))
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

        // 隐私和开源卡片
        ListItem() {
          Column() {
            this.MenuRow(
              $r('sys.symbol.lock_shield'),
              '#34C759',
              '隐私政策',
              '',
              true,
              () => router.pushUrl({ url: 'pages/PrivacyPolicyPage' })
            )

            this.MenuDivider()

            this.MenuRow(
              $r('sys.symbol.book'),
              '#5856D6',
              '开源许可',
              '',
              true,
              () => router.pushUrl({ url: 'pages/OpenSourcePage' })
            )
          }
          .width('100%')
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .clip(true)
        }
        .padding({ left: 16, right: 16 })

        // 意见反馈卡片
        ListItem() {
          Column() {
            this.MenuRow(
              $r('sys.symbol.envelope_fill'),
              '#FF2D55',
              '意见反馈',
              'dayunjituan@outlook.com',
              true,
              async () => {
                try {
                  const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
                  await ctx.openLink('mailto:dayunjituan@outlook.com')
                } catch (e) {
                  console.error('打开邮箱失败:', JSON.stringify(e))
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

        // 底部版权
        ListItem() {
          Column({ space: 4 }) {
            Text('Copyright © 2025 TabAI Team')
              .fontSize(12)
              .fontColor('#BBBBBB')
            Text('Powered by ArkTS')
              .fontSize(12)
              .fontColor('#BBBBBB')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 12, bottom: 20 })
        }
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