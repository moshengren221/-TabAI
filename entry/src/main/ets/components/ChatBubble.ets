import { MessageModel, MessageRole, MessageStatus } from '../model/MessageModel'
import { MarkdownText } from './MarkdownText'
import { pasteboard } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'

@Component
export struct ChatBubble {
  @ObjectLink message: MessageModel
  @Prop aiNickname: string = 'TabAI'
  @Prop bubbleUserColor: string = '#95EC69'
  @Prop bubbleAiColor: string = '#FFFFFF'
  @Prop showThinking: boolean = false
  @Prop aiAvatar: string = ''
  onQuote?: (msg: MessageModel) => void
  onRecall?: (msg: MessageModel) => void
  onDelete?: (msg: MessageModel) => void
  onToggleContext?: (msg: MessageModel) => void
  onAvatarClick?: () => void
  onAvatarLongPress?: () => void
  @State showMenu: boolean = false

  private formatTime(ts: number): string {
    const d: Date = new Date(ts)
    return `${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`
  }

  private canRecall(): boolean {
    if (this.message.role !== MessageRole.USER) return false
    const elapsed: number = (Date.now() - this.message.timestamp) / 1000 / 60
    return elapsed <= 2 && this.message.canRecall
  }

  private getContrastColor(hex: string): string {
    if (!hex || hex.length < 7) return '#333333'
    const r: number = parseInt(hex.substring(1, 3), 16)
    const g: number = parseInt(hex.substring(3, 5), 16)
    const b: number = parseInt(hex.substring(5, 7), 16)
    const brightness: number = (r * 299 + g * 587 + b * 114) / 1000
    return brightness > 128 ? '#333333' : '#FFFFFF'
  }

  private async copyToClipboard(): Promise<void> {
    try {
      const pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.message.content)
      await pasteboard.getSystemPasteboard().setData(pasteData)
      promptAction.showToast({ message: '已复制', duration: 1500 })
    } catch (e) {
      console.error('复制失败:', JSON.stringify(e))
    }
  }

  @Builder
  MenuBuilder() {
    Column({ space: 0 }) {
      Row({ space: 10 }) {
        SymbolGlyph($r('sys.symbol.doc_text_fill')).fontSize(18).fontColor(['#333333'])
        Text('复制').fontSize(14).fontColor('#333333')
      }
      .width('100%').height(40).padding({ left: 12, right: 12 })
      .onClick(() => {
        this.showMenu = false
        this.copyToClipboard()
      })

      if (this.message.role === MessageRole.ASSISTANT && this.onQuote) {
        Row({ space: 10 }) {
          SymbolGlyph($r('sys.symbol.textformat')).fontSize(18).fontColor(['#333333'])
          Text('引用').fontSize(14).fontColor('#333333')
        }
        .width('100%').height(40).padding({ left: 12, right: 12 })
        .onClick(() => {
          this.showMenu = false
          if (this.onQuote) this.onQuote(this.message)
        })
      }

      if (this.onToggleContext) {
        Row({ space: 10 }) {
          SymbolGlyph(this.message.isContext ? $r('sys.symbol.pin_slash') : $r('sys.symbol.pin'))
            .fontSize(18).fontColor(['#333333'])
          Text(this.message.isContext ? '移出上下文' : '添加到上下文')
            .fontSize(14).fontColor('#333333')
        }
        .width('100%').height(40).padding({ left: 12, right: 12 })
        .onClick(() => {
          this.showMenu = false
          if (this.onToggleContext) this.onToggleContext(this.message)
        })
      }

      if (this.message.role === MessageRole.USER && this.canRecall() && this.onRecall) {
        Row({ space: 10 }) {
          SymbolGlyph($r('sys.symbol.arrowshape_turn_up_left_fill')).fontSize(18).fontColor(['#333333'])
          Text('撤回').fontSize(14).fontColor('#333333')
        }
        .width('100%').height(40).padding({ left: 12, right: 12 })
        .onClick(() => {
          this.showMenu = false
          if (this.onRecall) this.onRecall(this.message)
        })
      }

      if (this.onDelete) {
        Row({ space: 10 }) {
          SymbolGlyph($r('sys.symbol.trash_fill')).fontSize(18).fontColor(['#FF4444'])
          Text('删除').fontSize(14).fontColor('#FF4444')
        }
        .width('100%').height(40).padding({ left: 12, right: 12 })
        .onClick(() => {
          this.showMenu = false
          if (this.onDelete) this.onDelete(this.message)
        })
      }
    }
    .width(160)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 20, color: 'rgba(0,0,0,0.15)', offsetX: 0, offsetY: 4 })
  }

  build() {
    Column() {
      // ========== AI消息 ==========
      if (this.message.role === MessageRole.ASSISTANT) {
        Row() {
          // 头像
          Stack() {
            if (this.aiAvatar && this.aiAvatar.length > 0) {
              Image(this.aiAvatar)
                .width(40).height(40).borderRadius(4).objectFit(ImageFit.Cover)
            } else {
              Image($r('app.media.touxiang'))
                .width(40).height(40).borderRadius(4).objectFit(ImageFit.Cover)
            }
          }
          .width(40).height(40)
          .margin({ right: 8 })
          .flexShrink(0)
          .onClick(() => {
            if (this.onAvatarClick) this.onAvatarClick()
          })
          .gesture(
            LongPressGesture({ repeat: false }).onAction(() => {
              if (this.onAvatarLongPress) this.onAvatarLongPress()
            })
          )

          Column({ space: 4 }) {
            Text(this.aiNickname)
              .fontSize(12).fontColor('#999999')

            Row() {
              if (this.message.isContext) {
                Column()
                  .width(3).height('100%').backgroundColor('#07C160')
              }

              MarkdownText({
                content: this.message.content,
                fontSize: 16,
                fontColor: this.getContrastColor(this.bubbleAiColor)
              })
                .layoutWeight(1)
                .padding({
                  left: this.message.isContext ? 9 : 12,
                  right: 12,
                  top: 10,
                  bottom: 10
                })
            }
            .width('100%')
            .backgroundColor(this.bubbleAiColor)
            .borderRadius(4)
            .bindPopup(this.showMenu, {
              builder: this.MenuBuilder(),
              placement: Placement.Bottom,
              popupColor: Color.White,
              mask: true,
              onStateChange: (e) => { this.showMenu = e.isVisible }
            })
            .gesture(
              LongPressGesture({ repeat: false }).onAction(() => { this.showMenu = true })
            )

            if (this.message.isContext) {
              Row({ space: 4 }) {
                SymbolGlyph($r('sys.symbol.pin')).fontSize(10).fontColor(['#07C160'])
                Text('上下文').fontSize(10).fontColor('#07C160')
              }
            }

            Text(this.formatTime(this.message.timestamp))
              .fontSize(11).fontColor('#BBBBBB')
          }
          .layoutWeight(1)
          .constraintSize({ maxWidth: '70%' })
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(VerticalAlign.Top)
      }

      // ========== 用户消息 ==========
      if (this.message.role === MessageRole.USER) {
        Column({ space: 4 }) {
          Text('我')
            .fontSize(12).fontColor('#999999')
            .textAlign(TextAlign.End).width('100%')

          Column({ space: 6 }) {
            // 用户发送的图片
            if (this.message.imageUri && this.message.imageUri.length > 0) {
              Image(this.message.imageUri)
                .width(180)
                .borderRadius(6)
                .objectFit(ImageFit.Contain)
                .constraintSize({ maxHeight: 240 })
            }

            // 用户发送的文字（有内容才显示）
            if (this.message.content && this.message.content.length > 0) {
              Row() {
                Text(this.message.content)
                  .fontSize(16)
                  .fontColor(this.getContrastColor(this.bubbleUserColor))
                  .constraintSize({ maxWidth: '100%' })
                  .padding({
                    left: 12,
                    right: this.message.isContext ? 9 : 12,
                    top: 10,
                    bottom: 10
                  })

                if (this.message.isContext) {
                  Column()
                    .width(3).height('100%').backgroundColor('#07C160')
                }
              }
              .constraintSize({ maxWidth: '100%' })
              .backgroundColor(this.bubbleUserColor)
              .borderRadius(4)
            }

            // 整体长按菜单（绑定在外层 Column 上）
          }
          .constraintSize({ maxWidth: '100%' })
          .backgroundColor((!this.message.content || this.message.content.length === 0) && this.message.imageUri ? 'transparent' : 'transparent')
          .bindPopup(this.showMenu, {
            builder: this.MenuBuilder(),
            placement: Placement.Bottom,
            popupColor: Color.White,
            mask: true,
            onStateChange: (e) => { this.showMenu = e.isVisible }
          })
          .gesture(
            LongPressGesture({ repeat: false }).onAction(() => { this.showMenu = true })
          )

          if (this.message.isContext) {
            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.pin')).fontSize(10).fontColor(['#07C160'])
              Text('上下文').fontSize(10).fontColor('#07C160')
            }
            .justifyContent(FlexAlign.End).width('100%')
          }

          Row() {
            if (this.message.status === MessageStatus.READ) {
              Text('已读').fontSize(11).fontColor('#BBBBBB')
            } else if (this.message.status === MessageStatus.SENT) {
              Text('已送达').fontSize(11).fontColor('#BBBBBB')
            } else {
              Text('发送中').fontSize(11).fontColor('#BBBBBB')
            }
            Text(' ')
            Text(this.formatTime(this.message.timestamp))
              .fontSize(11).fontColor('#BBBBBB')
          }
          .justifyContent(FlexAlign.End)
        }
        .constraintSize({ maxWidth: '70%' })
        .alignItems(HorizontalAlign.End)
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .alignItems(this.message.role === MessageRole.USER ? HorizontalAlign.End : HorizontalAlign.Start)
  }
}