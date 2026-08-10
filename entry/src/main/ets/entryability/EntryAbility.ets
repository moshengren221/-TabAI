import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { window, display } from '@kit.ArkUI'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate<string>('app_name', '智识TabAI')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    try {
      const win = windowStage.getMainWindowSync()
      // 全屏沉浸
      win.setWindowLayoutFullScreen(true)
      // 状态栏透明背景
      const systemBarProperties: window.SystemBarProperties = {
        statusBarColor: '#00000000',
        statusBarContentColor: '#000000'
      }
      win.setWindowSystemBarProperties(systemBarProperties)

      const top = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect
      const bottom = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect

      let density = 1
      try {
        const disp = display.getDefaultDisplaySync()
        density = disp.densityDPI / 160
      } catch (e) {
        console.error('Display error:', JSON.stringify(e))
      }

      AppStorage.setOrCreate<number>('safeTop', top.height / density)
      AppStorage.setOrCreate<number>('safeBottom', bottom.height / density)
    } catch (e) {
      console.error('Window setup error:', JSON.stringify(e))
    }

    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err) {
        console.error('Failed to load content', JSON.stringify(err))
      }
    })
  }
}