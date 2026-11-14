sap.ui.define([
  "uim/kyma/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageToast) {
  "use strict";

  var TABLES = ["envModuleTable", "envNamespaceTable", "envApplicationTable"];

  return BaseController.extend("uim.kyma.controller.EnvironmentDetail", {

    onInit: function () {
      this.getRouter().getRoute("environment").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this._sId = sId;
      this.getView().bindElement({ path: "/Environments('" + sId.replace(/'/g, "''") + "')" });
      var oFilter = new Filter("environmentId", FilterOperator.EQ, sId);
      TABLES.forEach(function (sTable) {
        var oBinding = this.byId(sTable).getBinding("items");
        oBinding.filter(oFilter);
        if (oBinding.isSuspended()) {
          oBinding.resume();
        }
      }, this);
    },

    onEnvironmentAction: function (sAction) {
      this.invokeAction(sAction, { id: this._sId }).then(function (oResult) {
        MessageToast.show(this.getText("actionDone", [oResult.name, this.formatter.enumText(oResult.status)]));
        this.getView().getElementBinding().refresh();
      }.bind(this), this.showError.bind(this));
    },

    onClose: function () {
      this.getRouter().navTo("main", { tab: "environments" });
    }
  });
});
