
# react-native-bazaar-voice

## Getting started

`$ npm install react-native-bazaar-voice --save`

### Mostly automatic installation

`$ react-native link react-native-bazaar-voice`

### After automatic, do Android

	Paste this in your `MainApplication.java`:

	```java

	import com.bazaarvoice.bvandroidsdk.BVLogLevel;
	import com.bazaarvoice.bvandroidsdk.BVSDK;
	import com.bazaarvoice.bvandroidsdk.BazaarEnvironment;

	// (...)
	@Override
    public void onCreate() {
		// (...)
		BVSDK.builder(this, BazaarEnvironment.STAGING)
					.logLevel(BVLogLevel.ERROR)
					.dryRunAnalytics(false)
					.build();
	}
	```

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-bazaar-voice` and add `RNBazaarVoice.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNBazaarVoice.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNBazaarVoicePackage;` to the imports at the top of the file
  - Add `new RNBazaarVoicePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-bazaar-voice'
  	project(':react-native-bazaar-voice').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-bazaar-voice/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-bazaar-voice')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNBazaarVoice.sln` in `node_modules/react-native-bazaar-voice/windows/RNBazaarVoice.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Com.Reactlibrary.RNBazaarVoice;` to the usings at the top of the file
  - Add `new RNBazaarVoicePackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNBazaarVoice from 'react-native-bazaar-voice';

// TODO: What to do with the module?
RNBazaarVoice;
```
  