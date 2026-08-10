import notificationManager from '@ohos.notificationManager'
import { common, wantAgent, Want } from '@kit.AbilityKit'
import { image } from '@kit.ImageKit'
import { WantAgent } from '@kit.AbilityKit'

export class NotificationUtil {
  private static nextId: number = 1001

  static async requestPermission(context: Context): Promise<void> {
    try {
      const abilityContext: common.UIAbilityContext = context as common.UIAbilityContext
      await notificationManager.requestEnableNotification(abilityContext)
    } catch (e) {
      console.error('请求通知权限失败:', JSON.stringify(e))
    }
  }

  private static async loadPixelMapFromResource(context: Context, res: Resource): Promise<image.PixelMap> {
    const buffer: Uint8Array = await context.resourceManager.getMediaContent(res)
    const imgSource: image.ImageSource = image.createImageSource(buffer.buffer)
    const pixelMap: image.PixelMap = await imgSource.createPixelMap()
    return pixelMap
  }

  private static async loadPixelMapFromUri(uri: string): Promise<image.PixelMap> {
    const imgSource: image.ImageSource = image.createImageSource(uri)
    const pixelMap: image.PixelMap = await imgSource.createPixelMap()
    return pixelMap
  }

  /**
   * 创建点击通知后跳转到聊天页面的 WantAgent
   */
  private static async createClickAgent(sessionId: string): Promise<WantAgent> {
    const want: Want = {
      bundleName: 'com.zhishitab.aichat',
      abilityName: 'EntryAbility',
      uri: 'pages/ChatDetailPage',
      parameters: {
        sessionId: sessionId
      }
    } as Want

    const agentInfo: wantAgent.WantAgentInfo = {
      wants: [want],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: NotificationUtil.nextId,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    } as wantAgent.WantAgentInfo

    const agent: WantAgent = await wantAgent.getWantAgent(agentInfo)
    return agent
  }

  /**
   * 发送一条系统通知（带点击跳转）
   */
  static async send(context: Context, title: string, text: string, sessionId: string, avatarUri?: string): Promise<void> {
    try {
      const id: number = NotificationUtil.nextId++

      const normalContent: notificationManager.NotificationBasicContent = {
        title: title,
        text: text
      } as notificationManager.NotificationBasicContent

      const content: notificationManager.NotificationContent = {
        contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: normalContent
      } as notificationManager.NotificationContent

      const request: notificationManager.NotificationRequest = {
        id: id,
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        content: content
      } as notificationManager.NotificationRequest

      // 点击通知跳转到聊天页面
      try {
        const clickAgent: WantAgent = await NotificationUtil.createClickAgent(sessionId)
        request.wantAgent = clickAgent
      } catch (e) {
        console.error('创建WantAgent失败:', JSON.stringify(e))
      }

      // 小图标 = 应用图标
      try {
        request.smallIcon = await NotificationUtil.loadPixelMapFromResource(context, $r('app.media.app_icon'))
      } catch (e) {
        console.error('加载小图标失败:', JSON.stringify(e))
      }

      // 大图标 = AI头像
      try {
        if (avatarUri && avatarUri.length > 0) {
          request.largeIcon = await NotificationUtil.loadPixelMapFromUri(avatarUri)
        } else {
          request.largeIcon = await NotificationUtil.loadPixelMapFromResource(context, $r('app.media.touxiang'))
        }
      } catch (e) {
        try {
          request.largeIcon = await NotificationUtil.loadPixelMapFromResource(context, $r('app.media.touxiang'))
        } catch (fe) {
          // 放弃图标
        }
      }

      await notificationManager.publish(request)
    } catch (e) {
      console.error('发送通知失败:', JSON.stringify(e))
    }
  }
}