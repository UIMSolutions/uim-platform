sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/Fragment",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "uim/management/model/formatter",
  "uim/management/model/models"
], function (Controller, UIComponent, Fragment, MessageBox, MessageToast, formatter, models) {
  "use strict";

  /** Fragment name and entity set of each create dialog. */
  var DIALOGS = {
    GlobalAccounts: "CreateGlobalAccountDialog",
    Directories: "CreateDirectoryDialog",
    Subaccounts: "CreateSubaccountDialog",
    Entitlements: "AssignEntitlementDialog",
    Environments: "CreateEnvironmentDialog",
    Subscriptions: "CreateSubscriptionDialog",
    ServicePlans: "CreateServicePlanDialog",
    Labels: "CreateLabelDialog"
  };

  return Controller.extend("uim.management.controller.BaseController", {
    formatter: formatter,

    getRouter: function () {
      return UIComponent.getRouterFor(this);
    },

    getModel: function (sName) {
      return this.getView().getModel(sName);
    },

    getText: function (sKey, aArgs) {
      return this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(sKey, aArgs);
    },

    /** Show an OData / backend error. */
    showError: function (oError) {
      var sMessage = (oError && (oError.message || oError.statusText)) || String(oError);
      MessageBox.error(sMessage);
    },

    // ── Create dialogs (one fragment per entity set, shared "ui>/draft") ──

    /**
     * Open the create dialog of an entity set. The dialog writes into "ui>/draft";
     * on save the draft is POSTed through the given list binding.
     */
    openCreateDialog: function (sEntitySet, oListBinding, oDefaults, fnDone) {
      this._oCreate = { entitySet: sEntitySet, binding: oListBinding, done: fnDone };
      this.getModel("ui").setProperty("/draft", models.emptyDraft(sEntitySet, oDefaults));
      this._dialog(sEntitySet).then(function (oDialog) { oDialog.open(); });
    },

    _dialog: function (sEntitySet) {
      this._mDialogs = this._mDialogs || {};
      if (!this._mDialogs[sEntitySet]) {
        this._mDialogs[sEntitySet] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.management.fragment." + DIALOGS[sEntitySet],
          controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      return this._mDialogs[sEntitySet];
    },

    onCreateSave: function () {
      var oCreate = this._oCreate;
      var oDraft = Object.assign({}, this.getModel("ui").getProperty("/draft"));
      ["maxSubaccounts", "maxDirectories", "quotaAssigned", "memoryQuotaMb", "routeQuota", "serviceQuota", "maxQuota"]
        .forEach(function (sKey) {
          if (sKey in oDraft) { oDraft[sKey] = parseInt(oDraft[sKey], 10) || 0; }
        });
      if ("valuesText" in oDraft) {
        oDraft.values = String(oDraft.valuesText).split(",").map(function (s) { return s.trim(); })
          .filter(function (s) { return s.length > 0; });
        delete oDraft.valuesText;
      }
      var oContext = oCreate.binding.create(oDraft);
      oContext.created().then(function () {
        MessageToast.show(this.getText("created"));
        if (oCreate.done) { oCreate.done(oContext); }
      }.bind(this), function (oError) {
        // keep the transient row out of the table on failure
        if (!oContext.isTransient || oContext.isTransient()) {
          oContext.delete().catch(function () { /* already gone */ });
        }
        this.showError(oError);
      }.bind(this));
      this.onCreateCancel();
    },

    onCreateCancel: function () {
      this._dialog(this._oCreate.entitySet).then(function (oDialog) { oDialog.close(); });
    },

    // ── Unbound OData actions ─────────────────────────────────────────────

    /** Invoke an unbound action, e.g. callAction("SuspendSubaccount", {id: "…"}). */
    callAction: function (sAction, mParameters) {
      var oOperation = this.getModel().bindContext("/" + sAction + "(...)");
      Object.keys(mParameters || {}).forEach(function (sName) {
        oOperation.setParameter(sName, mParameters[sName]);
      });
      return oOperation.execute().then(function () {
        var oResult = oOperation.getBoundContext().getObject() || {};
        MessageToast.show(oResult.message || this.getText("done"));
        this.getModel().refresh();
        return oResult;
      }.bind(this), function (oError) {
        this.showError(oError);
        throw oError;
      }.bind(this));
    },

    /** Ask, then delete the given binding context. */
    confirmDelete: function (oContext, sQuestion, fnDone) {
      MessageBox.confirm(sQuestion, {
        emphasizedAction: MessageBox.Action.OK,
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          oContext.delete().then(function () {
            MessageToast.show(this.getText("deleted"));
            if (fnDone) { fnDone(); }
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    }
  });
});
