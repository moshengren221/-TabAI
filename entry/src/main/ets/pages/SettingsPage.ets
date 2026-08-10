import { router, promptAction } from '@kit.ArkUI'

@Entry
@Component
struct SettingsPage {
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

        Text('设置')
          .fontSize(20).fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Row().width(40)
      }
      .width('100%')
      .height(56 + this.safeTop)
      .padding({ left: 12, right: 12, top: this.safeTop })
      .backgroundColor('#F5F5F5')

      List({ space: 12 }) {
        // 分组1
        ListItem() {
          Column() {
            this.MenuRow(
              $r('sys.symbol.person_fill'),
              '#007AFF',
              '关于我们',
              '',
              true,
              () => router.pushUrl({ url: 'pages/AboutPage' })
            )
            this.MenuDivider()
            this.MenuRow(
              $r('sys.symbol.arrow_clockwise'),
              '#FF9500',
              '检查更新',
              '',
              true,
              () => promptAction.showToast({ message: '请自行前往应用商店更新', duration: 2000 })
            )
            this.MenuDivider()
            this.MenuRow(
              $r('sys.symbol.info_circle_fill'),
              '#8E8E93',
              '软件信息',
              'v1.0.0',
              false
            )
          }
          .width('100%')
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .clip(true)
        }
        .padding({ left: 16, right: 16 })

        // 分组2
        ListItem() {
          Column() {
            this.MenuRow(
              $r('sys.symbol.star_fill'),
              '#FF2D55',
              '实验室功能',
              '',
              true,
              () => promptAction.showToast({ message: '正在灰度测试中，请等待正式公测', duration: 2000 })
            )
            this.MenuDivider()
            this.MenuRow(
              $r('sys.symbol.paintbrush_fill'),
              '#5856D6',
              '个性化',
              '',
              true,
              () => router.pushUrl({ url: 'pages/PersonalizePage' })
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
  }
}