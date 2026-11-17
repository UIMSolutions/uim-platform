sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "sap/m/Dialog",
  "sap/m/Button",
  "sap/m/Label",
  "sap/m/Input",
  "sap/m/VBox",
  "uim/workzone/model/formatter",
  "uim/workzone/model/service"
], function (Controller, UIComponent, MessageBox, MessageToast, Dialog, Button, Label, Input, VBox, formatter, Service) {
  "use strict";

  return Controller.extend("uim.workzone.controller.BaseController", {
    formatter: formatter,

    getRouter: function () {
      return UIComponent.getRouterFor(this);
    },

    getModel: function (sName) {
      return this.getView().getModel(sName) || this.getOwnerComponent().getModel(sName);
    },

    getText: function (sKey, aArgs) {
      var oBundle = this.getOwnerComponent().getModel("i18n").getResourceBundle();
      return oBundle.hasText(sKey) ? oBundle.getText(sKey, aArgs) : sKey;
    },

    /** The OData write client (shared per component). */
    service: function () {
      var oComponent = this.getOwnerComponent();
      if (!oComponent._oService) {
        oComponent._oService = new Service(oComponent.getServiceUrl());
      }
      return oComponent._oService;
    },

    /** The catalogue entry of an entity set (undefined until loaded). */
    resourceOf: function (sSet) {
      var oCatalog = this.getModel("catalog");
      return oCatalog && oCatalog.getProperty("/bySet/" + sSet);
    },

    /** Show a backend error (OData error payload or exception). */
    showError: function (oError) {
      if (oError && oError.canceled) {
        return;
      }
      var sMessage = (oError && (oError.message || oError.statusText)) || String(oError);
      MessageBox.error(sMessage);
    },

    /** Run a write call with busy indicator, then refresh all bindings. */
    run: function (pCall, sSuccess) {
      var oUi = this.getModel("ui");
      oUi.setProperty("/busy", true);
      return pCall.then(function (oResult) {
        if (sSuccess) {
          MessageToast.show(sSuccess);
        }
        this.getModel().refresh();
        return oResult;
      }.bind(this)).catch(this.showError.bind(this)).finally(function () {
        oUi.setProperty("/busy", false);
      });
    },

    /**
     * Ask for action parameters (["userId", "role"]) and resolve with
     * { name: value }. Resolves immediately when there are none; rejects on cancel.
     */
    askParameters: function (sTitle, aNames) {
      aNames = aNames || [];
      if (!aNames.length) {
        return Promise.resolve({});
      }
      var that = this;
      return new Promise(function (resolve, reject) {
        var mInputs = {};
        var aItems = [];
        aNames.forEach(function (sName) {
          var oInput = new Input({ placeholder: that.getText("param_" + sName + "_hint") });
          mInputs[sName] = oInput;
          aItems.push(new Label({ text: that.getText("param_" + sName), labelFor: oInput }), oInput);
        });
        var bDone = false;
        var oDialog = new Dialog({
          title: sTitle,
          contentWidth: "26rem",
          content: [new VBox({ items: aItems }).addStyleClass("sapUiSmallMargin")],
          beginButton: new Button({ text: that.getText("ok"), type: "Emphasized", press: function () {
            var mValues = {};
            aNames.forEach(function (sName) {
              var sValue = mInputs[sName].getValue().trim();
              if (sValue) {
                mValues[sName] = sValue;
              }
            });
            bDone = true;
            oDialog.close();
            resolve(mValues);
          } }),
          endButton: new Button({ text: that.getText("cancel"), press: function () { oDialog.close(); } }),
          afterClose: function () {
            oDialog.destroy();
            if (!bDone) {
              reject({ canceled: true });
            }
          }
        });
        that.getView().addDependent(oDialog);
        oDialog.open();
      });
    }
  });
});
