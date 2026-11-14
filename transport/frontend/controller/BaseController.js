sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "uim/transport/model/formatter"
], function (Controller, UIComponent, MessageBox, MessageToast, formatter) {
  "use strict";

  return Controller.extend("uim.transport.controller.BaseController", {
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

    /**
     * Invoke an unbound OData action (ExportRequest, ImportNode, ...).
     * Resolves with the OperationResult; shows a toast (or a warning if imports failed).
     */
    callAction: function (sAction, mParameters) {
      var oUi = this.getModel("ui");
      var oOperation = this.getModel().bindContext("/" + sAction + "(...)");
      Object.keys(mParameters || {}).forEach(function (sName) {
        oOperation.setParameter(sName, mParameters[sName]);
      });
      oUi.setProperty("/busy", true);
      return oOperation.execute().then(function () {
        var oResult = oOperation.getBoundContext().getObject() || {};
        if (oResult.failed > 0) {
          MessageBox.warning(oResult.message);
        } else {
          MessageToast.show(oResult.message || sAction);
        }
        this.getModel().refresh();
        return oResult;
      }.bind(this)).catch(function (oError) {
        this.showError(oError);
        throw oError;
      }.bind(this)).finally(function () {
        oUi.setProperty("/busy", false);
      });
    }
  });
});
