
package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

public class RNBazaarVoiceModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNBazaarVoiceModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNBazaarVoice";
  }
}