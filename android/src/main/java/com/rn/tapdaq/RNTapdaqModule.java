package com.rn.tapdaq;

import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.tapdaq.sdk.Tapdaq;

public class RNTapdaqModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private String TAG = this.getName();

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
        Log.d(TAG, String.format("Initializing Tapdaq: applicationdId - %s, clientKey - %s", applicationId, clientKey));
        new RNTapdaqInitialiser(getCurrentActivity(), applicationId, clientKey, promise);
    }

    @ReactMethod
    public void startTestActivity() {
        Tapdaq.getInstance().startTestActivity(getCurrentActivity());
    }

}
