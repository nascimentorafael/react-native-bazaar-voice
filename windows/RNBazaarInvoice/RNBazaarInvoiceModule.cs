using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Com.Reactlibrary.RNBazaarInvoice
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNBazaarInvoiceModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNBazaarInvoiceModule"/>.
        /// </summary>
        internal RNBazaarInvoiceModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNBazaarInvoice";
            }
        }
    }
}
