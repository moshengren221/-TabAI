import { ApiConfig } from '../common/ApiService'

export class AppConfig implements ApiConfig {
  modelName: string = ''
  systemPrompt: string = 'You are a helpful assistant.'
  apiUrl: string = ''
  apiKey: string = ''
  aiAvatar: string = ''
  aiNickname: string = 'TabAI'
  showThinking: boolean = false
  bubbleUserColor: string = '#007DFF'
  bubbleAiColor: string = '#E8E8E8'
  chatBgUri: string = ''
  bgBlur: number = 0
  checkUpdateUrl: string = ''
}