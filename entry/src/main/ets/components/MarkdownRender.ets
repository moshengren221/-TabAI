interface BlockItem {
  type: string;
  content: string;
  lang?: string;
}

@Component
export struct MarkdownRender {
  @Prop content: string;
  @Prop textColor: string = '#000000';

  private parseBlocks(text: string): BlockItem[] {
    const blocks: BlockItem[] = [];
    const codeRegex = /```(\w*)\n([\s\S]*?)```/g;
    let lastIndex = 0;
    let match: RegExpExecArray | null;
    while ((match = codeRegex.exec(text)) !== null) {
      if (match.index > lastIndex) {
        blocks.push({ type: 'text', content: text.substring(lastIndex, match.index) });
      }
      blocks.push({ type: 'code', content: match[2], lang: match[1] });
      lastIndex = match.index + match[0].length;
    }
    if (lastIndex < text.length) {
      blocks.push({ type: 'text', content: text.substring(lastIndex) });
    }
    if (blocks.length === 0) blocks.push({ type: 'text', content: text });
    return blocks;
  }

  private renderInline(txt: string): string[] {
    return txt.split('\n');
  }

  build() {
    Column() {
      ForEach(this.parseBlocks(this.content), (block: BlockItem, index: number) => {
        if (block.type === 'code') {
          Column() {
            if (block.lang) {
              Text(block.lang)
                .fontSize(11)
                .fontColor('#888888')
                .margin({ bottom: 4 });
            }
            Text(block.content)
              .fontSize(13)
              .fontColor('#333333')
              .fontFamily('monospace')
              .maxLines(100)
              .width('100%');
          }
          .width('100%')
          .padding(10)
          .backgroundColor('#F0F0F0')
          .borderRadius(8)
          .margin({ top: 6, bottom: 6 });
        } else {
          ForEach(this.renderInline(block.content), (line: string, idx: number) => {
            Text(line)
              .fontSize(15)
              .fontColor(this.textColor)
              .lineHeight(22)
              .width('100%');
          });
        }
      });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }
}