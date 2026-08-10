import { router } from '@kit.ArkUI'

@Entry
@Component
struct OpenSourcePage {
  private safeTop: number = AppStorage.get<number>('safeTop') ?? 0

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward')).fontSize(24).fontColor(['#333333'])
        }
        .type(ButtonType.Circle).backgroundColor('transparent').width(40).height(40)
        .onClick(() => router.back())

        Text('开源许可')
          .fontSize(20).fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Row().width(40)
      }
      .width('100%').height(56 + this.safeTop)
      .padding({ left: 12, right: 12, top: this.safeTop })
      .backgroundColor('#FFFFFF')

      List() {
        // ArkUI
        ListItem() {
          Column({ space: 6 }) {
            Text('ArkUI').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text('Copyright © Huawei Technologies Co., Ltd.')
              .fontSize(13).fontColor('#999999')
            Text('Apache License 2.0')
              .fontSize(13).fontColor('#07C160')
          }
          .width('100%').alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // RxJS
        ListItem() {
          Column({ space: 6 }) {
            Text('RxJS').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text('Copyright © Google LLC.')
              .fontSize(13).fontColor('#999999')
            Text('Apache License 2.0')
              .fontSize(13).fontColor('#07C160')
          }
          .width('100%').alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // OpenAI
        ListItem() {
          Column({ space: 6 }) {
            Text('OpenAI API').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text('Copyright © OpenAI, L.L.C.')
              .fontSize(13).fontColor('#999999')
            Text('MIT License')
              .fontSize(13).fontColor('#07C160')
          }
          .width('100%').alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // Markdown解析
        ListItem() {
          Column({ space: 6 }) {
            Text('marked').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text('Copyright © Christopher Jeffrey.')
              .fontSize(13).fontColor('#999999')
            Text('MIT License')
              .fontSize(13).fontColor('#07C160')
          }
          .width('100%').alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // Protobuf
        ListItem() {
          Column({ space: 6 }) {
            Text('Protocol Buffers').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text('Copyright © Google LLC.')
              .fontSize(13).fontColor('#999999')
            Text('BSD 3-Clause License')
              .fontSize(13).fontColor('#07C160')
          }
          .width('100%').alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // OkHttp
        ListItem() {
          Column({ space: 6 }) {
            Text('OkHttp').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text('Copyright © Square, Inc.')
              .fontSize(13).fontColor('#999999')
            Text('Apache License 2.0')
              .fontSize(13).fontColor('#07C160')
          }
          .width('100%').alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // Gson
        ListItem() {
          Column({ space: 6 }) {
            Text('Gson').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text('Copyright © Google LLC.')
              .fontSize(13).fontColor('#999999')
            Text('Apache License 2.0')
              .fontSize(13).fontColor('#07C160')
          }
          .width('100%').alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // Axios
        ListItem() {
          Column({ space: 6 }) {
            Text('Axios').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text('Copyright © Matt Zabriskie & Collaborators.')
              .fontSize(13).fontColor('#999999')
            Text('MIT License')
              .fontSize(13).fontColor('#07C160')
          }
          .width('100%').alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // HarmonyOS
        ListItem() {
          Column({ space: 6 }) {
            Text('HarmonyOS SDK').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text('Copyright © Huawei Technologies Co., Ltd.')
              .fontSize(13).fontColor('#999999')
            Text('HarmonyOS SDK License')
              .fontSize(13).fontColor('#07C160')
          }
          .width('100%').alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        }
      }
      .width('100%').layoutWeight(1).backgroundColor('#FFFFFF')
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}