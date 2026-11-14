sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/routing/History",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "uim/taskcenter/model/formatter"
], function (Controller, UIComponent, History, MessageBox, MessageToast, formatter) {
  "use strict";

  return Controller.extend("uim.taskcenter.controller.BaseController", {
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

    /** Invoke an unbound OData action; resolves with its result and refreshes. */
    invokeAction: function (name, parameters) {
      var operation = this.getModel().bindContext("/" + name + "(...)");
      Object.keys(parameters || {}).forEach(function (key) {
        if (parameters[key] !== "" && parameters[key] !== undefined && parameters[key] !== null) {
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

    /** PerformTaskAction with a toast on success. */
    performTaskAction: function (taskId, action, extra) {
      var parameters = Object.assign({ taskId: taskId, action: action }, extra || {});
      return this.invokeAction("PerformTaskAction", parameters).then(function (task) {
        this.toast("actionDone", [this.formatter.enumText(action), task.title, this.formatter.enumText(task.status)]);
        return task;
      }.bind(this), function (error) {
        this.showError(error);
        throw error;
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
