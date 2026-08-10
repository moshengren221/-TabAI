export enum MessageRole {
  USER = 'user',
  ASSISTANT = 'assistant'
}

export enum MessageStatus {
  SENDING = 'sending',
  SENT = 'sent',
  READ = 'read',
  FAILED = 'failed'
}

export class MessageModel {
  id: string;
  role: MessageRole;
  content: string;
  thinking?: string;
  timestamp: number;
  status: MessageStatus;
  imageUri?: string;
  quoteRef?: string;
  canRecall: boolean = true;
  isContext: boolean = false;

  constructor(role: MessageRole, content: string) {
    this.id = Date.now().toString() + Math.random().toString(36).substring(2, 8);
    this.role = role;
    this.content = content;
    this.timestamp = Date.now();
    this.status = MessageStatus.SENT;
    this.isContext = false;
  }
}