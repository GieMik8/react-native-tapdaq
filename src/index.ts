import { NativeModules } from 'react-native'

export interface TapdaqConfig {
  userSubjectToGDPR?: boolean
  consentGiven?: boolean
  isAgeRestrictedUser?: boolean
}

class RNTapdaq {
  get nativeModule() {
    return NativeModules.RNTapdaq
  }

  public initialise(applicationId: string, clientKey: string, config?: TapdaqConfig): Promise<boolean> {
    if (config) {
      return this.nativeModule.initialiseWithConfig(applicationId, clientKey, config)
    }
    return this.nativeModule.initialise(applicationId, clientKey)
  }

  public isInitialised(): Promise<boolean> {
    return this.nativeModule.isInitialised()
  }

  public startTestActivity(): void {
    this.nativeModule.startTestActivity()
  }
}

export default new RNTapdaq()
