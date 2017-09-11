
# react-native-bazaar-invoice

## Getting started

`$ npm install react-native-bazaar-invoice --save`

### Mostly automatic installation

`$ react-native link react-native-bazaar-invoice`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-bazaar-invoice` and add `RNBazaarInvoice.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNBazaarInvoice.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNBazaarInvoicePackage;` to the imports at the top of the file
  - Add `new RNBazaarInvoicePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-bazaar-invoice'
  	project(':react-native-bazaar-invoice').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-bazaar-invoice/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-bazaar-invoice')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNBazaarInvoice.sln` in `node_modules/react-native-bazaar-invoice/windows/RNBazaarInvoice.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Com.Reactlibrary.RNBazaarInvoice;` to the usings at the top of the file
  - Add `new RNBazaarInvoicePackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNBazaarInvoice from 'react-native-bazaar-invoice';

// TODO: What to do with the module?
RNBazaarInvoice;
```
  