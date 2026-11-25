sap.ui.define([
  "uim/documentai/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (BaseController, Filter, FilterOperator) {
  "use strict";

  return BaseController.extend("uim.documentai.controller.DocumentDetail", {
    onInit: function () {
      this.getRouter().getRoute("document").attachPatternMatched(this.onMatched, this);
    },

    /** Bind the document; header values (row 0) and line item cells (row > 0) of it. */
    onMatched: function (event) {
      this.documentId = event.getParameter("arguments").id;
      this.bindTo("Documents", this.documentId);
      var mine = new Filter("documentId", FilterOperator.EQ, this.documentId);
      [["headerTable", FilterOperator.EQ], ["lineItemsTable", FilterOperator.GT]].forEach(function (spec) {
        var binding = this.byId(spec[0]).getBinding("items");
        binding.filter([mine, new Filter("rowIndex", spec[1], 0)]);
        if (binding.isSuspended()) {
          binding.resume();
        }
      }, this);
    },

    /** After an operation the view shows the document of the result (e.g. reprocessed). */
    refreshAll: function () {
      this.getModel().refresh();
    }
  });
});
