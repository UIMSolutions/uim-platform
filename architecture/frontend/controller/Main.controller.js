sap.ui.define([
  "uim/architecture/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (BaseController, Filter, FilterOperator) {
  "use strict";

  return BaseController.extend("uim.architecture.controller.Main", {
    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      var tab = (event.getParameter("arguments") || {}).tab;
      if (tab) {
        this.getModel("view").setProperty("/tab", tab);
      }
    },

    onTabSelect: function (event) {
      this.getRouter().navTo("main", { tab: event.getParameter("key") }, true);
    },

    // ── building blocks ───────────────────────────────────────────────────

    onFilterBlocks: function () {
      var view = this.getModel("view");
      var filters = [];
      var kind = view.getProperty("/kindFilter");
      var status = view.getProperty("/statusFilter");
      if (kind && kind !== "all") {
        filters.push(new Filter("kind", FilterOperator.EQ, kind));
      }
      if (status) {
        filters.push(new Filter("status", FilterOperator.EQ, status));
      }
      this.byId("blocksTable").getBinding("items").filter(filters);
    },

    onClearStatus: function () {
      this.getModel("view").setProperty("/statusFilter", "");
      this.byId("statusFilter").setSelectedKey(null);
      this.onFilterBlocks();
    },

    onSearch: function (event) {
      var query = event.getParameter("query");
      this.byId("blocksTable").getBinding("items").changeParameters({ $search: query ? query : undefined });
    },

    onNewBlock: function () {
      var kind = this.getModel("view").getProperty("/kindFilter");
      this.openBlockDialog(null, kind && kind !== "all" ? kind : "architecture");
    },

    // ── relationships ─────────────────────────────────────────────────────

    onNewRelationship: function () {
      this.openRelationshipDialog("");
    },

    onFilterRelationships: function (event) {
      var type = event.getSource().getSelectedKey();
      this.byId("relationshipsTable").getBinding("items").filter(type ? [new Filter("type", FilterOperator.EQ, type)] : []);
    },

    onClearRelationshipType: function () {
      this.byId("relationshipTypeFilter").setSelectedKey(null);
      this.byId("relationshipsTable").getBinding("items").filter([]);
    },

    // ── repository actions ────────────────────────────────────────────────

    onSeed: function () {
      this.invokeAction("SeedDemoData").then(function (result) {
        this.refreshAll();
        this.toast("seeded", [result.blocks, result.relationships]);
      }.bind(this)).catch(this.showError.bind(this));
    },

    onExport: function () {
      this.invokeAction("ExportArchiMate", { modelName: this.text("appTitle") }).then(function (result) {
        var blob = new Blob([result.content], { type: result.contentType });
        var link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = result.fileName;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(link.href);
        this.toast("exported", [result.elements]);
      }.bind(this)).catch(this.showError.bind(this));
    }
  });
});
