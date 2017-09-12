using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Com.Reactlibrary.RNBazaarVoice
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNBazaarVoiceModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNBazaarVoiceModule"/>.
        /// </summary>
        internal RNBazaarVoiceModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNBazaarVoice";
            }
        }
    }
}
