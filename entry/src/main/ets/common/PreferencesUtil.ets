import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

export class PreferencesUtil {
  private static instance: PreferencesUtil;
  private prefMap: Map<string, preferences.Preferences> = new Map();

  static getInstance(): PreferencesUtil {
    if (!PreferencesUtil.instance) {
      PreferencesUtil.instance = new PreferencesUtil();
    }
    return PreferencesUtil.instance;
  }

  async getPref(context: Context, name: string): Promise<preferences.Preferences> {
    if (this.prefMap.has(name)) {
      return this.prefMap.get(name)!;
    }
    const pref = await preferences.getPreferences(context, name);
    this.prefMap.set(name, pref);
    return pref;
  }

  async put(context: Context, prefName: string, key: string, value: preferences.ValueType): Promise<void> {
    const pref = await this.getPref(context, prefName);
    await pref.put(key, value);
    await pref.flush();
  }

  async get(context: Context, prefName: string, key: string, def?: preferences.ValueType): Promise<preferences.ValueType> {
    const pref = await this.getPref(context, prefName);
    return await pref.get(key, def ?? '');
  }

  async delete(context: Context, prefName: string, key: string): Promise<void> {
    const pref = await this.getPref(context, prefName);
    await pref.delete(key);
    await pref.flush();
  }
}