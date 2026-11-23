sap.ui.define([
  "uim/dataquality/controller/BaseController",
  "uim/dataquality/model/dialogs"
], function (BaseController, DIALOGS) {
  "use strict";

  /** Tables of the page, filtered to the dataset. */
  var TABLES = ["recordsTable", "columnsTable", "detailViolationsTable", "detailGroupsTable", "snapshotsTable"];

  return BaseController.extend("uim.dataquality.controller.DatasetDetail", {
    dialogs: function () {
      return DIALOGS;
    },

    onInit: function () {
      this.getRouter().getRoute("dataset").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      this._id = event.getParameter("arguments").id;
      this.bindTo("Datasets", this._id);
      TABLES.forEach(function (table) {
        this.filterTable(table, { datasetId: this._id });
      }, this);
    },

    dialogPrefill: function (dialog) {
      if (dialog === "importCsv") {
        return { datasetId: this._id, createDataset: false };
      }
      return { datasetId: this._id };
    },

    onSearch: function (event) {
      var query = event.getParameter("query");
      this.byId("recordsTable").getBinding("items").changeParameters({ $search: query ? query : undefined });
    },

    onAction: function (event) {
      this.runDatasetAction(event.getSource().data("action"), this._id);
    },

    onEditRecord: function () {
      var context = this.selected("recordsTable");
      if (context) {
        this.openDialog("record", {
          datasetId: this._id, id: context.getProperty("id"), key: context.getProperty("key"),
          fields: (context.getObject().fields || []).join("\n")
        });
      }
    },

    onValidateRecord: function () {
      var context = this.selected("recordsTable");
      if (!context) {
        return;
      }
      this.invokeAction("ValidateRecord", { key: context.getProperty("key") }).then(function (r) {
        this.toast("recordValidated", [context.getProperty("id"), this.formatter.score(r.qualityScore), r.violationCount]);
      }.bind(this), this.showError.bind(this));
    }
  });
});
