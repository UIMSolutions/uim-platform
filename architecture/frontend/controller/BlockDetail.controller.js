sap.ui.define([
  "uim/architecture/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/ActionSheet",
  "sap/m/Button",
  "sap/m/MessageBox",
  "uim/architecture/model/formatter",
  "uim/architecture/model/models"
], function (BaseController, Filter, FilterOperator, ActionSheet, Button, MessageBox, formatter, models) {
  "use strict";

  return BaseController.extend("uim.architecture.controller.BlockDetail", {
    onInit: function () {
      this.getRouter().getRoute("block").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      var id = decodeURIComponent(event.getParameter("arguments").id);
      this._id = id;
      var view = this.getModel("view");
      view.setProperty("/impact", []);
      view.setProperty("/impactLoaded", false);
      view.setProperty("/impactText", "");
      view.setProperty("/isArchitecture", false);
      this.getView().bindElement({ path: models.entityPath("BuildingBlocks", id) });
      this.getView().getElementBinding().getBoundContext().requestProperty("kind").then(function (kind) {
        view.setProperty("/isArchitecture", kind === "architecture");
      }).catch(function () { /* 404 is shown by the binding */ });
      this.byId("detailTabs").setSelectedKey("general");
      this._filter("outgoingTable", [new Filter("sourceId", FilterOperator.EQ, id)]);
      this._filter("incomingTable", [new Filter("targetId", FilterOperator.EQ, id)]);
      this._filter("realizedByTable", [new Filter("realizesId", FilterOperator.EQ, id)]);
    },

    /** Apply filters to the items of a (suspended) table and resume it. */
    _filter: function (tableId, filters) {
      var binding = this.byId(tableId).getBinding("items");
      binding.filter(filters);
      if (binding.isSuspended()) {
        binding.resume();
      }
    },

    _row: function () {
      return this.getView().getBindingContext().getObject();
    },

    onEdit: function () {
      this.openBlockDialog(this._row());
    },

    onNewRelationship: function () {
      this.openRelationshipDialog(this._id);
    },

    onOpenRealized: function () {
      this.getRouter().navTo("block", { id: this._row().realizesId });
    },

    // ── lifecycle ─────────────────────────────────────────────────────────

    onLifecycle: function (event) {
      var row = this._row();
      var next = formatter.nextStatuses(row.status);
      if (next.length === 0) {
        MessageBox.information(this.text("noTransitions", [this.statusText(row.status)]));
        return;
      }
      if (this._sheet) {
        this._sheet.destroy();
      }
      this._sheet = new ActionSheet({
        placement: "Bottom",
        buttons: next.map(function (status) {
          return new Button({
            text: this.statusText(status),
            icon: formatter.statusIcon(status),
            press: this._changeStatus.bind(this, row, status)
          });
        }.bind(this))
      });
      this.getView().addDependent(this._sheet);
      this._sheet.openBy(event.getSource());
    },

    _changeStatus: function (row, status) {
      this.confirm("confirmStatus", [row.name, this.statusText(status)])
        .then(function () {
          return this.invokeAction("ChangeStatus", { id: row.id, status: status });
        }.bind(this))
        .then(function (result) {
          this.refreshAll();
          this.toast("statusChanged", [row.name, this.statusText(result.previousStatus), this.statusText(result.status)]);
        }.bind(this))
        .catch(this.showError.bind(this));
    },

    // ── impact analysis ───────────────────────────────────────────────────

    onAnalyzeImpact: function () {
      this.invokeAction("AnalyzeImpact", { id: this._id }).then(function (result) {
        var rows = Array.isArray(result) ? result : (result && result.value) || [];
        var view = this.getModel("view");
        view.setProperty("/impact", rows);
        view.setProperty("/impactLoaded", true);
        view.setProperty("/impactText", rows.length === 0 ? this.text("impactNone")
          : this.text("impactSummary", [rows.length, rows.filter(function (r) { return r.depth === 1; }).length]));
        this.byId("detailTabs").setSelectedKey("impact");
      }.bind(this)).catch(this.showError.bind(this));
    },

    onOpenImpacted: function (event) {
      var row = event.getParameter("listItem").getBindingContext("view").getObject();
      this.getRouter().navTo("block", { id: row.id });
    },

    // ── delete ────────────────────────────────────────────────────────────

    onDelete: function () {
      var row = this._row();
      if (!formatter.deletable(row.status)) {
        MessageBox.warning(this.text("notDeletable"));
        return;
      }
      this.confirm("confirmDelete", [row.name])
        .then(function () {
          return this.request("DELETE", models.entityPath("BuildingBlocks", row.id));
        }.bind(this))
        .then(function () {
          this.toast("blockDeleted");
          this.getView().unbindElement();
          this.refreshAll();
          this.getRouter().navTo("main", {}, true);
        }.bind(this))
        .catch(this.showError.bind(this));
    }
  });
});
