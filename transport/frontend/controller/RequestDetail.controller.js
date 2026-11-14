sap.ui.define([
  "uim/transport/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/ui/core/routing/History"
], function (BaseController, Filter, FilterOperator, History) {
  "use strict";

  return BaseController.extend("uim.transport.controller.RequestDetail", {

    onInit: function () {
      this.getRouter().getRoute("request").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this._sId = sId;
      var sKey = sId.replace(/'/g, "''");
      this.getView().bindElement({ path: "/TransportRequests('" + sKey + "')" });

      var oFilter = new Filter("requestId", FilterOperator.EQ, sId);
      ["requestQueueTable", "requestActionTable"].forEach(function (sTable) {
        var oBinding = this.byId(sTable).getBinding("items");
        oBinding.filter(oFilter);
        if (oBinding.isSuspended()) {
          oBinding.resume();
        }
      }, this);
    },

    onExport: function () {
      this.callAction("ExportRequest", { requestId: this._sId });
    },

    onRefresh: function () {
      this.getModel().refresh();
    },

    onNavBack: function () {
      if (History.getInstance().getPreviousHash() !== undefined) {
        window.history.go(-1);
      } else {
        this.getRouter().navTo("main", { tab: "requests" }, true);
      }
    }
  });
});
