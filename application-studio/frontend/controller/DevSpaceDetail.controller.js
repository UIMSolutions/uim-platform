sap.ui.define([
  "uim/studio/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageToast) {
  "use strict";

  /** Child tables of the object page (all reference the dev space by devSpaceId). */
  var TABLES = ["dsProjectTable", "dsBindingTable", "dsRunTable", "dsBuildTable"];

  return BaseController.extend("uim.studio.controller.DevSpaceDetail", {

    onInit: function () {
      this.getRouter().getRoute("devSpace").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this._sId = sId;
      this.getView().bindElement({ path: "/DevSpaces('" + sId.replace(/'/g, "''") + "')" });
      TABLES.forEach(function (sTable) {
        var oBinding = this.byId(sTable).getBinding("items");
        oBinding.filter(new Filter("devSpaceId", FilterOperator.EQ, sId));
        if (oBinding.isSuspended()) {
          oBinding.resume();
        }
      }, this);
    },

    _refresh: function () {
      this.getView().getElementBinding().refresh();
      TABLES.forEach(function (sTable) {
        this.byId(sTable).getBinding("items").refresh();
      }, this);
    },

    onDevSpaceAction: function (sAction, sParameters) {
      this.askParameters(this.getText("action_" + sAction), sParameters).then(function (mParameters) {
        mParameters.id = this._sId;
        return this.invokeAction(sAction, mParameters).then(function (oResult) {
          MessageToast.show(this.getText("actionDone", [oResult.name, this.formatter.enumText(oResult.status)]));
          this._refresh();
        }.bind(this));
      }.bind(this)).catch(function (oError) {
        if (!oError || !oError.canceled) {
          this.showError(oError);
        }
      }.bind(this));
    },

    /** Record the access (postpones hibernation / resumes) and open the workspace URL. */
    onOpen: function () {
      this.invokeAction("TouchDevSpace", { id: this._sId }).then(function (oResult) {
        this._refresh();
        if (oResult.url && oResult.status === "running") {
          window.open(oResult.url, "_blank", "noopener");
        } else {
          MessageToast.show(this.getText("actionDone", [oResult.name, this.formatter.enumText(oResult.status)]));
        }
      }.bind(this), this.showError.bind(this));
    },

    onClose: function () {
      this.getRouter().navTo("main", { tab: "devSpaces" });
    }
  });
});
