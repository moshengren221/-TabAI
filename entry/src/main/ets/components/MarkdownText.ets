enum MarkdownType {
  TEXT,
  H1,
  H2,
  H3,
  UL,
  OL,
  QUOTE,
  CODE_BLOCK,
  DIVIDER,
  EMPTY
}

class MarkdownLine {
  type: MarkdownType = MarkdownType.TEXT
  text: string = ''
  extra: string = ''

  constructor(type: MarkdownType, text: string, extra: string = '') {
    this.type = type
    this.text = text
    this.extra = extra
  }
}

enum InlineType {
  PLAIN,
  BOLD,
  ITALIC,
  CODE,
  LINK
}

class InlineSegment {
  type: InlineType = InlineType.PLAIN
  text: string = ''
  url: string = ''

  constructor(type: InlineType, text: string, url: string = '') {
    this.type = type
    this.text = text
    this.url = url
  }
}

@Component
export struct MarkdownText {
  @Prop content: string = ''
  @Prop fontSize: number = 16
  @Prop fontColor: string = '#333333'

  private parseLines(): MarkdownLine[] {
    const result: MarkdownLine[] = []
    const raw: string[] = this.content.split('\n')
    let inCode: boolean = false
    let codeLang: string = ''
    let codeBody: string = ''

    for (let i: number = 0; i < raw.length; i++) {
      const line: string = raw[i]
      const trimmed: string = line.trim()

      if (trimmed.startsWith('```')) {
        if (inCode) {
          result.push(new MarkdownLine(MarkdownType.CODE_BLOCK, codeBody, codeLang))
          codeBody = ''
          codeLang = ''
          inCode = false
        } else {
          inCode = true
          codeLang = trimmed.substring(3).trim()
        }
        continue
      }

      if (inCode) {
        if (codeBody.length > 0) codeBody += '\n'
        codeBody += line
        continue
      }

      if (trimmed.length === 0) {
        result.push(new MarkdownLine(MarkdownType.EMPTY, ''))
        continue
      }

      if (trimmed.startsWith('### ')) {
        result.push(new MarkdownLine(MarkdownType.H3, trimmed.substring(4)))
        continue
      }
      if (trimmed.startsWith('## ')) {
        result.push(new MarkdownLine(MarkdownType.H2, trimmed.substring(3)))
        continue
      }
      if (trimmed.startsWith('# ')) {
        result.push(new MarkdownLine(MarkdownType.H1, trimmed.substring(2)))
        continue
      }

      if (/^[-*_]{3,}$/.test(trimmed)) {
        result.push(new MarkdownLine(MarkdownType.DIVIDER, ''))
        continue
      }

      if (trimmed.startsWith('- ') || trimmed.startsWith('* ') || trimmed.startsWith('+ ')) {
        result.push(new MarkdownLine(MarkdownType.UL, trimmed.substring(2)))
        continue
      }

      const olMatch: RegExpMatchArray | null = trimmed.match(/^(\d+)\.\s+(.*)/)
      if (olMatch) {
        result.push(new MarkdownLine(MarkdownType.OL, olMatch[2], olMatch[1]))
        continue
      }

      if (trimmed.startsWith('> ')) {
        result.push(new MarkdownLine(MarkdownType.QUOTE, trimmed.substring(2)))
        continue
      }

      result.push(new MarkdownLine(MarkdownType.TEXT, trimmed))
    }

    if (inCode && codeBody.length > 0) {
      result.push(new MarkdownLine(MarkdownType.CODE_BLOCK, codeBody, codeLang))
    }

    return result
  }

  private parseInlineSegments(text: string): InlineSegment[] {
    const segments: InlineSegment[] = []
    const pattern: RegExp = /(`[^`]+`|\*\*[^*]+\*\*|\*[^*]+\*|$$[^$$]+\]$$[^)]+$$)/g
    let lastIndex: number = 0
    let match: RegExpExecArray | null = pattern.exec(text)

    while (match !== null) {
      if (match.index > lastIndex) {
        segments.push(new InlineSegment(InlineType.PLAIN, text.substring(lastIndex, match.index)))
      }

      const m: string = match[0]

      if (m.startsWith('`') && m.endsWith('`')) {
        segments.push(new InlineSegment(InlineType.CODE, m.substring(1, m.length - 1)))
      } else if (m.startsWith('**') && m.endsWith('**')) {
        segments.push(new InlineSegment(InlineType.BOLD, m.substring(2, m.length - 2)))
      } else if (m.startsWith('[') && m.includes('](')) {
        const parts: string[] = m.split('](')
        const label: string = parts[0].substring(1)
        const url: string = parts[1].substring(0, parts[1].length - 1)
        segments.push(new InlineSegment(InlineType.LINK, label, url))
      } else if (m.startsWith('*') && m.endsWith('*')) {
        segments.push(new InlineSegment(InlineType.ITALIC, m.substring(1, m.length - 1)))
      } else {
        segments.push(new InlineSegment(InlineType.PLAIN, m))
      }

      lastIndex = match.index + m.length
      match = pattern.exec(text)
    }

    if (lastIndex < text.length) {
      segments.push(new InlineSegment(InlineType.PLAIN, text.substring(lastIndex)))
    }

    return segments
  }

  private hasInlineFormat(text: string): boolean {
    return text.includes('`') || text.includes('**') || text.includes('*') || text.includes('[')
  }

  build() {
    Column({ space: 4 }) {
      ForEach(this.parseLines(), (line: MarkdownLine) => {
        if (line.type === MarkdownType.EMPTY) {
          Column()
            .width('100%')
            .height(8)
        }
        else if (line.type === MarkdownType.H1) {
          Text(line.text)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.fontColor)
            .width('100%')
            .constraintSize({ maxWidth: '100%' })
        }
        else if (line.type === MarkdownType.H2) {
          Text(line.text)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.fontColor)
            .width('100%')
            .constraintSize({ maxWidth: '100%' })
        }
        else if (line.type === MarkdownType.H3) {
          Text(line.text)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.fontColor)
            .width('100%')
            .constraintSize({ maxWidth: '100%' })
        }
        else if (line.type === MarkdownType.DIVIDER) {
          Divider()
            .color('#E5E5E5')
            .margin({ top: 4, bottom: 4 })
            .width('100%')
        }
        else if (line.type === MarkdownType.UL) {
          Row({ space: 6 }) {
            Text('•')
              .fontSize(this.fontSize)
              .fontColor(this.fontColor)
              .flexShrink(0)
            Text(line.text)
              .fontSize(this.fontSize)
              .fontColor(this.fontColor)
              .layoutWeight(1)
              .constraintSize({ maxWidth: '100%' })
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }
        else if (line.type === MarkdownType.OL) {
          Row({ space: 6 }) {
            Text(line.extra + '.')
              .fontSize(this.fontSize)
              .fontColor(this.fontColor)
              .fontWeight(FontWeight.Medium)
              .flexShrink(0)
            Text(line.text)
              .fontSize(this.fontSize)
              .fontColor(this.fontColor)
              .layoutWeight(1)
              .constraintSize({ maxWidth: '100%' })
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }
        else if (line.type === MarkdownType.QUOTE) {
          Row() {
            Column()
              .width(3)
              .height('100%')
              .backgroundColor('#CCCCCC')
              .margin({ right: 8 })
              .flexShrink(0)
            Text(line.text)
              .fontSize(this.fontSize)
              .fontColor('#666666')
              .fontStyle(FontStyle.Italic)
              .layoutWeight(1)
              .constraintSize({ maxWidth: '100%' })
          }
          .width('100%')
          .padding({ left: 4, top: 4, bottom: 4 })
        }
        else if (line.type === MarkdownType.CODE_BLOCK) {
          Text(line.text)
            .fontSize(this.fontSize - 2)
            .fontColor('#D4D4D4')
            .fontFamily('monospace')
            .width('100%')
            .constraintSize({ maxWidth: '100%' })
            .padding(12)
            .backgroundColor('#1E1E1E')
            .borderRadius(8)
        }
        else {
          // 普通行
          if (this.hasInlineFormat(line.text)) {
            Text('') {
              ForEach(this.parseInlineSegments(line.text), (seg: InlineSegment) => {
                if (seg.type === InlineType.BOLD) {
                  Span(seg.text)
                    .fontSize(this.fontSize)
                    .fontColor(this.fontColor)
                    .fontWeight(FontWeight.Bold)
                }
                else if (seg.type === InlineType.ITALIC) {
                  Span(seg.text)
                    .fontSize(this.fontSize)
                    .fontColor(this.fontColor)
                    .fontStyle(FontStyle.Italic)
                }
                else if (seg.type === InlineType.CODE) {
                  Span(seg.text)
                    .fontSize(this.fontSize - 2)
                    .fontColor('#E83E8C')
                    .backgroundColor('#F5F5F5')
                    .borderRadius(4)
                }
                else if (seg.type === InlineType.LINK) {
                  Span(seg.text)
                    .fontSize(this.fontSize)
                    .fontColor('#007DFF')
                    .decoration({ type: TextDecorationType.Underline })
                }
                else {
                  Span(seg.text)
                    .fontSize(this.fontSize)
                    .fontColor(this.fontColor)
                }
              })
            }
            .width('100%')
            .constraintSize({ maxWidth: '100%' })
          } else {
            Text(line.text)
              .fontSize(this.fontSize)
              .fontColor(this.fontColor)
              .width('100%')
              .constraintSize({ maxWidth: '100%' })
          }
        }
      })
    }
    .width('100%')
    .constraintSize({ maxWidth: '100%' })
    .alignItems(HorizontalAlign.Start)
  }
}