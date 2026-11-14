sap.ui.define([
  "uim/authorization/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageToast) {
  "use strict";

  return BaseController.extend("uim.authorization.controller.ApplicationDetail", {

    onInit: function () {
      this.getRouter().getRoute("application").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      this._sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this.getView().bindElement({
        path: "/Applications('" + this._sId.replace(/'/g, "''") + "')",
        parameters: { $$updateGroupId: "applicationEdit" }
      });
      var oByApp = new Filter("applicationId", FilterOperator.EQ, this._sId);
      ["apiTable", "appPolicyTable"].forEach(function (sTable) {
        var oBinding = this.byId(sTable).getBinding("items");
        oBinding.filter(oByApp, "Application");
        if (oBinding.isSuspended()) { oBinding.resume(); }
      }.bind(this));
    },

    onNavBack: function () {
      this.navBack("applications");
    },

    onSave: function () {
      this.getModel().submitBatch("applicationEdit").then(function () {
        if (!this.getModel().hasPendingChanges("applicationEdit")) {
          MessageToast.show(this.getText("saved"));
        }
      }.bind(this), this.showError.bind(this));
    },

    onCancel: function () {
      this.getModel().resetChanges("applicationEdit");
    },

    onSeedBase: function () {
      this.callAction("SeedBasePolicies", { application: this._sId }).catch(function () { /* shown */ });
    },

    onDelete: function () {
      this.confirmDelete(this.getView().getBindingContext(), this.getText("deleteApplicationQuestion"),
        this.onNavBack.bind(this));
    },

    onCreateApi: function () {
      this.openCreateDialog("ApplicationApis", this.byId("apiTable").getBinding("items"), { applicationId: this._sId });
    },

    onDeleteApi: function () {
      var oItem = this.byId("apiTable").getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectRow"));
        return;
      }
      this.confirmDelete(oItem.getBindingContext(), this.getText("deleteQuestion"));
    },

    onCreatePolicy: function () {
      this.openCreateDialog("Policies", this.byId("appPolicyTable").getBinding("items"), { applicationId: this._sId });
    },

    onPolicyPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("policy", { id: encodeURIComponent(sId) });
    }
  });
});
