sap.ui.define([
  "uim/documentai/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (BaseController, Filter, FilterOperator) {
  "use strict";

  return BaseController.extend("uim.documentai.controller.SchemaDetail", {
    onInit: function () {
      this.getRouter().getRoute("schema").attachPatternMatched(this.onMatched, this);
    },

    onMatched: function (event) {
      this.schemaId = event.getParameter("arguments").id;
      this.bindTo("Schemas", this.schemaId);
      this.filterTable("fieldsTable", { schemaId: this.schemaId });
      this.filterTable("schemaDocumentsTable", { schemaId: this.schemaId });
    },

    /** New fields belong to this schema; line item fields go after the last one of their scope. */
    dialogPrefill: function (key) {
      if (key !== "schemaField") {
        return {};
      }
      var items = this.byId("fieldsTable").getItems();
      var highest = 0;
      items.forEach(function (item) {
        highest = Math.max(highest, item.getBindingContext().getProperty("sequenceNumber") || 0);
      });
      return { schemaId: this.schemaId, sequenceNumber: highest + 10 };
    },

    /** Copy as a new draft version and open it. */
    onCopy: function () {
      this.invokeAction("CopySchema", { id: this.schemaId }).then(function (r) {
        this.toast("schemaCopied", [r.name, r.version]);
        this.getRouter().navTo("schema", { id: r.id });
      }.bind(this), this.showError.bind(this));
    }
  });
});
