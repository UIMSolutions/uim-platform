sap.ui.define([
  "uim/dataretention/controller/BaseController"
], function (BaseController) {
  "use strict";

  /** Tables of the page, filtered to the business purpose. */
  var TABLES = ["groundsTable", "residenceTable", "retentionTable", "detailSubjectsTable"];

  return BaseController.extend("uim.dataretention.controller.BusinessPurposeDetail", {
    onInit: function () {
      this.getRouter().getRoute("purpose").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      this.purposeId = event.getParameter("arguments").id;
      this.bindTo("BusinessPurposes", this.purposeId);
      TABLES.forEach(function (table) {
        this.filterTable(table, { businessPurposeId: this.purposeId });
      }, this);
    },

    /** New legal grounds belong to this purpose; new rules to the selected legal ground. */
    dialogPrefill: function (dialog) {
      var prefill = { businessPurposeId: this.purposeId };
      if (dialog === "residenceRule" || dialog === "retentionRule") {
        var item = this.byId("groundsTable").getSelectedItem();
        if (item) {
          prefill.legalGroundId = item.getBindingContext().getProperty("id");
        }
      }
      return prefill;
    },

    /** Activate / deactivate / deprecate this purpose (customData: action). */
    onPurposeAction: function (event) {
      var action = event.getSource().data("action");
      this.invokeAction(action, { id: this.purposeId }).then(function (r) {
        this.toast("statusChanged", [r.name, this.formatter.enumText(r.status)]);
      }.bind(this), this.showError.bind(this));
    },

    onEditPurpose: function () {
      var p = this.getView().getBindingContext().getObject();
      this.openDialog("businessPurpose", { id: p.id, name: p.name, description: p.description,
        applicationGroupId: p.applicationGroupId, dataSubjectRoleId: p.dataSubjectRoleId, legalEntityId: p.legalEntityId || "",
        edit: true });
    }
  });
});
