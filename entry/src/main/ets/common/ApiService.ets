import { http } from '@kit.NetworkKit'
import { fileIo } from '@kit.CoreFileKit'

export interface ApiConfig {
  modelName: string
  systemPrompt: string
  apiUrl: string
  apiKey: string
  aiAvatar: string
}

export interface ImageUrl {
  url: string
}

export interface ContentPart {
  type: string
  image_url?: ImageUrl
  text?: string
}

export interface ChatMessage {
  role: string
  content: string | Array<ContentPart>
}

interface ChatRequestBody {
  model: string
  messages: ChatMessage[]
  stream: boolean
}

export class ApiService {
  static createTextMessage(role: string, content: string): ChatMessage {
    const msg: ChatMessage = { role: role, content: content }
    return msg
  }

  static createVisionMessage(role: string, imageUrl: string, text: string): ChatMessage {
    const imgUrl: ImageUrl = { url: imageUrl }
    const imgPart: ContentPart = { type: 'image_url', image_url: imgUrl }
    const textPart: ContentPart = { type: 'text', text: text }
    const parts: ContentPart[] = [imgPart, textPart]
    const msg: ChatMessage = { role: role, content: parts }
    return msg
  }

  static imageToBase64DataUri(uri: string): string {
    if (uri.startsWith('data:')) return uri

    try {
      const stat: fileIo.Stat = fileIo.statSync(uri)
      const fileSize: number = stat.size
      if (fileSize <= 0) return uri

      const file: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      const arrayBuffer: ArrayBuffer = new ArrayBuffer(fileSize)
      fileIo.readSync(file.fd, arrayBuffer)
      fileIo.closeSync(file)

      const bytes: Uint8Array = new Uint8Array(arrayBuffer)
      const chars: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
      let result: string = ''

      for (let i: number = 0; i < bytes.length; i += 3) {
        const remaining: number = bytes.length - i
        const b1: number = bytes[i]
        const b2: number = remaining >= 2 ? bytes[i + 1] : 0
        const b3: number = remaining >= 3 ? bytes[i + 2] : 0

        result += chars.charAt(b1 >> 2)
        result += chars.charAt(((b1 & 0x03) << 4) | (b2 >> 4))

        if (remaining >= 3) {
          result += chars.charAt(((b2 & 0x0F) << 2) | (b3 >> 6))
          result += chars.charAt(b3 & 0x3F)
        } else if (remaining === 2) {
          result += chars.charAt((b2 & 0x0F) << 2)
          result += '='
        } else {
          result += '=='
        }
      }

      let mimeType: string = 'image/jpeg'
      const lowerUri: string = uri.toLowerCase()
      if (lowerUri.includes('.png')) mimeType = 'image/png'
      else if (lowerUri.includes('.webp')) mimeType = 'image/webp'
      else if (lowerUri.includes('.gif')) mimeType = 'image/gif'

      return 'data:' + mimeType + ';base64,' + result
    } catch (e) {
      console.error('图片转base64失败:', JSON.stringify(e))
      return uri
    }
  }

  static async chat(config: ApiConfig, messages: ChatMessage[], onChunk: (text: string) => void): Promise<void> {
    const httpRequest = http.createHttp()
    const url: string = config.apiUrl.endsWith('/v1/chat/completions')
      ? config.apiUrl
      : config.apiUrl.replace(/\/+$/, '') + '/v1/chat/completions'

    const sysMsg: ChatMessage = ApiService.createTextMessage('system', config.systemPrompt)
    const body: ChatRequestBody = {
      model: config.modelName,
      messages: [sysMsg, ...messages],
      stream: true
    }
    const bodyStr: string = JSON.stringify(body)

    const response = await httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + config.apiKey
      },
      extraData: bodyStr,
      expectDataType: http.HttpDataType.STRING
    })

    const reader: string = response.result as string
    const lines: string[] = reader.split('\n')
    for (const line of lines) {
      if (line.startsWith('data: ')) {
        const data: string = line.substring(6)
        if (data === '[DONE]') break
        try {
          const obj: Record<string, object> = JSON.parse(data)
          const choices = obj.choices as Array<Record<string, object>>
          const firstChoice: Record<string, object> = choices[0]
          const delta: Record<string, string> = firstChoice.delta as Record<string, string>
          const content: string = delta.content
          if (content) onChunk(content)
        } catch {
          continue
        }
      }
    }
    httpRequest.destroy()
  }

  static supportsVision(model: string): boolean {
    const lower: string = model.toLowerCase()
    const visionKeywords: string[] = [
      'gpt-4o',
      'gpt-4-vision',
      'gpt-4-turbo',
      'claude-3',
      'claude-sonnet',
      'claude-opus',
      'qwen-vl',
      'qwen2-vl',
      'qwen2.5-vl',
      'qwen3-vl',
      'qwen3',
      'qwen-max',
      'qwen-plus',
      'qwen-turbo',
      'gemini',
      'pro-vision',
      'glm-4v',
      'cogvlm',
      'minimax-vl',
      'internvl',
      'deepseek-vl',
      'yi-vl',
      'yi-vision',
      'moonshot-v1',
      'vision',
      'vl',
      'visual',
      'ocr'
    ]
    for (const keyword of visionKeywords) {
      if (lower.includes(keyword)) {
        return true
      }
    }
    return false
  }
}