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
    public void initialise(String applicationId, String clientKey, Promise promise) {
        new RNTapdaqInitialiser(getCurrentActivity(), applicationId, clientKey, promise);
    }

    @ReactMethod
    public void initialiseWithConfig(String applicationId, String clientKey, ReadableMap config, Promise promise) {
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
                    Log.d(TAG, String.format("Unknown config key (%s) passed to initialise()", key));
            }
        }
        new RNTapdaqInitialiser(getCurrentActivity(), applicationId, clientKey, tapdaqConfig, promise);
    }

    @ReactMethod
    public void isInitialised(Promise promise) {
        promise.resolve(Tapdaq.getInstance().IsInitialised());
    }

    @ReactMethod
    public void startTestActivity() {
        Tapdaq.getInstance().startTestActivity(getCurrentActivity());
    }

}
