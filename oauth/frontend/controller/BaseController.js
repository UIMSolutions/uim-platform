sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/routing/History",
  "sap/ui/core/Fragment",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "uim/oauth/model/formatter"
], function (Controller, UIComponent, History, Fragment, MessageBox, MessageToast, formatter) {
  "use strict";

  return Controller.extend("uim.oauth.controller.BaseController", {
    formatter: formatter,

    getRouter: function () {
      return UIComponent.getRouterFor(this);
    },

    getModel: function (name) {
      return this.getView().getModel(name);
    },

    text: function (key, args) {
      return this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(key, args);
    },

    toast: function (key, args) {
      MessageToast.show(this.text(key, args));
    },

    /** Show the backend error (OData error message or HTTP status). */
    showError: function (error) {
      MessageBox.error((error && error.message) || this.text("unknownError"));
    },

    /** Re-read everything (lists, the Statistics header, the detail page). */
    refreshAll: function () {
      this.getModel().refresh();
    },

    setBusy: function (busy) {
      this.getModel("view").setProperty("/busy", busy);
    },

    /** OK/Cancel confirmation; resolves only on OK. */
    confirm: function (key, args) {
      return new Promise(function (resolve) {
        MessageBox.confirm(this.text(key, args), {
          onClose: function (action) {
            if (action === MessageBox.Action.OK) {
              resolve();
            }
          }
        });
      }.bind(this));
    },

    /** Invoke an unbound OData action and refresh on success. */
    invokeAction: function (name, parameters) {
      var operation = this.getModel().bindContext("/" + name + "(...)");
      Object.keys(parameters || {}).forEach(function (key) {
        if (parameters[key] !== "" && parameters[key] !== undefined && parameters[key] !== null) {
          operation.setParameter(key, parameters[key]);
        }
      });
      this.setBusy(true);
      return operation.execute().then(function () {
        this.refreshAll();
        return operation.getBoundContext().getObject();
      }.bind(this)).finally(function () {
        this.setBusy(false);
      }.bind(this));
    },

    // ── the client secret is shown exactly once ─────────────────────────
    showSecret: function (clientId, clientSecret, revokedTokens) {
      this.getModel("view").setProperty("/secret", {
        clientId: clientId, clientSecret: clientSecret, revokedTokens: revokedTokens || 0
      });
      if (!this._secretDialog) {
        this._secretDialog = Fragment.load({
          id: this.getView().getId() + "--secret",
          name: "uim.oauth.fragment.SecretDialog",
          controller: this
        }).then(function (dialog) {
          this.getView().addDependent(dialog);
          return dialog;
        }.bind(this));
      }
      this._secretDialog.then(function (dialog) {
        dialog.open();
      });
    },

    onCopySecret: function () {
      var secret = this.getModel("view").getProperty("/secret/clientSecret");
      if (navigator.clipboard) {
        navigator.clipboard.writeText(secret).then(function () {
          this.toast("copied");
        }.bind(this));
      }
    },

    onCloseSecret: function () {
      this.getModel("view").setProperty("/secret", { clientId: "", clientSecret: "", revokedTokens: 0 });
      this._secretDialog.then(function (dialog) {
        dialog.close();
      });
    },

    onNavBack: function () {
      if (History.getInstance().getPreviousHash() !== undefined) {
        window.history.go(-1);
      } else {
        this.getRouter().navTo("main", {}, true);
      }
    }
  });
});
