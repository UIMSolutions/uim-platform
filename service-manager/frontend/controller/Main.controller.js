sap.ui.define([
  "uim/servicemanager/controller/BaseController",
  "sap/ui/core/Fragment",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox"
], function (BaseController, Fragment, Filter, FilterOperator, MessageBox) {
  "use strict";

  var DIALOGS = {
    provision: "ProvisionInstanceDialog",
    binding: "CreateBindingDialog",
    broker: "RegisterBrokerDialog",
    platform: "RegisterPlatformDialog"
  };

  return BaseController.extend("uim.servicemanager.controller.Main", {
    onInit: function () {
      this._dialogs = {};
      this.getRouter().getRoute("main").attachPatternMatched(function (event) {
        var tab = (event.getParameter("arguments") || {}).tab;
        if (tab) {
          this.getModel("view").setProperty("/tab", tab);
        }
      }, this);
    },

    onTabSelect: function (event) {
      this.getRouter().navTo("main", { tab: event.getParameter("key") }, true);
    },

    onRefresh: function () {
      this.refreshAll();
    },

    /** $search on the table named in the SearchField's customData. */
    onSearch: function (event) {
      var table = this.byId(event.getSource().data("table"));
      var query = event.getParameter("query");
      table.getBinding("items").changeParameters({ $search: query ? query : undefined });
    },

    onInstancePress: function (event) {
      var id = event.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("instance", { id: id });
    },

    // ── generic delete ────────────────────────────────────────────────────
    onDelete: function (event) {
      var table = this.byId(event.getSource().data("table"));
      var item = table.getSelectedItem();
      if (!item) {
        this.toast("selectFirst");
        return;
      }
      var context = item.getBindingContext();
      var name = context.getProperty("name") || context.getProperty("key") || context.getProperty("id");
      MessageBox.confirm(this.text("confirmDelete", [name]), {
        onClose: function (action) {
          if (action !== MessageBox.Action.OK) {
            return;
          }
          context.delete().then(function () {
            this.toast("deleted", [name]);
            this.refreshAll();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    // ── dialogs ───────────────────────────────────────────────────────────
    _openDialog: function (key) {
      if (!this._dialogs[key]) {
        this._dialogs[key] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.servicemanager.fragment." + DIALOGS[key],
          controller: this
        }).then(function (dialog) {
          this.getView().addDependent(dialog);
          return dialog;
        }.bind(this));
      }
      this._dialogs[key].then(function (dialog) {
        this._openDialogControl = dialog;
        dialog.open();
      }.bind(this));
    },

    onCloseDialog: function () {
      if (this._openDialogControl) {
        this._openDialogControl.close();
      }
    },

    /** POST a new entity through the list binding of a table. */
    _create: function (tableId, payload, successKey) {
      var context = this.byId(tableId).getBinding("items").create(payload, true);
      this.getModel("view").setProperty("/busy", true);
      return context.created().then(function () {
        this.onCloseDialog();
        this.toast(successKey, [payload.name]);
        this.refreshAll();
      }.bind(this), function (error) {
        if (!error.canceled) {
          this.showError(error);
        }
        context.delete().catch(function () { /* transient context already gone */ });
      }.bind(this)).finally(function () {
        this.getModel("view").setProperty("/busy", false);
      }.bind(this));
    },

    // provision
    onOpenProvision: function () {
      this.getModel("view").setProperty("/newInstance", { name: "", planId: "", platformId: "", parameters: "", shared: false });
      this._openDialog("provision");
    },

    onOfferingChange: function (event) {
      var offeringId = event.getParameter("selectedItem").getKey();
      var plans = this.byId("planSelect").getBinding("items");
      plans.filter(new Filter("offeringId", FilterOperator.EQ, offeringId));
      if (plans.isSuspended()) {
        plans.resume();
      }
      this.getModel("view").setProperty("/newInstance/planId", "");
    },

    onProvision: function () {
      var data = this.getModel("view").getProperty("/newInstance");
      if (!data.name || !data.planId) {
        this.toast("requiredMissing");
        return;
      }
      var payload = { name: data.name, planId: data.planId, shared: data.shared };
      if (data.platformId) {
        payload.platformId = data.platformId;
      }
      if (data.parameters) {
        payload.parameters = data.parameters;
      }
      this._create("instancesTable", payload, "provisioned");
    },

    // bindings
    onOpenBinding: function () {
      this.getModel("view").setProperty("/newBinding", { name: "", instanceId: "" });
      this._openDialog("binding");
    },

    onCreateBinding: function () {
      var data = this.getModel("view").getProperty("/newBinding");
      if (!data.name || !data.instanceId) {
        this.toast("requiredMissing");
        return;
      }
      this._create("bindingsTable", { name: data.name, instanceId: data.instanceId }, "bindingCreated");
    },

    // brokers
    onOpenBroker: function () {
      this.getModel("view").setProperty("/newBroker", { name: "", brokerUrl: "", description: "", credentials: "" });
      this._openDialog("broker");
    },

    onRegisterBroker: function () {
      var data = this.getModel("view").getProperty("/newBroker");
      if (!data.name || !data.brokerUrl) {
        this.toast("requiredMissing");
        return;
      }
      var payload = { name: data.name, brokerUrl: data.brokerUrl, description: data.description };
      if (data.credentials) {
        payload.credentials = data.credentials;
      }
      this._create("brokersTable", payload, "registered");
    },

    onSyncCatalog: function () {
      var item = this.byId("brokersTable").getSelectedItem();
      if (!item) {
        this.toast("selectFirst");
        return;
      }
      this.getModel("view").setProperty("/busy", true);
      this.invokeAction("SyncBrokerCatalog", { brokerId: item.getBindingContext().getProperty("id") })
        .then(function (result) {
          this.toast("synced", [result.brokerName, result.offeringsCreated, result.offeringsUpdated,
            result.offeringsRemoved, result.plansCreated + result.plansUpdated]);
        }.bind(this), this.showError.bind(this))
        .finally(function () {
          this.getModel("view").setProperty("/busy", false);
        }.bind(this));
    },

    // platforms
    onOpenPlatform: function () {
      this.getModel("view").setProperty("/newPlatform", { name: "", type: "cloudFoundry", region: "", description: "" });
      this._openDialog("platform");
    },

    onRegisterPlatform: function () {
      var data = this.getModel("view").getProperty("/newPlatform");
      if (!data.name) {
        this.toast("requiredMissing");
        return;
      }
      this._create("platformsTable", Object.assign({}, data), "registered");
    },

    // operations
    onCompleteOperation: function (event) {
      var item = this.byId("operationsTable").getSelectedItem();
      if (!item) {
        this.toast("selectFirst");
        return;
      }
      var succeeded = event.getSource().data("succeeded") === "true";
      var parameters = { operationId: item.getBindingContext().getProperty("id"), succeeded: succeeded };
      if (!succeeded) {
        parameters.errorMessage = this.text("failedByOperator");
      }
      this.invokeAction("CompleteOperation", parameters).then(function (result) {
        this.toast("operationCompleted", [result.status]);
      }.bind(this), this.showError.bind(this));
    }
  });
});
