sap.ui.define([
  "uim/auditlog/controller/BaseController",
  "sap/ui/core/Fragment",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast"
], function (BaseController, Fragment, Filter, FilterOperator, MessageBox, MessageToast) {
  "use strict";

  var TAB_TABLES = {
    logs: "auditLogTable",
    security: "securityTable",
    dataAccess: "dataAccessTable",
    configChanges: "configChangeTable",
    retention: "retentionTable",
    auditConfig: "auditConfigTable",
    exports: "exportTable"
  };

  return BaseController.extend("uim.auditlog.controller.Main", {

    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(this._onRouteMatched, this);
      this.byId("auditConfigTable").attachUpdateFinished(function (oEvent) {
        this.getModel("ui").setProperty("/hasConfig", oEvent.getParameter("total") > 0);
      }, this);
    },

    _onRouteMatched: function (oEvent) {
      var sTab = (oEvent.getParameter("arguments") || {}).tab;
      if (sTab && (TAB_TABLES[sTab] || sTab === "overview")) {
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

    _showLogs: function (sCategory) {
      this.byId("categoryFilter").setSelectedKey(sCategory);
      this.getModel("ui").setProperty("/selectedTab", "logs");
      this.onFilterLogs();
    },

    onTileSecurity: function () { this._showLogs("securityEvents"); },
    onTileConfig: function () { this._showLogs("configuration"); },
    onTileDataAccess: function () { this._showLogs("dataAccess"); },

    onAuditLogPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("auditLog", { id: encodeURIComponent(sId) });
    },

    // ── Audit log filters ($filter / $search on the OData V4 list binding) ─

    onFilterLogs: function () {
      var aFilters = [];
      var sCategory = this.byId("categoryFilter").getSelectedKey();
      var sSeverity = this.byId("severityFilter").getSelectedKey();
      var sQuery = (this.byId("logSearch").getValue() || "").trim();

      if (sCategory) {
        aFilters.push(new Filter("category", FilterOperator.EQ, sCategory));
      }
      if (sSeverity) {
        aFilters.push(new Filter("severity", FilterOperator.EQ, sSeverity));
      }
      if (sQuery) {
        aFilters.push(new Filter({
          filters: [
            new Filter({ path: "message", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false }),
            new Filter({ path: "userName", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false }),
            new Filter({ path: "userId", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false }),
            new Filter({ path: "objectId", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false })
          ],
          and: false
        }));
      }
      this.byId("auditLogTable").getBinding("items").filter(aFilters.length ? new Filter({ filters: aFilters, and: true }) : []);
    },

    // ── Retention policies ──────────────────────────────────────────────

    onCreatePolicy: function () {
      this.getModel("ui").setProperty("/newPolicy", {
        name: "", description: "", retentionDays: 90, categories: [], isDefault: false
      });
      if (!this._pPolicyDialog) {
        this._pPolicyDialog = Fragment.load({
          id: this.getView().getId(),
          name: "uim.auditlog.fragment.CreatePolicyDialog",
          controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      this._pPolicyDialog.then(function (oDialog) { oDialog.open(); });
    },

    onSavePolicy: function () {
      var oDraft = this.getModel("ui").getProperty("/newPolicy");
      if (!oDraft.name) {
        MessageBox.warning(this.getText("nameRequired"));
        return;
      }
      var oBinding = this.byId("retentionTable").getBinding("items");
      var oContext = oBinding.create({
        name: oDraft.name,
        description: oDraft.description,
        retentionDays: parseInt(oDraft.retentionDays, 10) || 90,
        categories: oDraft.categories,
        isDefault: !!oDraft.isDefault
      });
      oContext.created().then(function () {
        MessageToast.show(this.getText("policyCreated"));
        this._refreshStatistics();
      }.bind(this), this.showError.bind(this));
      this.onCancelPolicy();
    },

    onCancelPolicy: function () {
      this.byId("createPolicyDialog").close();
    },

    onDeletePolicy: function () {
      this._deleteSelected("retentionTable", "confirmDeletePolicy", "policyDeleted");
    },

    onEnforceRetention: function () {
      MessageBox.confirm(this.getText("confirmEnforce"), {
        emphasizedAction: MessageBox.Action.OK,
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          var oOperation = this.getModel().bindContext("/EnforceRetention(...)");
          oOperation.execute().then(function () {
            var oResult = oOperation.getBoundContext().getObject();
            MessageBox.success(this.getText("retentionDone", [oResult.removed, oResult.retentionDays]));
            this.getModel().refresh();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    // ── Audit configuration (two-way bound, PATCHed via $direct) ────────

    onConfigChanged: function () {
      MessageToast.show(this.getText("configSaved"));
    },

    onConfigStatus: function (oEvent) {
      var oContext = oEvent.getSource().getBindingContext();
      oContext.setProperty("status", oEvent.getParameter("state") ? "enabled" : "disabled")
        .then(this.onConfigChanged.bind(this), this.showError.bind(this));
    },

    onCreateConfig: function () {
      var oContext = this.byId("auditConfigTable").getBinding("items").create({
        name: this.getText("defaultConfigName"),
        logDataAccess: true,
        logDataModification: true,
        logSecurityEvents: true,
        logConfigurationChanges: true,
        enableDataMasking: false,
        maskedFields: [],
        excludedServices: [],
        minimumSeverity: "info",
        rateLimitPerSecond: 8
      });
      oContext.created().then(function () {
        MessageToast.show(this.getText("configSaved"));
      }.bind(this), this.showError.bind(this));
    },

    // ── Exports ─────────────────────────────────────────────────────────

    onCreateExport: function () {
      var sFormat = this.getModel("ui").getProperty("/newExport/format");
      var oContext = this.byId("exportTable").getBinding("items").create({ format: sFormat, categories: [] });
      oContext.created().then(function () {
        MessageToast.show(this.getText("exportCreated"));
        this._refreshStatistics();
      }.bind(this), this.showError.bind(this));
    },

    onDeleteExport: function () {
      this._deleteSelected("exportTable", "confirmDeleteExport", "exportDeleted");
    },

    // ── helpers ─────────────────────────────────────────────────────────

    _deleteSelected: function (sTableId, sConfirmKey, sDoneKey) {
      var oItem = this.byId(sTableId).getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return;
      }
      MessageBox.confirm(this.getText(sConfirmKey), {
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          oItem.getBindingContext().delete().then(function () {
            MessageToast.show(this.getText(sDoneKey));
            this._refreshStatistics();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    _refreshStatistics: function () {
      var oBinding = this.byId("kpiHeader").getElementBinding();
      if (oBinding) {
        oBinding.refresh();
      }
    }
  });
});
