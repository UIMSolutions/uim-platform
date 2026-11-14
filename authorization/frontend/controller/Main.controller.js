sap.ui.define([
  "uim/authorization/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageBox, MessageToast) {
  "use strict";

  var TABS = ["applications", "policies", "assignments", "check", "decisions"];

  return BaseController.extend("uim.authorization.controller.Main", {

    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sTab = (oEvent.getParameter("arguments") || {}).tab;
      if (sTab && TABS.indexOf(sTab) >= 0) {
        this.getModel("ui").setProperty("/selectedTab", sTab);
      }
    },

    // ── Navigation & refresh ────────────────────────────────────────────

    onTabSelect: function (oEvent) {
      this.getRouter().navTo("main", { tab: oEvent.getParameter("key") }, true);
    },

    onRefresh: function () {
      this.getModel().refresh();
      MessageToast.show(this.getText("refreshed"));
    },

    _pressedContext: function (oEvent) {
      return (oEvent.getParameter("listItem") || oEvent.getSource()).getBindingContext();
    },

    onApplicationPress: function (oEvent) {
      var sId = this._pressedContext(oEvent).getProperty("id");
      this.getRouter().navTo("application", { id: encodeURIComponent(sId) });
    },

    onPolicyPress: function (oEvent) {
      var sId = this._pressedContext(oEvent).getProperty("id");
      this.getRouter().navTo("policy", { id: encodeURIComponent(sId) });
    },

    onAssignmentPolicyPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("policyId");
      this.getRouter().navTo("policy", { id: encodeURIComponent(sId) });
    },

    onSeedDemo: function () {
      MessageBox.confirm(this.getText("seedDemoQuestion"), {
        onClose: function (sAction) {
          if (sAction === MessageBox.Action.OK) {
            this.callAction("SeedDemoData", {}).catch(function () { /* shown */ });
          }
        }.bind(this)
      });
    },

    // ── Filters ($filter / $search on the OData V4 list bindings) ───────

    /** Generic search: the SearchField carries "table" and "fields" custom data. */
    onSearch: function (oEvent) {
      var oField = oEvent.getSource();
      var sQuery = (oField.getValue() || "").trim();
      var aFields = String(oField.data("fields")).split(",");
      this.byId(oField.data("table")).getBinding("items").filter(sQuery ? this._containsAny(aFields, sQuery) : []);
    },

    onFilterPolicies: function () {
      var aFilters = [];
      var sKind = this.byId("policyKindFilter").getSelectedKey();
      var sStatus = this.byId("policyStatusFilter").getSelectedKey();
      var sQuery = (this.byId("policySearch").getValue() || "").trim();
      if (sKind) { aFilters.push(new Filter("kind", FilterOperator.EQ, sKind)); }
      if (sStatus) { aFilters.push(new Filter("status", FilterOperator.EQ, sStatus)); }
      if (sQuery) { aFilters.push(this._containsAny(["name", "description", "resource", "applicationName"], sQuery)); }
      this.byId("policyTable").getBinding("items")
        .filter(aFilters.length ? new Filter({ filters: aFilters, and: true }) : []);
    },

    onFilterDecisions: function () {
      var aFilters = [];
      var sOutcome = this.byId("decisionOutcomeFilter").getSelectedKey();
      var sQuery = (this.byId("decisionSearch").getValue() || "").trim();
      if (sOutcome) { aFilters.push(new Filter("allowed", FilterOperator.EQ, sOutcome === "true")); }
      if (sQuery) { aFilters.push(this._containsAny(["principalId", "resource", "action", "applicationName"], sQuery)); }
      this.byId("decisionTable").getBinding("items")
        .filter(aFilters.length ? new Filter({ filters: aFilters, and: true }) : []);
    },

    _containsAny: function (aPaths, sQuery) {
      return new Filter({
        filters: aPaths.map(function (sPath) {
          return new Filter({ path: sPath, operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false });
        }),
        and: false
      });
    },

    // ── Create / change ─────────────────────────────────────────────────

    _refreshHeader: function () {
      this.byId("kpiHeader").getElementBinding().refresh();
    },

    _selectedValue: function (sTableId, sProperty) {
      var oItem = this.byId(sTableId).getSelectedItem();
      return oItem ? oItem.getBindingContext().getProperty(sProperty) : "";
    },

    onCreateApplication: function () {
      this.openCreateDialog("Applications", this.byId("applicationTable").getBinding("items"), null,
        this._refreshHeader.bind(this));
    },

    onCreatePolicy: function () {
      this.openCreateDialog("Policies", this.byId("policyTable").getBinding("items"), {
        applicationId: this._selectedValue("applicationTable", "id")
      }, this._refreshHeader.bind(this));
    },

    onCreateAssignment: function () {
      this.openCreateDialog("Assignments", this.byId("assignmentTable").getBinding("items"), {
        policyId: this._selectedValue("policyTable", "id")
      }, this._refreshHeader.bind(this));
    },

    _withSelectedPolicy: function (fn) {
      var sId = this._selectedValue("policyTable", "id");
      if (!sId) {
        MessageToast.show(this.getText("selectRow"));
        return;
      }
      fn(sId);
    },

    onEnablePolicy: function () {
      this._withSelectedPolicy(function (sId) {
        this.callAction("EnablePolicy", { id: sId }).catch(function () { /* shown */ });
      }.bind(this));
    },

    onDisablePolicy: function () {
      this._withSelectedPolicy(function (sId) {
        this.callAction("DisablePolicy", { id: sId }).catch(function () { /* shown */ });
      }.bind(this));
    },

    onDeleteSelected: function (oEvent) {
      var oItem = this.byId(oEvent.getSource().data("table")).getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectRow"));
        return;
      }
      this.confirmDelete(oItem.getBindingContext(), this.getText("deleteQuestion"), this._refreshHeader.bind(this));
    },

    // ── Check & decision log ────────────────────────────────────────────

    onEvaluate: function () {
      var oCheck = this.getModel("ui").getProperty("/check");
      this.callAction("EvaluateAuthorization", oCheck, true).then(function (oResult) {
        this.getModel("ui").setProperty("/checkResult", oResult);
      }.bind(this)).catch(function () {
        this.getModel("ui").setProperty("/checkResult", null);
      }.bind(this));
    },

    onPruneDecisions: function () {
      MessageBox.confirm(this.getText("pruneQuestion"), {
        onClose: function (sAction) {
          if (sAction === MessageBox.Action.OK) {
            this.callAction("PruneDecisions", { olderThanDays: 30 }).catch(function () { /* shown */ });
          }
        }.bind(this)
      });
    }
  });
});
