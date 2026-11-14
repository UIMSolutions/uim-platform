sap.ui.define([
  "uim/abap/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageToast) {
  "use strict";

  /** Child tables and the property that references the system. */
  var TABLES = {
    envComponentTable: "systemInstanceId",
    envBindingTable: "systemInstanceId",
    envArrangementTable: "systemInstanceId",
    envUserTable: "systemInstanceId",
    envRoleTable: "systemInstanceId",
    envTransportTable: "sourceSystemId",
    envJobTable: "systemInstanceId"
  };

  return BaseController.extend("uim.abap.controller.SystemDetail", {

    onInit: function () {
      this.getRouter().getRoute("system").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this._sId = sId;
      this.getView().bindElement({ path: "/Systems('" + sId.replace(/'/g, "''") + "')" });
      Object.keys(TABLES).forEach(function (sTable) {
        var oBinding = this.byId(sTable).getBinding("items");
        oBinding.filter(new Filter(TABLES[sTable], FilterOperator.EQ, sId));
        if (oBinding.isSuspended()) {
          oBinding.resume();
        }
      }, this);
    },

    onSystemAction: function (sAction, sParameters) {
      this.askParameters(this.getText("action_" + sAction), sParameters).then(function (mParameters) {
        mParameters.id = this._sId;
        return this.invokeAction(sAction, mParameters).then(function (oResult) {
          MessageToast.show(this.getText("actionDone", [oResult.name, this.formatter.enumText(oResult.status)]));
          this.getView().getElementBinding().refresh();
        }.bind(this));
      }.bind(this)).catch(function (oError) {
        if (!oError || !oError.canceled) {
          this.showError(oError);
        }
      }.bind(this));
    },

    onClose: function () {
      this.getRouter().navTo("main", { tab: "systems" });
    }
  });
});
