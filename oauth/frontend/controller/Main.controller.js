sap.ui.define([
  "uim/oauth/controller/BaseController",
  "uim/oauth/model/models",
  "sap/ui/core/Fragment"
], function (BaseController, models, Fragment) {
  "use strict";

  /** Strip empty optional texts so the backend applies its defaults. */
  function compact(object) {
    var result = {};
    Object.keys(object).forEach(function (key) {
      if (object[key] !== "" && object[key] !== null && object[key] !== undefined) {
        result[key] = object[key];
      }
    });
    return result;
  }

  /** dialog key → fragment, target table, required form fields, payload builder */
  var DIALOGS = {
    client: {
      fragment: "CreateClientDialog", table: "clientsTable", required: ["name"],
      payload: function (f) {
        return compact({
          name: f.name, clientId: f.clientId, clientType: f.clientType, description: f.description,
          grantTypes: f.grantTypes, allowedScopes: f.allowedScopes, redirectUris: models.lines(f.redirectUris),
          contacts: models.lines(f.contacts),
          accessTokenValidity: Number(f.accessTokenValidity) || undefined,
          refreshTokenValidity: Number(f.refreshTokenValidity) || undefined
        });
      }
    },
    scope: {
      fragment: "CreateScopeDialog", table: "scopesTable", required: ["applicationId", "name"],
      payload: compact
    },
    branding: {
      fragment: "CreateBrandingDialog", table: "brandingsTable", required: ["name"],
      payload: compact
    },
    testToken: { fragment: "TestTokenDialog", required: ["clientId", "clientSecret"] },
    introspect: { fragment: "IntrospectDialog", required: ["token"] }
  };

  return BaseController.extend("uim.oauth.controller.Main", {
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

    onClientPress: function (event) {
      this.getRouter().navTo("client", { id: event.getSource().getBindingContext().getProperty("id") });
    },

    _selected: function (tableId) {
      var item = this.byId(tableId).getSelectedItem();
      if (!item) {
        this.toast("selectFirst");
        return null;
      }
      return item.getBindingContext();
    },

    _nameOf: function (context) {
      return context.getProperty("name") || context.getProperty("clientId") || context.getProperty("id");
    },

    // ── generic delete / status ───────────────────────────────────────────
    onDelete: function (event) {
      var context = this._selected(event.getSource().data("table"));
      if (!context) {
        return;
      }
      var name = this._nameOf(context);
      this.confirm("confirmDelete", [name]).then(function () {
        return context.delete().then(function () {
          this.toast("deleted", [name]);
          this.refreshAll();
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    onSetStatus: function (event) {
      var source = event.getSource();
      var context = this._selected(source.data("table"));
      if (!context) {
        return;
      }
      var status = source.data("status");
      var apply = function () {
        context.setProperty("status", status).then(function () {
          this.toast("statusChanged", [this._nameOf(context), this.formatter.enumText(status)]);
          this.refreshAll();
        }.bind(this), this.showError.bind(this));
      }.bind(this);
      if (status === "blocked") {
        this.confirm("confirmBlock", [this._nameOf(context)]).then(apply);
      } else {
        apply();
      }
    },

    // ── client actions ────────────────────────────────────────────────────
    onRotateSecret: function () {
      var context = this._selected("clientsTable");
      if (!context) {
        return;
      }
      if (context.getProperty("clientType") !== "confidential") {
        this.toast("publicNoSecret");
        return;
      }
      this.confirm("confirmRotate", [this._nameOf(context)]).then(function () {
        return this.invokeAction("RotateClientSecret", { id: context.getProperty("id") }).then(function (r) {
          this.showSecret(r.clientId, r.clientSecret, r.revokedTokens);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    onRevokeClientTokens: function () {
      var context = this._selected("clientsTable");
      if (!context) {
        return;
      }
      this.confirm("confirmRevokeClient", [this._nameOf(context)]).then(function () {
        return this.invokeAction("RevokeClientTokens", { id: context.getProperty("id") }).then(function (r) {
          this.toast("revokedCounts", [r.accessTokens, r.refreshTokens, r.codes]);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    /** Revoke the selected access / refresh token (action name in customData). */
    onRevoke: function (event) {
      var source = event.getSource();
      var context = this._selected(source.data("table"));
      if (!context) {
        return;
      }
      this.invokeAction(source.data("action"), { id: context.getProperty("id") }).then(function (r) {
        this.toast("revokedCounts", [r.accessTokens, r.refreshTokens, r.codes]);
      }.bind(this), this.showError.bind(this));
    },

    onMakeDefault: function () {
      var context = this._selected("brandingsTable");
      if (!context) {
        return;
      }
      context.setProperty("isDefault", true).then(function () {
        this.toast("defaultBranding", [this._nameOf(context)]);
        this.refreshAll();
      }.bind(this), this.showError.bind(this));
    },

    onPurge: function () {
      this.confirm("confirmPurge").then(function () {
        return this.invokeAction("PurgeExpired", {}).then(function (r) {
          this.toast("purged", [r.accessTokens, r.refreshTokens, r.codes]);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    // ── dialogs ───────────────────────────────────────────────────────────
    _openDialog: function (key, prefill) {
      this._current = key;
      this.getModel("view").setProperty("/form/" + key, Object.assign(models.emptyForms()[key], prefill || {}));
      if (!this._dialogs[key]) {
        this._dialogs[key] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.oauth.fragment." + DIALOGS[key].fragment,
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

    onOpenDialog: function (event) {
      this._openDialog(event.getSource().data("dialog"));
    },

    onOpenTestToken: function () {
      var item = this.byId("clientsTable").getSelectedItem();
      this.getModel("view").setProperty("/token", null);
      this._openDialog("testToken", item ? { clientId: item.getBindingContext().getProperty("clientId") } : {});
    },

    onOpenIntrospect: function () {
      this.getModel("view").setProperty("/introspection", null);
      this._openDialog("introspect");
    },

    onCloseDialog: function () {
      if (this._openDialogControl) {
        this._openDialogControl.close();
      }
    },

    _form: function () {
      var key = this._current;
      var form = Object.assign({}, this.getModel("view").getProperty("/form/" + key));
      var missing = DIALOGS[key].required.some(function (name) {
        return !form[name];
      });
      if (missing) {
        this.toast("requiredMissing");
        return null;
      }
      return form;
    },

    /**
     * POST a new entity through a separate, unrendered list binding. Creating
     * through the table's binding would render a transient row whose relative
     * list bindings on collection properties (grant types, scopes) UI5 treats
     * as a deep create. Without $select the full POST response is kept —
     * including the client secret that is returned exactly once.
     */
    onSave: function () {
      var form = this._form();
      if (!form) {
        return;
      }
      var key = this._current;
      var def = DIALOGS[key];
      var payload = def.payload(form);
      var binding = this.getModel().bindList("/" + this.byId(def.table).getBinding("items").getPath().replace(/^\//, ""));
      var context = binding.create(payload, true);
      this.setBusy(true);
      context.created().then(function () {
        var created = context.getObject() || {};
        this.onCloseDialog();
        this.toast("created", [payload.name]);
        if (key === "client" && created.clientSecret) {
          this.showSecret(created.clientId, created.clientSecret, 0);
        }
        this.refreshAll();
      }.bind(this), function (error) {
        if (!error.canceled) {
          this.showError(error);
        }
        context.delete().catch(function () { /* transient context already gone */ });
      }.bind(this)).finally(function () {
        this.setBusy(false);
        binding.destroy();
      }.bind(this));
    },

    onRequestToken: function () {
      var form = this._form();
      if (!form) {
        return;
      }
      this.invokeAction("RequestClientToken", form).then(function (result) {
        this.getModel("view").setProperty("/token", result);
        this.getModel("view").setProperty("/form/testToken/clientSecret", "");
      }.bind(this), this.showError.bind(this));
    },

    onIntrospect: function () {
      var form = this._form();
      if (!form) {
        return;
      }
      this.invokeAction("IntrospectToken", form).then(function (result) {
        this.getModel("view").setProperty("/introspection", result);
      }.bind(this), this.showError.bind(this));
    }
  });
});
