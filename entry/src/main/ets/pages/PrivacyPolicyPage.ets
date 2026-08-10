import { router } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'

@Entry
@Component
struct PrivacyPolicyPage {
  private safeTop: number = AppStorage.get<number>('safeTop') ?? 0

  @Builder
  Section(title: string, items: string[]) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(17).fontWeight(FontWeight.Medium).fontColor('#333333')
        .width('100%')
      ForEach(items, (item: string) => {
        Text(item)
          .fontSize(14).fontColor('#666666')
          .width('100%')
          .lineHeight(22)
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward')).fontSize(24).fontColor(['#333333'])
        }
        .type(ButtonType.Circle).backgroundColor('transparent').width(40).height(40)
        .onClick(() => router.back())

        Text('隐私政策')
          .fontSize(20).fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Row().width(40)
      }
      .width('100%').height(56 + this.safeTop)
      .padding({ left: 12, right: 12, top: this.safeTop })
      .backgroundColor('#FFFFFF')

      List() {
        // 头部
        ListItem() {
          Column({ space: 12 }) {
            Text('关于智识号AITools与隐私的声明')
              .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
              .width('100%')
            Text('更新日期：2026.8.2')
              .fontSize(13).fontColor('#999999')
              .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 20, bottom: 12 })
        }

        // 介绍
        ListItem() {
          Column({ space: 12 }) {
            Text('智识号AITools 是由 罗述继 （以下简称"我们"）为您提供的，用于AI智能对话助手的应用。本隐私声明由我们为处理您的个人信息而制定。')
              .fontSize(14).fontColor('#666666').lineHeight(22)
              .width('100%')
            Text('我们非常重视您的个人信息和隐私保护，将会按照法律要求和业界成熟的安全标准，为您的个人信息提供相应的安全保护措施。')
              .fontSize(14).fontColor('#666666').lineHeight(22)
              .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }

        // 隐私声明摘要
        ListItem() {
          Column({ space: 12 }) {
            Text('您可以通过访问隐私声明摘要快速了解应用收集、使用个人信息的目的、方式、范围。除上述主要功能外，我们在提供服务过程还涉及如下处理活动：')
              .fontSize(14).fontColor('#666666').lineHeight(22)
              .width('100%')

            Column({ space: 8 }) {
              Text('对话内容（文字/图片）方面我们提供AI对话服务并加密传输至您配置的AI服务提供商，用于获取AI回复；')
                .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
              Text('我们会使用您的设备信息（型号、系统版本）优化服务体验并在本地存储，用于兼容性适配和问题排查；')
                .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
              Text('我们将会将您的API配置信息（密钥、模型参数）用以连接AI服务，请放心，这些数据仅存储在设备本地，加密保管；')
                .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
              Text('我们会用您的联系人信息（名称、头像）管理对话会话，请放心，这些数据仅存储在设备本地，不上传服务器；')
                .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
              Text('我们会合理调用您的通知权限显示AI回复消息提醒，本地生成通知，不收集任何数据。')
                .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }

        // 1. 我们如何收集和使用您的个人信息
        ListItem() {
          this.Section('1. 我们如何收集和使用您的个人信息', [
            '我们仅在有合法性基础的情形下才会使用您的个人信息。根据适用的法律，我们可能会基于您的同意、为履行/订立您与我们的合同所必需、履行法定义务所必需等合法性基础，使用您的个人信息。'
          ])
        }

        ListItem() {
          Column({ space: 8 }) {
            Text('1.1 我们为您提供下述AI智能对话助手服务，在您使用相关业务的过程中，我们会处理所必需的信息，以便履行我们的合同义务。若您不提供相关信息，会影响到您使用本应用的相关功能/服务。')
              .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
            Text('为了实现应用功能，在获取您的同意后我们需要收集您的联系人列表、用户标识符、其他身份信息、其他设备标识符、账号信息、图片或视频、文字信息、搜索词、剪贴板、其他通讯内容、应用基本信息、应用运行状态、操作系统信息、设备状态。')
              .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        }

        // 2. 设备权限调用
        ListItem() {
          this.Section('2. 设备权限调用', [
            '本服务在运行过程中需要使用以下权限，我们会在使用之前征求您的意见，任何未明确同意使用的权限，均不会被随意调用。'
          ])
        }

        // READ_IMAGEVIDEO
        ListItem() {
          Column({ space: 8 }) {
            Column({ space: 6 }) {
              Text('图片和视频（READ_IMAGEVIDEO）')
                .fontSize(15).fontWeight(FontWeight.Medium).fontColor('#333333')
                .width('100%')
              Text('允许应用读取用户公共目录的图片或视频文件')
                .fontSize(13).fontColor('#999999').width('100%')
            }

            Text('我们会在您同意的前提之下，读取您处于公共目录下的图片文件，用以为您提供图片对话和自定义头像服务。')
              .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // SHORT_TERM_WRITE_IMAGEVIDEO
        ListItem() {
          Column({ space: 8 }) {
            Column({ space: 6 }) {
              Text('短期写入图片视频（SHORT_TERM_WRITE_IMAGEVIDEO）')
                .fontSize(15).fontWeight(FontWeight.Medium).fontColor('#333333')
                .width('100%')
              Text('允许应用短期保存图片、视频到用户公共目录')
                .fontSize(13).fontColor('#999999').width('100%')
            }

            Text('我们会在您使用应用期间，短期保存图片信息于您的设备公共目录之中，用以为您提供自定义联系人头像等服务。该权限为短期授权，应用退出后即失效。')
              .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // READ_PASTEBOARD
        ListItem() {
          Column({ space: 8 }) {
            Column({ space: 6 }) {
              Text('读取剪切板（READ_PASTEBOARD）')
                .fontSize(15).fontWeight(FontWeight.Medium).fontColor('#333333')
                .width('100%')
              Text('允许应用读取剪贴板')
                .fontSize(13).fontColor('#999999').width('100%')
            }

            Text('我们会在您准许的情况下，读取您的剪贴板用以提升对话便捷性。例如您复制的文字可直接粘贴到输入框中发送给AI。我们不会在后台静默读取剪贴板内容。')
              .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }

        ListItem() {
          Divider().color('#E5E5E5').margin({ left: 16 })
        }

        // APP_TRACKING_CONSENT
        ListItem() {
          Column({ space: 8 }) {
            Column({ space: 6 }) {
              Text('应用跟踪（APP_TRACKING_CONSENT）')
                .fontSize(15).fontWeight(FontWeight.Medium).fontColor('#333333')
                .width('100%')
              Text('读取开放匿名设备标识符')
                .fontSize(13).fontColor('#999999').width('100%')
            }

            Text('我们会在您使用应用期间于本地存储您的匿名设备标识符，并用于区别不同用户和提升使用体验。该标识符为匿名标识，不会与您的真实身份信息关联。')
              .fontSize(14).fontColor('#666666').lineHeight(22).width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        }

        // 3. 管理您的个人信息
        ListItem() {
          this.Section('3. 管理您的个人信息', [
            '如您对您的数据主体权利有进一步要求或存在任何疑问、意见或建议，可通过本声明中"如何联系我们"章节中所述方式与我们取得联系，并行使您的相关权利。'
          ])
        }

        // 4. 信息存储地点及期限
        ListItem() {
          this.Section('4. 信息存储地点及期限', [
            '4.1 固定存储期限：对话内容、信息保存永久；联系人配置信息，保存永久。',
            '4.2 上述信息将会传输并保存至您本地的服务器。'
          ])
        }

        // 5. 如何联系我们
        ListItem() {
          this.Section('5. 如何联系我们', [
            '您可通过以下方式联系我们，并行使您的相关权利，我们会尽快回复。',
            '邮箱：dayunjituan@outlook.com',
            '官方网站：http://lycbook.xyz',
            '如果您对我们的回复不满意，特别是当个人信息处理行为损害了您的合法权益时，您还可以通过向有管辖权的人民法院提起诉讼、向行业自律协会或政府相关管理机构投诉等外部途径进行解决。您也可以向我们了解可能适用的相关投诉途径的信息。'
          ])
        }

        // 应用市场隐私政策链接
        ListItem() {
          Column() {
            Divider().color('#E5E5E5').margin({ left: 16 })
            Row() {
              Text('应用市场隐私政策')
                .fontSize(15).fontColor('#333333')
              Blank()
              SymbolGlyph($r('sys.symbol.chevron_forward')).fontSize(16).fontColor(['#BCBCBC'])
            }
            .width('100%').height(52).padding({ left: 16, right: 16 })
            .onClick(() => {
              try {
                const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
                ctx.openLink('https://agreement-drcn.hispace.dbankcloud.cn/index.html?lang=zh&agreementId=2007596305831991616')
              } catch (e) {
                console.error('打开链接失败:', JSON.stringify(e))
              }
            })
          }
          .width('100%').backgroundColor('#FFFFFF')
        }

        // 生效日期
        ListItem() {
          Column() {
            Text('生效日期：2026.8.1')
              .fontSize(14).fontColor('#333333')
              .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 40 })
        }
      }
      .width('100%').layoutWeight(1).backgroundColor('#FFFFFF')
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}