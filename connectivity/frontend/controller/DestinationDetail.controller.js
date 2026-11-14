sap.ui.define([
  "uim/connectivity/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageToast) {
  "use strict";

  return BaseController.extend("uim.connectivity.controller.DestinationDetail", {

    onInit: function () {
      this.getRouter().getRoute("destination").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this._sId = sId;
      this.getView().bindElement({
        path: "/Destinations('" + sId.replace(/'/g, "''") + "')",
        // complex collections are only shown via formatters, so select them explicitly
        parameters: { $select: "properties,additionalHeaders" }
      });
      var oBinding = this.byId("destinationLogTable").getBinding("items");
      oBinding.filter(new Filter("sourceId", FilterOperator.EQ, sId));
      if (oBinding.isSuspended()) {
        oBinding.resume();
      }
    },

    /** Run the connection check (CheckDestination) and show the outcome. */
    onCheck: function () {
      this.getModel("ui").setProperty("/busy", true);
      this.invokeAction("CheckDestination", { id: this._sId }).then(function (oResult) {
        MessageToast.show(this.getText("checkDone", [this.formatter.enumText(oResult.status), oResult.statusMessage]));
        this.getView().getElementBinding().refresh();
        this.byId("destinationLogTable").getBinding("items").refresh();
      }.bind(this), this.showError.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    },

    onClose: function () {
      this.getRouter().navTo("main", { tab: "destinations" });
    }
  });
});
