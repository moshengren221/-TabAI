import { router } from '@kit.ArkUI'
import { ChatBubble } from '../components/ChatBubble'
import { ChatInputBar } from '../components/ChatInputBar'
import { MessageModel, MessageRole, MessageStatus } from '../model/MessageModel'
import { ChatSession } from '../model/ChatSession'
import { AppConfig } from '../model/AppConfig'
import { PreferencesUtil } from '../common/PreferencesUtil'
import { Constants } from '../common/Constants'
import { ApiService, ChatMessage } from '../common/ApiService'
import { NotificationUtil } from '../common/NotificationUtil'

@Entry
@Component
struct ChatDetailPage {
  @State private config: AppConfig = new AppConfig()
  @State private messages: MessageModel[] = []
  @State private currentSession: ChatSession = new ChatSession('新对话')
  @State private isLoading: boolean = false
  @State private typingTitle: string = ''
  @State private supportImage: boolean = false
  @State private quoteText: string = ''
  @State private contactAvatar: string = ''
  @State private contextCount: number = 0
  @State private isPageVisible: boolean = true
  private safeTop: number = AppStorage.get<number>('safeTop') ?? 0
  private scrollController: Scroller = new Scroller()
  private sessionId: string = ''

  async aboutToAppear(): Promise<void> {
    const params: Record<string, string> = router.getParams() as Record<string, string>
    this.sessionId = params['sessionId'] || ''
    await this.loadConfig()
    await this.loadSession()
    this.updateContextCount()
    NotificationUtil.requestPermission(getContext(this))
  }

  onPageShow(): void {
    this.isPageVisible = true
    this.refreshTitle()
    this.refreshAvatar()
    this.refreshShowThinking()
  }

  onPageHide(): void {
    this.isPageVisible = false
  }

  private updateContextCount(): void {
    let count: number = 0
    for (const m of this.messages) {
      if (m.isContext) count++
    }
    this.contextCount = count
  }

  private toggleContext(msg: MessageModel): void {
    const idx: number = this.messages.findIndex((m: MessageModel) => m.id === msg.id)
    if (idx >= 0) {
      this.messages[idx].isContext = !this.messages[idx].isContext
      this.messages = [...this.messages]
      this.updateContextCount()
    }
  }

  private clearAllContext(): void {
    for (const m of this.messages) {
      m.isContext = false
    }
    this.messages = [...this.messages]
    this.contextCount = 0
  }

  private async refreshTitle(): Promise<void> {
    if (!this.sessionId) return
    try {
      const ctx: Context = getContext(this)
      const json: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
      const sessions: ChatSession[] = JSON.parse(json) as ChatSession[]
      const session: ChatSession | undefined = sessions.find((s: ChatSession) => s.id === this.sessionId)
      if (session) {
        this.currentSession.title = session.title || this.config.aiNickname
        this.typingTitle = session.title || this.config.aiNickname
      }
    } catch (e) {
      // ignore
    }
  }

  private async refreshAvatar(): Promise<void> {
    if (!this.sessionId) return
    try {
      const ctx: Context = getContext(this)
      const json: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
      const sessions: ChatSession[] = JSON.parse(json) as ChatSession[]
      const session: ChatSession | undefined = sessions.find((s: ChatSession) => s.id === this.sessionId)
      if (session) {
        const newAvatar: string = session.customAvatar || ''
        if (newAvatar !== this.contactAvatar) {
          this.contactAvatar = newAvatar
        }
      }
    } catch (e) {
      // ignore
    }
  }

  private async refreshShowThinking(): Promise<void> {
    if (!this.sessionId) return
    try {
      const ctx: Context = getContext(this)
      const json: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
      const sessions: ChatSession[] = JSON.parse(json) as ChatSession[]
      const session: ChatSession | undefined = sessions.find((s: ChatSession) => s.id === this.sessionId)
      if (session) {
        this.currentSession.showThinking = session.showThinking || false
      }
    } catch (e) {
      // ignore
    }
  }

  private async loadConfig(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      const pref: PreferencesUtil = PreferencesUtil.getInstance()

      this.config.aiNickname = await pref.get(ctx, Constants.PREF_PERSONALIZE, 'aiNickname', 'TabAI') as string
      this.config.showThinking = false
      this.config.bubbleUserColor = await pref.get(ctx, Constants.PREF_PERSONALIZE, 'bubbleUserColor', '#95EC69') as string
      this.config.bubbleAiColor = await pref.get(ctx, Constants.PREF_PERSONALIZE, 'bubbleAiColor', '#FFFFFF') as string
      this.config.chatBgUri = await pref.get(ctx, Constants.PREF_PERSONALIZE, 'chatBgUri', '') as string
      this.config.bgBlur = parseFloat(await pref.get(ctx, Constants.PREF_PERSONALIZE, 'bgBlur', '0') as string)
      this.config.aiAvatar = await pref.get(ctx, Constants.PREF_CONFIG, 'aiAvatar', '') as string

      if (this.sessionId) {
        const json: string = await pref.get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
        try {
          const sessions: ChatSession[] = JSON.parse(json) as ChatSession[]
          const session: ChatSession | undefined = sessions.find((s: ChatSession) => s.id === this.sessionId)
          if (session) {
            this.config.modelName = session.modelName || await pref.get(ctx, Constants.PREF_CONFIG, 'modelName', '') as string
            this.config.apiUrl = session.apiUrl || await pref.get(ctx, Constants.PREF_CONFIG, 'apiUrl', '') as string
            this.config.apiKey = session.apiKey || await pref.get(ctx, Constants.PREF_CONFIG, 'apiKey', '') as string
            this.config.systemPrompt = session.systemPrompt || await pref.get(ctx, Constants.PREF_CONFIG, 'systemPrompt', 'You are a helpful assistant.') as string
            this.config.showThinking = session.showThinking || false
            this.contactAvatar = session.customAvatar || ''
          } else {
            this.config.modelName = await pref.get(ctx, Constants.PREF_CONFIG, 'modelName', '') as string
            this.config.apiUrl = await pref.get(ctx, Constants.PREF_CONFIG, 'apiUrl', '') as string
            this.config.apiKey = await pref.get(ctx, Constants.PREF_CONFIG, 'apiKey', '') as string
            this.config.systemPrompt = await pref.get(ctx, Constants.PREF_CONFIG, 'systemPrompt', 'You are a helpful assistant.') as string
          }
        } catch (e) {
          this.config.modelName = await pref.get(ctx, Constants.PREF_CONFIG, 'modelName', '') as string
          this.config.apiUrl = await pref.get(ctx, Constants.PREF_CONFIG, 'apiUrl', '') as string
          this.config.apiKey = await pref.get(ctx, Constants.PREF_CONFIG, 'apiKey', '') as string
          this.config.systemPrompt = await pref.get(ctx, Constants.PREF_CONFIG, 'systemPrompt', 'You are a helpful assistant.') as string
        }
      }

      this.supportImage = ApiService.supportsVision(this.config.modelName)
      this.typingTitle = this.config.aiNickname
    } catch (e) {
      console.error('Load config failed:', JSON.stringify(e))
    }
  }

  private async loadSession(): Promise<void> {
    if (!this.sessionId) return
    try {
      const ctx: Context = getContext(this)
      const json: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
      const sessions: ChatSession[] = JSON.parse(json) as ChatSession[]
      const session: ChatSession | undefined = sessions.find((s: ChatSession) => s.id === this.sessionId)
      if (session) {
        this.currentSession = session
        this.messages = session.messages.map((m: MessageModel) => {
          const msg: MessageModel = new MessageModel(m.role as MessageRole, m.content)
          msg.id = m.id
          msg.timestamp = m.timestamp
          msg.status = m.status as MessageStatus
          msg.quoteRef = m.quoteRef || ''
          msg.isContext = m.isContext || false
          msg.imageUri = m.imageUri || ''
          return msg
        })
        this.typingTitle = session.title || this.config.aiNickname
        this.contactAvatar = session.customAvatar || ''
      }
    } catch (e) {
      console.error('Load session failed:', JSON.stringify(e))
    }
  }

  private async saveSession(): Promise<void> {
    try {
      const ctx: Context = getContext(this)
      const sessionsJson: string = await PreferencesUtil.getInstance().get(ctx, Constants.PREF_SESSIONS, 'list', '[]') as string
      const rawSessions: Array<Record<string, Object>> = JSON.parse(sessionsJson) as Array<Record<string, Object>>
      const idx: number = rawSessions.findIndex((s: Record<string, Object>) => s['id'] === this.sessionId)

      const now: number = Date.now()

      if (idx >= 0) {
        rawSessions[idx]['messages'] = this.messages
        rawSessions[idx]['updateTime'] = now
        if (!rawSessions[idx]['modelName']) {
          rawSessions[idx]['modelName'] = this.config.modelName
        }
        if (!rawSessions[idx]['apiUrl']) {
          rawSessions[idx]['apiUrl'] = this.config.apiUrl
        }
        if (!rawSessions[idx]['apiKey']) {
          rawSessions[idx]['apiKey'] = this.config.apiKey
        }
        if (!rawSessions[idx]['systemPrompt']) {
          rawSessions[idx]['systemPrompt'] = this.config.systemPrompt
        }
        rawSessions[idx]['apiCallCount'] = this.currentSession.apiCallCount || 0
        if (this.messages.length > 0) {
          const lastMsg: MessageModel = this.messages[this.messages.length - 1]
          rawSessions[idx]['lastMessage'] = lastMsg.content.substring(0, 50)
        }
      } else {
        const newSession: Record<string, Object> = {}
        newSession['id'] = this.sessionId
        newSession['title'] = this.config.aiNickname
        newSession['messages'] = this.messages
        newSession['updateTime'] = now
        newSession['createTime'] = now
        newSession['lastMessage'] = this.messages.length > 0 ? this.messages[this.messages.length - 1].content.substring(0, 50) : ''
        newSession['modelName'] = this.config.modelName
        newSession['apiUrl'] = this.config.apiUrl
        newSession['apiKey'] = this.config.apiKey
        newSession['systemPrompt'] = this.config.systemPrompt
        newSession['showThinking'] = false
        newSession['customAvatar'] = ''
        newSession['apiCallCount'] = 0
        rawSessions.unshift(newSession)
      }

      await PreferencesUtil.getInstance().put(ctx, Constants.PREF_SESSIONS, 'list', JSON.stringify(rawSessions.slice(0, 50)))
    } catch (e) {
      console.error('Save session failed:', JSON.stringify(e))
    }
  }

  private buildApiMessages(): ChatMessage[] {
    const apiMsgs: ChatMessage[] = []

    for (const m of this.messages) {
      if (!m.isContext) continue
      if (m.role !== MessageRole.USER && m.role !== MessageRole.ASSISTANT) continue
      const role: string = m.role === MessageRole.USER ? 'user' : 'assistant'
      if (m.imageUri) {
        const dataUri: string = ApiService.imageToBase64DataUri(m.imageUri)
        const msgText: string = m.content && m.content.length > 0 ? m.content : '请描述这张图片'
        apiMsgs.push(ApiService.createVisionMessage(role, dataUri, msgText))
      } else {
        apiMsgs.push(ApiService.createTextMessage(role, m.content))
      }
    }

    for (const m of this.messages) {
      if (m.role !== MessageRole.USER && m.role !== MessageRole.ASSISTANT) continue
      if (m.isContext) continue
      const role: string = m.role === MessageRole.USER ? 'user' : 'assistant'
      if (m.imageUri) {
        const dataUri: string = ApiService.imageToBase64DataUri(m.imageUri)
        const msgText: string = m.content && m.content.length > 0 ? m.content : '请描述这张图片'
        apiMsgs.push(ApiService.createVisionMessage(role, dataUri, msgText))
      } else {
        apiMsgs.push(ApiService.createTextMessage(role, m.content))
      }
    }

    return apiMsgs
  }

  private async sendMessage(text: string, imageUri?: string): Promise<void> {
    if (!text && !imageUri) return
    if (imageUri && !this.supportImage) return

    const userMsg: MessageModel = new MessageModel(MessageRole.USER, text)
    if (imageUri) userMsg.imageUri = imageUri
    if (this.quoteText.length > 0) {
      userMsg.quoteRef = this.quoteText
    }
    this.messages.push(userMsg)
    this.scrollToBottom()

    this.isLoading = true
    this.typingTitle = '正在输入中...'
    this.quoteText = ''

    const apiMsgs: ChatMessage[] = this.buildApiMessages()

    if (this.currentSession.showThinking && apiMsgs.length > 0) {
      const lastApiMsg: ChatMessage = apiMsgs[apiMsgs.length - 1]
      if (lastApiMsg.role === 'user') {
        const hiddenInstruction: string = '请你在回答用户时用不超过10个字的简短语言表达你此刻的想法并跟随在你要回答的内容后面用括号框起来'
        if (typeof lastApiMsg.content === 'string') {
          lastApiMsg.content = lastApiMsg.content + '\n\n[系统指令：' + hiddenInstruction + ']'
        }
      }
    }

    let aiContent: string = ''
    try {
      await ApiService.chat(this.config, apiMsgs, (chunk: string): void => {
        aiContent += chunk
      })
    } catch (e) {
      console.error('API请求失败:', JSON.stringify(e))
      aiContent = '请求失败，请检查网络或API配置'
    }

    const aiMsg: MessageModel = new MessageModel(MessageRole.ASSISTANT, aiContent)
    aiMsg.status = (aiContent === '请求失败，请检查网络或API配置') ? MessageStatus.FAILED : MessageStatus.READ
    this.messages.push(aiMsg)
    this.scrollToBottom()

    if (!this.isPageVisible && aiMsg.status === MessageStatus.READ) {
      const nickname: string = this.currentSession.title || this.config.aiNickname
      const preview: string = aiContent.length > 15
        ? aiContent.substring(0, 15) + '...'
        : aiContent
      const avatar: string = this.contactAvatar || this.config.aiAvatar || ''
      NotificationUtil.send(getContext(this), nickname, preview, this.sessionId, avatar)
    }

    this.isLoading = false
    this.typingTitle = this.currentSession.title || this.config.aiNickname
    this.messages = [...this.messages]
    this.currentSession.apiCallCount = (this.currentSession.apiCallCount || 0) + 1
    await this.saveSession()
  }

  private scrollToBottom(): void {
    setTimeout((): void => this.scrollController.scrollEdge(Edge.Bottom), 100)
  }

  private onQuote(msg: MessageModel): void {
    this.quoteText = msg.content.substring(0, 50)
  }

  private async onRecall(msg: MessageModel): Promise<void> {
    const idx: number = this.messages.findIndex((m: MessageModel) => m.id === msg.id)
    if (idx >= 0) {
      this.messages[idx].content = '已撤回'
      this.messages[idx].canRecall = false
      this.messages = [...this.messages]
      await this.saveSession()
    }
  }

  private async onDelete(msg: MessageModel): Promise<void> {
    const idx: number = this.messages.findIndex((m: MessageModel) => m.id === msg.id)
    if (idx >= 0) {
      this.messages.splice(idx, 1)
      this.messages = [...this.messages]
      this.updateContextCount()
      await this.saveSession()
    }
  }

  private openContactInfo(): void {
    try {
      router.pushUrl({
        url: 'pages/ContactInfoPage',
        params: { sessionId: this.sessionId }
      }).catch((error: Error) => {
        console.error('跳转联系人详情失败:', error)
      })
    } catch (e) {
      console.error('跳转异常:', e)
    }
  }

  private atAI(): void {
    this.quoteText = '@' + this.config.aiNickname
  }

  build() {
    Stack() {
      if (this.config.chatBgUri) {
        Image(this.config.chatBgUri)
          .width('100%').height('100%')
          .objectFit(ImageFit.Cover).blur(this.config.bgBlur)
      }
      Column() {
        // 顶部导航栏
        Row() {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_backward')).fontSize(24).fontColor(['#333333'])
          }
          .type(ButtonType.Circle).backgroundColor('transparent').width(40).height(40)
          .onClick(() => router.back())

          Text(this.typingTitle)
            .fontSize(18).fontWeight(FontWeight.Medium).fontColor('#000000')
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1).textAlign(TextAlign.Center)

          Button() {
            SymbolGlyph($r('sys.symbol.person')).fontSize(22).fontColor(['#333333'])
          }
          .type(ButtonType.Circle).backgroundColor('transparent').width(40).height(40)
          .onClick(() => this.openContactInfo())
        }
        .width('100%').height(48 + this.safeTop)
        .padding({ left: 4, right: 4, top: this.safeTop })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .backgroundBlurStyle(BlurStyle.Regular).backdropBlur(20)
        .position({ x: 0, y: 0 }).zIndex(100)

        // 上下文提示栏
        if (this.contextCount > 0) {
          Row() {
            SymbolGlyph($r('sys.symbol.pin')).fontSize(14).fontColor(['#07C160']).margin({ right: 6 })
            Text(`已选 ${this.contextCount} 条上下文`).fontSize(13).fontColor('#07C160')
            Blank()
            Button('清空').fontSize(13).fontColor('#FF4444').backgroundColor('transparent').height(28)
              .onClick(() => this.clearAllContext())
          }
          .width('100%').height(36).padding({ left: 16, right: 12 }).backgroundColor('#F0FFF0')
        }

        // 消息列表
        List({ scroller: this.scrollController }) {
          ForEach(this.messages, (msg: MessageModel) => {
            ListItem() {
              ChatBubble({
                message: msg,
                aiNickname: this.currentSession.title || this.config.aiNickname,
                aiAvatar: this.contactAvatar,
                bubbleUserColor: this.config.bubbleUserColor,
                bubbleAiColor: this.config.bubbleAiColor,
                showThinking: this.config.showThinking,
                onQuote: (m: MessageModel) => this.onQuote(m),
                onRecall: (m: MessageModel) => this.onRecall(m),
                onDelete: (m: MessageModel) => this.onDelete(m),
                onToggleContext: (m: MessageModel) => this.toggleContext(m),
                onAvatarClick: () => this.openContactInfo(),
                onAvatarLongPress: () => this.atAI()
              })
            }
          })
        }
        .width('100%').height('100%').layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring).scrollBar(BarState.Auto)
        .padding({ top: 48 + this.safeTop })

        // 模型不支持图片的提示
        if (!this.supportImage) {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.info_circle')).fontSize(12).fontColor(['#999999'])
            Text('当前模型不支持图片识别，请切换到支持视觉的模型以发送图片')
              .fontSize(11).fontColor('#999999')
          }
          .width('100%').height(28).padding({ left: 16, right: 16 })
          .backgroundColor('#FFF8E1')
          .justifyContent(FlexAlign.Start)
        }

        // 输入栏
        ChatInputBar({
          supportImage: this.supportImage,
          isLoading: this.isLoading,
          quoteText: this.quoteText,
          onSend: (text: string, img?: string) => this.sendMessage(text, img),
          onCancelQuote: () => { this.quoteText = '' }
        })
      }
      .width('100%').height('100%')
    }
    .width('100%').height('100%')
    .backgroundColor(this.config.chatBgUri ? 'transparent' : '#EDEDED')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}