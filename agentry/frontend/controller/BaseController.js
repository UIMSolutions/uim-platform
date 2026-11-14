sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/m/MessageBox",
  "uim/agentry/model/formatter"
], function (Controller, UIComponent, MessageBox, formatter) {
  "use strict";

  return Controller.extend("uim.agentry.controller.BaseController", {
    formatter: formatter,

    getRouter: function () {
      return UIComponent.getRouterFor(this);
    },

    getModel: function (sName) {
      return this.getView().getModel(sName);
    },

    getText: function (sKey, aArgs) {
      return this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(sKey, aArgs);
    },

    /** Show an OData / backend error. */
    showError: function (oError) {
      var sMessage = (oError && (oError.message || oError.statusText)) || String(oError);
      MessageBox.error(sMessage);
    }
  });
});
