sap.ui.define([
  "uim/authorization/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageToast) {
  "use strict";

  return BaseController.extend("uim.authorization.controller.PolicyDetail", {

    onInit: function () {
      this.getRouter().getRoute("policy").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      this._sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this.getView().bindElement({
        path: "/Policies('" + this._sId.replace(/'/g, "''") + "')",
        parameters: { $$updateGroupId: "policyEdit" }
      });
      var oBinding = this.byId("policyAssignmentTable").getBinding("items");
      oBinding.filter(new Filter("policyId", FilterOperator.EQ, this._sId), "Application");
      if (oBinding.isSuspended()) { oBinding.resume(); }
    },

    onNavBack: function () {
      this.navBack("policies");
    },

    onApplicationPress: function () {
      var sId = this.getView().getBindingContext().getProperty("applicationId");
      this.getRouter().navTo("application", { id: encodeURIComponent(sId) });
    },

    onSave: function () {
      this.getModel().submitBatch("policyEdit").then(function () {
        if (!this.getModel().hasPendingChanges("policyEdit")) {
          MessageToast.show(this.getText("saved"));
        }
      }.bind(this), this.showError.bind(this));
    },

    onCancel: function () {
      this.getModel().resetChanges("policyEdit");
    },

    onEnable: function () {
      this.callAction("EnablePolicy", { id: this._sId }).catch(function () { /* shown */ });
    },

    onDisable: function () {
      this.callAction("DisablePolicy", { id: this._sId }).catch(function () { /* shown */ });
    },

    onDelete: function () {
      this.confirmDelete(this.getView().getBindingContext(), this.getText("deletePolicyQuestion"),
        this.onNavBack.bind(this));
    },

    onAssign: function () {
      this.openCreateDialog("Assignments", this.byId("policyAssignmentTable").getBinding("items"), { policyId: this._sId });
    },

    onRevoke: function () {
      var oItem = this.byId("policyAssignmentTable").getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectRow"));
        return;
      }
      this.confirmDelete(oItem.getBindingContext(), this.getText("revokeQuestion"));
    }
  });
});
