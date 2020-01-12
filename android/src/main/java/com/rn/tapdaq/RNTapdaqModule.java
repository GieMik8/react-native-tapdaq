package com.rn.tapdaq;

import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.tapdaq.sdk.STATUS;
import com.tapdaq.sdk.Tapdaq;
import com.tapdaq.sdk.TapdaqConfig;

public class RNTapdaqModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private String TAG = this.getName();

    private static final String KEY_USER_SUBJECT_TO_GDPR = "userSubjectToGDPR";
    private static final String KEY_CONSENT_GIVEN = "consentGiven";
    private static final String KEY_IS_AGE_RESTRICTED_USER = "isAgeRestrictedUser";

    public RNTapdaqModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNTapdaq";
    }

    @ReactMethod
    public void initialize(String applicationId, String clientKey, Promise promise) {
        new RNTapdaqInitializer(getCurrentActivity(), applicationId, clientKey, promise);
    }

    @ReactMethod
    public void initializeWithConfig(String applicationId, String clientKey, ReadableMap config, Promise promise) {
        TapdaqConfig tapdaqConfig = new TapdaqConfig();
        ReadableMapKeySetIterator iterator = config.keySetIterator();
        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            Boolean value = config.getBoolean(key);
            switch (key) {
                case KEY_CONSENT_GIVEN:
                    tapdaqConfig.setConsentStatus(value ? STATUS.TRUE : STATUS.FALSE);
                    break;
                case KEY_IS_AGE_RESTRICTED_USER:
                    tapdaqConfig.setAgeRestrictedUserStatus(value ? STATUS.TRUE : STATUS.FALSE);
                    break;
                case KEY_USER_SUBJECT_TO_GDPR:
                    tapdaqConfig.setUserSubjectToGDPR(value ? STATUS.TRUE : STATUS.FALSE);
                    break;
                default:
                    Log.d(TAG, String.format("Unknown config key (%s) passed to initialize()", key));
            }
        }
        new RNTapdaqInitializer(getCurrentActivity(), applicationId, clientKey, tapdaqConfig, promise);
    }

    @ReactMethod
    public void isInitialized(Promise promise) {
        promise.resolve(Tapdaq.getInstance().IsInitialised());
    }

    @ReactMethod
    public void openTestControls() {
        Tapdaq.getInstance().startTestActivity(getCurrentActivity());
    }

    @ReactMethod
    public void setConsentGiven(Boolean value) {
        Tapdaq.getInstance().setContentGiven(getCurrentActivity(), value);
    }

    @ReactMethod
    public void setIsAgeRestrictedUser(Boolean value) {
        Tapdaq.getInstance().setIsAgeRestrictedUser(getCurrentActivity(), value);
    }

    @ReactMethod
    public void setUserSubjectToGDPR(Boolean value) {
        Tapdaq.getInstance().setUserSubjectToGDPR(getCurrentActivity(), value ? STATUS.TRUE : STATUS.FALSE);
    }

    @ReactMethod
    public void setUserId(String userId) {
        Tapdaq.getInstance().setUserId(getCurrentActivity(), userId);
    }

}
