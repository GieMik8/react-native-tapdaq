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

  public setConsentGiven(value: boolean) {
    this.nativeModule.setConsentGiven(value)
  }

  public setIsAgeRestrictedUser(value: boolean) {
    this.nativeModule.setIsAgeRestrictedUser(value)
  }

  public setUserSubjectToGDPR(value: boolean) {
    this.nativeModule.setUserSubjectToGDPR(value)
  }

  public setUserId(id: string) {
    this.nativeModule.setUserId(id)
  }
}

export default new RNTapdaq()
