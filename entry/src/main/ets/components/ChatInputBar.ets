import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'

@Component
export struct ChatInputBar {
  @Prop supportImage: boolean = false
  @Prop isLoading: boolean = false
  @Prop quoteText: string = ''
  @State inputText: string = ''
  @State selectedImage: string = ''
  onSend?: (text: string, imageUri?: string) => void
  onCancelQuote?: () => void

  private async pickImage(): Promise<void> {
    try {
      const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker()
      const options: photoAccessHelper.PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = 1
      const result: photoAccessHelper.PhotoSelectResult = await picker.select(options)
      if (result.photoUris && result.photoUris.length > 0) {
        this.selectedImage = result.photoUris[0]
      }
    } catch (e) {
      console.error('选择图片失败:', JSON.stringify(e))
    }
  }

  private doSend(): void {
    if (!this.inputText && !this.selectedImage) return
    if (this.onSend) {
      this.onSend(this.inputText, this.selectedImage || undefined)
    }
    this.inputText = ''
    this.selectedImage = ''
  }

  build() {
    Column({ space: 0 }) {
      // 引用提示栏
      if (this.quoteText && this.quoteText.length > 0) {
        Row({ space: 8 }) {
          Column()
            .width(3).height(16).backgroundColor('#07C160').borderRadius(2)

          Text(this.quoteText)
            .fontSize(13).fontColor('#666666')
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(14).fontColor(['#999999'])
            .onClick(() => {
              if (this.onCancelQuote) this.onCancelQuote()
            })
        }
        .width('100%')
        .height(36)
        .padding({ left: 12, right: 12 })
        .backgroundColor('#F5F5F5')
      }

      // 选中图片预览
      if (this.selectedImage && this.selectedImage.length > 0) {
        Stack({ alignContent: Alignment.TopEnd }) {
          Image(this.selectedImage)
            .width(80).height(80)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)

          SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
            .fontSize(20)
            .fontColor(['#FFFFFF'])
            .offset({ x: 8, y: -8 })
            .onClick(() => {
              this.selectedImage = ''
            })
        }
        .width(80).height(80)
        .alignSelf(ItemAlign.Start)
        .margin({ left: 12, top: 8, bottom: 4 })
      }

      // 输入栏
      Row({ space: 8 }) {
        // 图片按钮（仅模型支持图片时显示）
        if (this.supportImage) {
          Button() {
            SymbolGlyph($r('sys.symbol.camera'))
              .fontSize(22)
              .fontColor(this.selectedImage ? ['#07C160'] : ['#666666'])
          }
          .type(ButtonType.Circle)
          .backgroundColor('transparent')
          .width(36).height(36)
          .onClick(() => this.pickImage())
        }

        TextInput({ text: $$this.inputText, placeholder: '输入消息...' })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .fontSize(15)
          .fontColor('#333333')
          .placeholderColor('#BBBBBB')
          .onSubmit(() => this.doSend())

        // 发送按钮
        Button() {
          if (this.isLoading) {
            LoadingProgress()
              .width(20).height(20)
              .color('#FFFFFF')
          } else {
            SymbolGlyph($r('sys.symbol.arrow_up'))
              .fontSize(18)
              .fontColor(['#FFFFFF'])
          }
        }
        .type(ButtonType.Circle)
        .backgroundColor((this.inputText || this.selectedImage) ? '#07C160' : '#CCCCCC')
        .width(36).height(36)
        .enabled(!this.isLoading && (this.inputText.length > 0 || this.selectedImage.length > 0))
        .onClick(() => this.doSend())
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
    }
    .width('100%')
    .padding({ bottom: 16 })
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E5E5E5' })
  }
}