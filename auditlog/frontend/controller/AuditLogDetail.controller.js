sap.ui.define([
  "uim/auditlog/controller/BaseController",
  "sap/ui/core/routing/History"
], function (BaseController, History) {
  "use strict";

  return BaseController.extend("uim.auditlog.controller.AuditLogDetail", {
    onInit: function () {
      this.getRouter().getRoute("auditLog").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this.getView().bindElement({
        path: "/AuditLogs('" + sId.replace(/'/g, "''") + "')",
        events: {
          dataRequested: function () { this.getView().setBusy(true); }.bind(this),
          dataReceived: function (oEvt) {
            this.getView().setBusy(false);
            if (oEvt.getParameter("error")) {
              this.showError(oEvt.getParameter("error"));
            }
          }.bind(this)
        }
      });
    },

    onNavBack: function () {
      if (History.getInstance().getPreviousHash() !== undefined) {
        window.history.go(-1);
      } else {
        this.getRouter().navTo("main", { tab: "logs" }, true);
      }
    }
  });
});
