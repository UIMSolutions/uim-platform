sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/Fragment",
  "sap/ui/core/routing/History",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "uim/authorization/model/formatter",
  "uim/authorization/model/models"
], function (Controller, UIComponent, Fragment, History, MessageBox, MessageToast, formatter, models) {
  "use strict";

  /** Fragment name of each create dialog (keyed by entity set). */
  var DIALOGS = {
    Applications: "CreateApplicationDialog",
    ApplicationApis: "CreateApplicationApiDialog",
    Policies: "CreatePolicyDialog",
    Assignments: "CreateAssignmentDialog"
  };

  return Controller.extend("uim.authorization.controller.BaseController", {
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

    /** Back to the previous page, or to the given tab of the main page. */
    navBack: function (sTab) {
      if (History.getInstance().getPreviousHash() !== undefined) {
        window.history.go(-1);
      } else {
        this.getRouter().navTo("main", { tab: sTab }, true);
      }
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
          name: "uim.authorization.fragment." + DIALOGS[sEntitySet],
          controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      return this._mDialogs[sEntitySet];
    },

    /** Draft → OData payload (lists, empty optional values). */
    toPayload: function (oDraft) {
      var oPayload = Object.assign({}, oDraft);
      if ("operationsText" in oPayload) {
        oPayload.operations = String(oPayload.operationsText || "").split(",")
          .map(function (s) { return s.trim(); })
          .filter(function (s) { return s.length > 0; });
        delete oPayload.operationsText;
      }
      ["validFrom", "validTo"].forEach(function (sKey) {
        if (sKey in oPayload && !oPayload[sKey]) { delete oPayload[sKey]; }
      });
      return oPayload;
    },

    onCreateSave: function () {
      var oCreate = this._oCreate;
      var oContext = oCreate.binding.create(this.toPayload(this.getModel("ui").getProperty("/draft")));
      oContext.created().then(function () {
        MessageToast.show(this.getText("created"));
        if (oCreate.done) { oCreate.done(oContext); }
      }.bind(this), function (oError) {
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

    /** Invoke an unbound action, e.g. callAction("DisablePolicy", {id: "…"}). */
    callAction: function (sAction, mParameters, bSilent) {
      var oOperation = this.getModel().bindContext("/" + sAction + "(...)");
      Object.keys(mParameters || {}).forEach(function (sName) {
        oOperation.setParameter(sName, mParameters[sName]);
      });
      return oOperation.execute().then(function () {
        var oResult = oOperation.getBoundContext().getObject() || {};
        if (!bSilent) {
          MessageToast.show(oResult.message || this.getText("done"));
        }
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
