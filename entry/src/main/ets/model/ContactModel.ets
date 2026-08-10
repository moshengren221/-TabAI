export class ContactModel {
  id: string
  name: string
  avatar: string
  lastMessage: string
  lastTime: number
  isTop: boolean
  isBlack: boolean
  unreadCount: number

  constructor(name: string = '') {
    this.id = Date.now().toString() + Math.random().toString(36).substring(2)
    this.name = name || '未命名'
    this.avatar = ''
    this.lastMessage = ''
    this.lastTime = Date.now()
    this.isTop = false
    this.isBlack = false
    this.unreadCount = 0
  }
}