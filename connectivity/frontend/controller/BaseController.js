sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/m/MessageBox",
  "sap/m/Dialog",
  "sap/m/Button",
  "sap/m/Label",
  "sap/m/Input",
  "sap/m/VBox",
  "uim/connectivity/model/formatter"
], function (Controller, UIComponent, MessageBox, Dialog, Button, Label, Input, VBox, formatter) {
  "use strict";

  return Controller.extend("uim.connectivity.controller.BaseController", {
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

    /**
     * Ask for the action parameters ("connector,url") and resolve with
     * { name: value }; mDefaults pre-fills the inputs. Resolves immediately when
     * there are none; rejects on cancel.
     */
    askParameters: function (sTitle, sParameters, mDefaults) {
      var aNames = (sParameters || "").split(",").map(function (s) { return s.trim(); }).filter(Boolean);
      if (!aNames.length) {
        return Promise.resolve({});
      }
      var that = this;
      return new Promise(function (resolve, reject) {
        var mInputs = {};
        var aItems = [];
        aNames.forEach(function (sName) {
          var oInput = new Input({ value: (mDefaults || {})[sName] || "", placeholder: that.getText("param_" + sName + "_hint") });
          mInputs[sName] = oInput;
          aItems.push(new Label({ text: that.getText("param_" + sName), labelFor: oInput }), oInput);
        });
        var bDone = false;
        var oDialog = new Dialog({
          title: sTitle,
          contentWidth: "28rem",
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
