sap.ui.define([
  "uim/management/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/ui/model/Sorter",
  "sap/m/ColumnListItem",
  "sap/m/ObjectIdentifier",
  "sap/m/ObjectStatus",
  "sap/m/Text",
  "sap/m/Link",
  "sap/m/ProgressIndicator",
  "sap/m/StandardListItem",
  "sap/m/MessageToast",
  "sap/m/MessageBox",
  "sap/m/Input"
], function (BaseController, Filter, FilterOperator, Sorter, ColumnListItem, ObjectIdentifier, ObjectStatus,
  Text, Link, ProgressIndicator, StandardListItem, MessageToast, MessageBox, Input) {
  "use strict";

  return BaseController.extend("uim.management.controller.SubaccountDetail", {

    onInit: function () {
      this.getRouter().getRoute("subaccount").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      this._sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      var sPath = "/Subaccounts('" + this._sId.replace(/'/g, "''") + "')";
      this.getView().bindElement({ path: sPath });
      this._bindChildren();
    },

    /** Child tables are bound to the top-level entity sets, filtered by subaccountId. */
    _bindChildren: function () {
      var f = this.formatter;
      var oBySub = new Filter("subaccountId", FilterOperator.EQ, this._sId);

      this.byId("detailEnvironments").bindItems({
        path: "/Environments",
        filters: [oBySub],
        template: new ColumnListItem({
          cells: [
            new ObjectIdentifier({ title: "{name}", text: "{technicalKey}" }),
            new Text({ text: { path: "environmentType", formatter: f.enumText } }),
            new Text({ text: "{planName}" }),
            new Link({ text: "{landscapeLabel}", href: "{dashboardUrl}", target: "_blank" }),
            new ObjectStatus({ text: { path: "status", formatter: f.enumText }, state: { path: "status", formatter: f.statusState } })
          ]
        }),
        templateShareable: false
      });

      this.byId("detailEntitlements").bindItems({
        path: "/Entitlements",
        filters: [oBySub],
        template: new ColumnListItem({
          cells: [
            new ObjectIdentifier({ title: "{serviceName}" }),
            new Text({ text: "{planName}" }),
            new ProgressIndicator({
              percentValue: { parts: ["quotaUsed", "quotaAssigned", "unlimited"], formatter: f.quotaPercent },
              displayValue: { parts: ["quotaUsed", "quotaAssigned", "unlimited"], formatter: f.quota },
              displayOnly: true
            }),
            new ObjectStatus({ text: { path: "status", formatter: f.enumText }, state: { path: "status", formatter: f.statusState } })
          ]
        }),
        templateShareable: false
      });

      this.byId("detailSubscriptions").bindItems({
        path: "/Subscriptions",
        filters: [oBySub],
        template: new ColumnListItem({
          cells: [
            new ObjectIdentifier({ title: "{appName}", text: "{appDisplayName}" }),
            new Text({ text: "{planName}" }),
            new Link({ text: "{appUrl}", href: "{appUrl}", target: "_blank" }),
            new ObjectStatus({ text: { path: "status", formatter: f.enumText }, state: { path: "status", formatter: f.statusState } })
          ]
        }),
        templateShareable: false
      });

      this.byId("detailEvents").bindItems({
        path: "/Events",
        filters: [oBySub],
        sorter: new Sorter("timestamp", true),
        template: new StandardListItem({
          title: "{description}",
          description: "{eventType} · {initiatedBy}",
          info: { path: "severity", formatter: f.enumText },
          infoState: { path: "severity", formatter: f.severityState }
        }),
        templateShareable: false
      });
    },

    onNavBack: function () {
      this.getRouter().navTo("main", { tab: "subaccounts" });
    },

    /** Two-way bound fields are PATCHed immediately ($direct). */
    onChanged: function () {
      MessageToast.show(this.getText("saved"));
    },

    _context: function () {
      return this.getView().getBindingContext();
    },

    _refreshAll: function () {
      this.getView().getElementBinding().refresh();
      ["detailEnvironments", "detailEntitlements", "detailSubscriptions", "detailEvents"].forEach(function (sId) {
        var oBinding = this.byId(sId).getBinding("items");
        if (oBinding) { oBinding.refresh(); }
      }, this);
    },

    onSuspend: function () {
      this.callAction("SuspendSubaccount", { id: this._sId }).then(this._refreshAll.bind(this), function () {});
    },

    onReactivate: function () {
      this.callAction("ReactivateSubaccount", { id: this._sId }).then(this._refreshAll.bind(this), function () {});
    },

    onMove: function () {
      var oContext = this._context();
      var sCurrent = oContext.getProperty("parentDirectoryId") || "";
      var oInput = new Input({ value: sCurrent, placeholder: this.getText("rootDirectory") });
      MessageBox.show(oInput, {
        title: this.getText("moveTitle"),
        actions: [MessageBox.Action.OK, MessageBox.Action.CANCEL],
        onClose: function (sAction) {
          if (sAction === MessageBox.Action.OK) {
            this.callAction("MoveSubaccount", { id: this._sId, targetDirectoryId: oInput.getValue().trim() })
              .then(this._refreshAll.bind(this), function () {});
          }
        }.bind(this)
      });
    },

    _defaults: function () {
      var oContext = this._context();
      return { subaccountId: this._sId, globalAccountId: oContext ? oContext.getProperty("globalAccountId") : "" };
    },

    onCreateEnvironment: function () {
      this.openCreateDialog("Environments", this.byId("detailEnvironments").getBinding("items"), this._defaults(),
        this._refreshAll.bind(this));
    },

    onAssignEntitlement: function () {
      this.openCreateDialog("Entitlements", this.byId("detailEntitlements").getBinding("items"), this._defaults(),
        this._refreshAll.bind(this));
    },

    onCreateSubscription: function () {
      this.openCreateDialog("Subscriptions", this.byId("detailSubscriptions").getBinding("items"), this._defaults(),
        this._refreshAll.bind(this));
    },

    onDeprovision: function () {
      var oItem = this.byId("detailEnvironments").getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return;
      }
      this.confirmDelete(oItem.getBindingContext(), this.getText("confirmDeprovision"), this._refreshAll.bind(this));
    },

    onUnsubscribe: function () {
      var oItem = this.byId("detailSubscriptions").getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return;
      }
      this.callAction("Unsubscribe", { id: oItem.getBindingContext().getProperty("id") })
        .then(this._refreshAll.bind(this), function () {});
    }
  });
});
