sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/routing/History",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "uim/eventmesh/model/formatter"
], function (Controller, UIComponent, History, MessageBox, MessageToast, formatter) {
  "use strict";

  return Controller.extend("uim.eventmesh.controller.BaseController", {
    formatter: formatter,

    getRouter: function () {
      return UIComponent.getRouterFor(this);
    },

    getModel: function (name) {
      return this.getView().getModel(name);
    },

    text: function (key, args) {
      return this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(key, args);
    },

    toast: function (key, args) {
      MessageToast.show(this.text(key, args));
    },

    /** Show the backend error (OData error message or HTTP status). */
    showError: function (error) {
      MessageBox.error((error && error.message) || this.text("unknownError"));
    },

    /** Re-read everything (lists, the Statistics header, the detail page). */
    refreshAll: function () {
      this.getModel().refresh();
    },

    setBusy: function (busy) {
      this.getModel("view").setProperty("/busy", busy);
    },

    /** Invoke an unbound OData action and refresh on success. */
    invokeAction: function (name, parameters) {
      var operation = this.getModel().bindContext("/" + name + "(...)");
      Object.keys(parameters).forEach(function (key) {
        if (parameters[key] !== "" && parameters[key] !== undefined) {
          operation.setParameter(key, parameters[key]);
        }
      });
      this.setBusy(true);
      return operation.execute().then(function () {
        this.refreshAll();
        return operation.getBoundContext().getObject();
      }.bind(this)).finally(function () {
        this.setBusy(false);
      }.bind(this));
    },

    onNavBack: function () {
      if (History.getInstance().getPreviousHash() !== undefined) {
        window.history.go(-1);
      } else {
        this.getRouter().navTo("main", {}, true);
      }
    }
  });
});
