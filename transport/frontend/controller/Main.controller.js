sap.ui.define([
  "uim/transport/controller/BaseController",
  "sap/ui/core/Fragment",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast"
], function (BaseController, Fragment, Filter, FilterOperator, MessageBox, MessageToast) {
  "use strict";

  var TABS = ["overview", "nodes", "routes", "requests", "queue", "actions"];

  return BaseController.extend("uim.transport.controller.Main", {

    onInit: function () {
      this._mDialogs = {};
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

    onShowRequests: function () {
      this.getModel("ui").setProperty("/selectedTab", "requests");
    },

    onRequestPress: function (oEvent) {
      this._navToRequest(oEvent.getSource().getBindingContext().getProperty("id"));
    },

    onQueueRequestPress: function (oEvent) {
      this._navToRequest(oEvent.getSource().getBindingContext().getProperty("requestId"));
    },

    _navToRequest: function (sId) {
      this.getRouter().navTo("request", { id: encodeURIComponent(sId) });
    },

    // ── Dialogs ─────────────────────────────────────────────────────────

    _openDialog: function (sName, sDraft, oDraft) {
      this.getModel("ui").setProperty("/" + sDraft, oDraft);
      if (!this._mDialogs[sName]) {
        this._mDialogs[sName] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.transport.fragment." + sName,
          controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      this._mDialogs[sName].then(function (oDialog) { oDialog.open(); });
    },

    onCloseDialog: function (oEvent) {
      this.byId(oEvent.getSource().data("dialog")).close();
    },

    _create: function (sTableId, oData, sDoneKey, sDialogId) {
      var oContext = this.byId(sTableId).getBinding("items").create(oData);
      this.byId(sDialogId).close();
      return oContext.created().then(function () {
        MessageToast.show(this.getText(sDoneKey));
        this._refreshStatistics();
        return oContext;
      }.bind(this), function (oError) {
        this.showError(oError);
        throw oError;
      }.bind(this));
    },

    // ── Nodes ───────────────────────────────────────────────────────────

    onCreateNode: function () {
      this._openDialog("CreateNodeDialog", "newNode", {
        name: "", nodeType: "cloudFoundry", description: "", region: "", subaccountId: "", spaceId: "",
        isForwardEnabled: true, autoImport: false
      });
    },

    onSaveNode: function () {
      var oDraft = this.getModel("ui").getProperty("/newNode");
      if (!oDraft.name) {
        MessageBox.warning(this.getText("nameRequired"));
        return;
      }
      this._create("nodeTable", oDraft, "nodeCreated", "createNodeDialog");
    },

    _selectedNode: function () {
      var oItem = this.byId("nodeTable").getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return null;
      }
      return oItem.getBindingContext().getObject();
    },

    onEnableNode: function () {
      var oNode = this._selectedNode();
      if (oNode) { this.callAction("EnableNode", { nodeId: oNode.id }); }
    },

    onDisableNode: function () {
      var oNode = this._selectedNode();
      if (oNode) { this.callAction("DisableNode", { nodeId: oNode.id }); }
    },

    onCheckConnection: function () {
      var oNode = this._selectedNode();
      if (oNode) { this.callAction("CheckConnection", { nodeId: oNode.id }); }
    },

    onImportSelectedNode: function () {
      var oNode = this._selectedNode();
      if (oNode) { this._confirmImport(oNode.id, oNode.name); }
    },

    // ── Routes ──────────────────────────────────────────────────────────

    onCreateRoute: function () {
      this._openDialog("CreateRouteDialog", "newRoute", {
        name: "", sourceNodeId: "", destinationNodeId: "", sequence: 0, description: ""
      });
    },

    onSaveRoute: function () {
      var oDraft = this.getModel("ui").getProperty("/newRoute");
      if (!oDraft.name) {
        MessageBox.warning(this.getText("nameRequired"));
        return;
      }
      if (!oDraft.sourceNodeId || !oDraft.destinationNodeId) {
        MessageBox.warning(this.getText("routeNodesRequired"));
        return;
      }
      oDraft.sequence = parseInt(oDraft.sequence, 10) || 0;
      this._create("routeTable", oDraft, "routeCreated", "createRouteDialog");
    },

    _selectedRoute: function () {
      var oItem = this.byId("routeTable").getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return null;
      }
      return oItem.getBindingContext().getObject();
    },

    onEnableRoute: function () {
      var oRoute = this._selectedRoute();
      if (oRoute) { this.callAction("EnableRoute", { routeId: oRoute.id }); }
    },

    onDisableRoute: function () {
      var oRoute = this._selectedRoute();
      if (oRoute) { this.callAction("DisableRoute", { routeId: oRoute.id }); }
    },

    // ── Requests ────────────────────────────────────────────────────────

    onCreateRequest: function () {
      this._openDialog("CreateRequestDialog", "newRequest", {
        name: "", sourceNodeId: "", contentType: "mtaArchive", version: "1.0.0", storageUrl: "",
        description: "", exportNow: true
      });
    },

    onSaveRequest: function () {
      var oDraft = Object.assign({}, this.getModel("ui").getProperty("/newRequest"));
      if (!oDraft.name) {
        MessageBox.warning(this.getText("nameRequired"));
        return;
      }
      var bExport = oDraft.exportNow && !!oDraft.sourceNodeId;
      delete oDraft.exportNow;
      this._create("requestTable", oDraft, "requestCreated", "createRequestDialog").then(function (oContext) {
        if (bExport) {
          this.callAction("ExportRequest", { requestId: oContext.getProperty("id") });
        }
      }.bind(this));
    },

    onExportRequest: function () {
      var oItem = this.byId("requestTable").getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return;
      }
      this.callAction("ExportRequest", { requestId: oItem.getBindingContext().getProperty("id") });
    },

    onSearchRequests: function (oEvent) {
      var sQuery = (oEvent.getParameter("query") || "").trim();
      var aFilters = sQuery ? [new Filter({
        filters: [
          new Filter({ path: "name", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false }),
          new Filter({ path: "description", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false }),
          new Filter({ path: "version", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false })
        ],
        and: false
      })] : [];
      this.byId("requestTable").getBinding("items").filter(aFilters);
    },

    // ── Import queues ───────────────────────────────────────────────────

    onQueueNodeChange: function (oEvent) {
      var sNodeId = oEvent.getSource().getSelectedKey();
      this.getModel("ui").setProperty("/queueNode", sNodeId);
      this.byId("queueTable").getBinding("items").filter(
        sNodeId ? [new Filter("nodeId", FilterOperator.EQ, sNodeId)] : []);
    },

    onQueueAllNodes: function () {
      this.byId("queueNodeFilter").setSelectedKey(null);
      this.getModel("ui").setProperty("/queueNode", "");
      this.byId("queueTable").getBinding("items").filter([]);
    },

    onImportQueue: function () {
      var oSelect = this.byId("queueNodeFilter");
      var oItem = oSelect.getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("chooseNode"));
        return;
      }
      this._confirmImport(oItem.getKey(), oItem.getText());
    },

    _confirmImport: function (sNodeId, sNodeName) {
      MessageBox.confirm(this.getText("confirmImport", [sNodeName]), {
        emphasizedAction: MessageBox.Action.OK,
        onClose: function (sAction) {
          if (sAction === MessageBox.Action.OK) {
            this.callAction("ImportNode", { nodeId: sNodeId, entryIds: [] }).then(this._refreshStatistics.bind(this));
          }
        }.bind(this)
      });
    },

    _selectedEntries: function () {
      var aContexts = this.byId("queueTable").getSelectedContexts();
      if (!aContexts.length) {
        MessageToast.show(this.getText("selectFirst"));
      }
      return aContexts.map(function (oContext) { return oContext.getObject(); });
    },

    onImportSelectedEntries: function () {
      var aEntries = this._selectedEntries();
      if (!aEntries.length) {
        return;
      }
      // one import run per node
      var mByNode = {};
      aEntries.forEach(function (oEntry) {
        (mByNode[oEntry.nodeId] = mByNode[oEntry.nodeId] || []).push(oEntry.id);
      });
      Object.keys(mByNode).reduce(function (oChain, sNodeId) {
        return oChain.then(function () {
          return this.callAction("ImportNode", { nodeId: sNodeId, entryIds: mByNode[sNodeId] });
        }.bind(this));
      }.bind(this), Promise.resolve()).then(this._refreshStatistics.bind(this), function () {});
    },

    onResetEntries: function () {
      this._selectedEntries().reduce(function (oChain, oEntry) {
        return oChain.then(function () {
          return this.callAction("ResetQueueEntry", { entryId: oEntry.id });
        }.bind(this));
      }.bind(this), Promise.resolve()).then(this._refreshStatistics.bind(this), function () {});
    },

    onDeleteEntries: function () {
      var aContexts = this.byId("queueTable").getSelectedContexts();
      if (!aContexts.length) {
        MessageToast.show(this.getText("selectFirst"));
        return;
      }
      MessageBox.confirm(this.getText("confirmDelete"), {
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          Promise.all(aContexts.map(function (oContext) { return oContext.delete(); })).then(function () {
            MessageToast.show(this.getText("deleted"));
            this._refreshStatistics();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    onToggleSelected: function () {
      // two-way binding PATCHes isSelected via $direct
    },

    // ── helpers ─────────────────────────────────────────────────────────

    onDeleteSelected: function (oEvent) {
      var oItem = this.byId(oEvent.getSource().data("table")).getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return;
      }
      MessageBox.confirm(this.getText("confirmDelete"), {
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          oItem.getBindingContext().delete().then(function () {
            MessageToast.show(this.getText("deleted"));
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
