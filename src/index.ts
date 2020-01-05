import { NativeModules } from 'react-native'

class RNTapdaq {
  get nativeModule() {
    return NativeModules.RNTapdaq
  }

  public initialise(applicationId: string, clientKey: string): Promise<boolean> {
    return this.nativeModule.initialise(applicationId, clientKey)
  }

  public startTestActivity(): void {
    this.nativeModule.startTestActivity()
  }
}

export default new RNTapdaq()
