sap.ui.define([
  "uim/management/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageToast) {
  "use strict";

  var TABS = ["overview", "globalAccounts", "directories", "subaccounts", "entitlements",
    "environments", "subscriptions", "servicePlans", "labels", "events"];

  return BaseController.extend("uim.management.controller.Main", {

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

    onTile: function (oEvent) {
      var sTab = oEvent.getSource().data("tab");
      this.getModel("ui").setProperty("/selectedTab", sTab);
      this.getRouter().navTo("main", { tab: sTab }, true);
    },

    onRefresh: function () {
      this.getModel().refresh();
      MessageToast.show(this.getText("refreshed"));
    },

    onGlobalAccountPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("globalAccount", { id: encodeURIComponent(sId) });
    },

    onSubaccountPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("subaccount", { id: encodeURIComponent(sId) });
    },

    // ── Filters ($filter / $search on the OData V4 list bindings) ───────

    /** Generic search: the SearchField carries "table" and "fields" custom data. */
    onSearch: function (oEvent) {
      var oField = oEvent.getSource();
      var sQuery = (oField.getValue() || "").trim();
      var aFields = String(oField.data("fields")).split(",");
      var oBinding = this.byId(oField.data("table")).getBinding("items");
      oBinding.filter(sQuery ? this._containsAny(aFields, sQuery) : []);
    },

    onFilterSubaccounts: function () {
      var aFilters = [];
      var sStatus = this.byId("subaccountStatusFilter").getSelectedKey();
      var sQuery = (this.byId("subaccountSearch").getValue() || "").trim();
      if (sStatus) {
        aFilters.push(new Filter("status", FilterOperator.EQ, sStatus));
      }
      if (sQuery) {
        aFilters.push(this._containsAny(["displayName", "subdomain", "region", "description"], sQuery));
      }
      this.byId("subaccountTable").getBinding("items")
        .filter(aFilters.length ? new Filter({ filters: aFilters, and: true }) : []);
    },

    onFilterEvents: function () {
      var aFilters = [];
      var sCategory = this.byId("eventCategoryFilter").getSelectedKey();
      var sSeverity = this.byId("eventSeverityFilter").getSelectedKey();
      var sQuery = (this.byId("eventSearch").getValue() || "").trim();
      if (sCategory) {
        aFilters.push(new Filter("category", FilterOperator.EQ, sCategory));
      }
      if (sSeverity) {
        aFilters.push(new Filter("severity", FilterOperator.EQ, sSeverity));
      }
      if (sQuery) {
        aFilters.push(this._containsAny(["description", "eventType", "initiatedBy"], sQuery));
      }
      this.byId("eventTable").getBinding("items")
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

    // ── Create dialogs ──────────────────────────────────────────────────

    _create: function (sEntitySet, sTableId, oDefaults) {
      this.openCreateDialog(sEntitySet, this.byId(sTableId).getBinding("items"), oDefaults,
        this._refreshOverview.bind(this));
    },

    _selectedValue: function (sTableId, sProperty) {
      var oItem = this.byId(sTableId).getSelectedItem();
      return oItem ? oItem.getBindingContext().getProperty(sProperty) : "";
    },

    onCreateGlobalAccount: function () { this._create("GlobalAccounts", "globalAccountTable"); },

    onCreateDirectory: function () {
      this._create("Directories", "directoryTable", {
        globalAccountId: this._selectedValue("globalAccountTable", "id")
      });
    },

    onCreateSubaccount: function () {
      this._create("Subaccounts", "subaccountTable", {
        globalAccountId: this._selectedValue("globalAccountTable", "id"),
        parentDirectoryId: this._selectedValue("directoryTable", "id")
      });
    },

    onAssignEntitlement: function () {
      this._create("Entitlements", "entitlementTable", {
        subaccountId: this._selectedValue("subaccountTable", "id"),
        servicePlanId: this._selectedValue("servicePlanTable", "id")
      });
    },

    onCreateEnvironment: function () {
      this._create("Environments", "environmentTable", {
        subaccountId: this._selectedValue("subaccountTable", "id")
      });
    },

    onCreateSubscription: function () {
      this._create("Subscriptions", "subscriptionTable", {
        subaccountId: this._selectedValue("subaccountTable", "id")
      });
    },

    onCreateServicePlan: function () { this._create("ServicePlans", "servicePlanTable"); },

    onCreateLabel: function () {
      this._create("Labels", "labelTable", {
        resourceId: this._selectedValue("subaccountTable", "id")
      });
    },

    // ── Lifecycle actions (unbound OData actions) ───────────────────────

    _actionOnSelected: function (sTableId, sAction) {
      var sId = this._selectedValue(sTableId, "id");
      if (!sId) {
        MessageToast.show(this.getText("selectFirst"));
        return;
      }
      this.callAction(sAction, { id: sId }).catch(function () { /* already shown */ });
    },

    onSuspendGlobalAccount: function () { this._actionOnSelected("globalAccountTable", "SuspendGlobalAccount"); },
    onReactivateGlobalAccount: function () { this._actionOnSelected("globalAccountTable", "ReactivateGlobalAccount"); },
    onSuspendSubaccount: function () { this._actionOnSelected("subaccountTable", "SuspendSubaccount"); },
    onReactivateSubaccount: function () { this._actionOnSelected("subaccountTable", "ReactivateSubaccount"); },
    onRevokeEntitlement: function () { this._actionOnSelected("entitlementTable", "RevokeEntitlement"); },
    onUnsubscribe: function () { this._actionOnSelected("subscriptionTable", "Unsubscribe"); },

    /** Delete the selected row of the table named in the button's "table" custom data. */
    onDeleteSelected: function (oEvent) {
      var oItem = this.byId(oEvent.getSource().data("table")).getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return;
      }
      this.confirmDelete(oItem.getBindingContext(), this.getText("confirmDelete"), this._refreshOverview.bind(this));
    },

    _refreshOverview: function () {
      var oBinding = this.byId("kpiHeader").getElementBinding();
      if (oBinding) {
        oBinding.refresh();
      }
    }
  });
});
