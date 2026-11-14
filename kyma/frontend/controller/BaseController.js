sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/m/MessageBox",
  "uim/kyma/model/formatter"
], function (Controller, UIComponent, MessageBox, formatter) {
  "use strict";

  return Controller.extend("uim.kyma.controller.BaseController", {
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
    },

    /** Invoke an unbound OData action with parameters; resolves with the returned object. */
    invokeAction: function (sAction, mParameters) {
      var oOperation = this.getModel().bindContext("/" + sAction + "(...)");
      Object.keys(mParameters || {}).forEach(function (sName) {
        oOperation.setParameter(sName, mParameters[sName]);
      });
      return oOperation.execute().then(function () {
        return oOperation.getBoundContext().getObject();
      });
    },

    /** Refresh the KPI header (Statistics singleton). */
    refreshStatistics: function () {
      var oHeader = this.byId("kpiHeader");
      var oBinding = oHeader && oHeader.getElementBinding();
      if (oBinding) {
        oBinding.refresh();
      }
    }
  });
});
