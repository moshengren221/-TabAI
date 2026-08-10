import { MessageModel } from './MessageModel'

export class ChatSession {
  id: string
  customAvatar: string = ''
  title: string
  messages: MessageModel[]
  updateTime: number
  isTop: boolean
  isBlacklisted: boolean
  lastMessage: string
  modelName: string
  apiUrl: string
  apiKey: string
  systemPrompt: string
  apiCallCount: number = 0
  showThinking: boolean = false
  chatBgUri: string = ''
  bgBlur: number = 0

  constructor(title: string = '新对话') {
    this.id = Date.now().toString() + Math.random().toString(36).substr(2, 9)
    this.customAvatar = ''
    this.title = title
    this.messages = []
    this.updateTime = Date.now()
    this.isTop = false
    this.isBlacklisted = false
    this.lastMessage = ''
    this.modelName = ''
    this.apiUrl = ''
    this.apiKey = ''
    this.systemPrompt = 'You are a helpful assistant.'
    this.apiCallCount = 0
    this.showThinking = false
    this.chatBgUri = ''
    this.bgBlur = 0
  }
}