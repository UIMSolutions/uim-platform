sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/routing/History",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "sap/ui/core/Fragment",
  "uim/ailaunchpad/model/formatter",
  "uim/ailaunchpad/model/models",
  "uim/ailaunchpad/model/session",
  "uim/ailaunchpad/model/dialogs"
], function (Controller, UIComponent, History, Filter, FilterOperator, MessageBox, MessageToast, Fragment, formatter, models,
  session, DIALOGS) {
  "use strict";

  /**
   * Shared behaviour of all pages: session (user menu, password, logout),
   * routing between launchpad and apps, generic dialogs for create / edit,
   * delete, unbound OData actions and table filters.
   */
  return Controller.extend("uim.ailaunchpad.controller.BaseController", {
    formatter: formatter,

    getRouter: function () {
      return UIComponent.getRouterFor(this);
    },

    getModel: function (name) {
      return this.getView().getModel(name) || this.getOwnerComponent().getModel(name);
    },

    text: function (key, args) {
      return this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(key, args);
    },

    toast: function (key, args) {
      MessageToast.show(this.text(key, args));
    },

    /** Show the backend error; an expired session (401) leads back to the login. */
    showError: function (error) {
      if (error && error.status === 401 && this.getModel("session").getProperty("/loginRequired")) {
        MessageBox.warning(this.text("sessionExpired"), {
          onClose: function () { this.getOwnerComponent().logout(); }.bind(this)
        });
        return;
      }
      MessageBox.error((error && error.message) || this.text("unknownError"));
    },

    // ── page / navigation ──────────────────────────────────────────────────
    /** Register a route of an app page: sets the shell title and the selected tab. */
    attachPage: function (route, titleKey, defaultTab, onMatched) {
      this.getRouter().getRoute(route).attachPatternMatched(function (event) {
        var tab = (event.getParameter("arguments") || {}).tab || defaultTab;
        var view = this.getModel("view");
        view.setProperty("/page", route);
        view.setProperty("/pageTitle", this.text(titleKey));
        view.setProperty("/tab", tab);
        if (onMatched) {
          onMatched.call(this, tab);
        }
      }, this);
    },

    /** IconTabBar selection → URL (keeps the browser history clean). */
    onTabSelect: function (event) {
      this.getRouter().navTo(this.getModel("view").getProperty("/page"), { tab: event.getParameter("key") }, true);
    },

    onNavBack: function () {
      if (History.getInstance().getPreviousHash() !== undefined) {
        window.history.go(-1);
      } else {
        this.getRouter().navTo("launchpad", {}, true);
      }
    },

    onHome: function () {
      this.getRouter().navTo("launchpad");
    },

    // ── session (built-in JWT login) ───────────────────────────────────────
    onUserMenu: function (event) {
      var source = event.getParameter("avatar") || event.getSource();
      if (!this._userMenu) {
        this._userMenu = Fragment.load({ id: this.getView().getId(), name: "uim.ailaunchpad.fragment.UserMenu", controller: this })
          .then(function (menu) {
            this.getView().addDependent(menu);
            return menu;
          }.bind(this));
      }
      this._userMenu.then(function (menu) { menu.openBy(source); });
    },

    onCloseUserMenu: function () {
      if (this._userMenu) {
        this._userMenu.then(function (menu) { menu.close(); });
      }
    },

    onLogout: function () {
      this.getOwnerComponent().logout();
    },

    onChangePassword: function () {
      if (!this._passwordDialog) {
        this._passwordDialog = Fragment.load({ id: this.getView().getId(), name: "uim.ailaunchpad.fragment.PasswordDialog",
          controller: this }).then(function (dialog) {
          this.getView().addDependent(dialog);
          return dialog;
        }.bind(this));
      }
      this.getModel("view").setProperty("/password", { current: "", next: "", repeat: "" });
      this._passwordDialog.then(function (dialog) { dialog.open(); });
    },

    onSavePassword: function () {
      var p = this.getModel("view").getProperty("/password");
      if (!p.current || !p.next) {
        this.toast("requiredMissing");
        return;
      }
      if (p.next !== p.repeat) {
        this.toast("passwordMismatch");
        return;
      }
      session.changePassword(this.getModel("session").getProperty("/token"), p.current, p.next).then(function () {
        this._passwordDialog.then(function (dialog) { dialog.close(); });
        this.toast("passwordChanged");
      }.bind(this), this.showError.bind(this));
    },

    onClosePassword: function () {
      this._passwordDialog.then(function (dialog) { dialog.close(); });
    },

    // ── helpers ────────────────────────────────────────────────────────────
    /** Re-read everything that is bound to the OData model. */
    refreshAll: function () {
      this.getModel().refresh();
    },

    onRefresh: function () {
      this.refreshAll();
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

    /** Invoke an unbound OData action and refresh on success; resolves with the result. */
    invokeAction: function (name, parameters, keepBusy) {
      var operation = this.getModel().bindContext("/" + name + "(...)");
      Object.keys(parameters || {}).forEach(function (key) {
        if (parameters[key] !== "" && parameters[key] !== undefined && parameters[key] !== null) {
          operation.setParameter(key, parameters[key]);
        }
      });
      if (!keepBusy) {
        this.setBusy(true);
      }
      return operation.execute().then(function () {
        this.refreshAll();
        return operation.getBoundContext().getObject();
      }.bind(this)).finally(function () {
        if (!keepBusy) {
          this.setBusy(false);
        }
      }.bind(this));
    },

    /** Apply filters to the items of a (possibly suspended) table and resume it. */
    applyFilters: function (tableId, filters) {
      var binding = this.byId(tableId).getBinding("items");
      binding.filter(filters);
      if (binding.isSuspended()) {
        binding.resume();
      }
    },

    /** EQ filters from {property: value}; empty values are skipped. */
    eqFilters: function (values) {
      return Object.keys(values).filter(function (name) {
        return values[name] !== "" && values[name] !== undefined && values[name] !== null;
      }).map(function (name) {
        return new Filter(name, FilterOperator.EQ, values[name]);
      });
    },

    /** $search on the table named in the SearchField's customData. */
    onSearch: function (event) {
      var table = this.byId(event.getSource().data("table"));
      var query = event.getParameter("query");
      table.getBinding("items").changeParameters({ $search: query ? query : undefined });
    },

    // ── dialogs ─────────────────────────────────────────────────────────────
    /** Prefill of a dialog opened from a toolbar (override). */
    dialogPrefill: function () {
      return {};
    },

    /** Open the dialog of a form key: reset the form to its defaults plus prefill, load the fragment once. */
    openDialog: function (key, prefill) {
      var def = DIALOGS[key];
      this._dialogs = this._dialogs || {};
      this._current = key;
      this.getModel("view").setProperty("/form/" + key, Object.assign(models.emptyForms()[key], prefill || {}));
      if (!this._dialogs[key]) {
        this._dialogs[key] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.ailaunchpad.fragment." + def.fragment,
          controller: this
        }).then(function (dialog) {
          this.getView().addDependent(dialog);
          return dialog;
        }.bind(this));
      }
      return this._dialogs[key].then(function (dialog) {
        this._openDialogControl = dialog;
        dialog.open();
        return dialog;
      }.bind(this));
    },

    onOpenDialog: function (event) {
      var key = event.getSource().data("dialog");
      this.openDialog(key, this.dialogPrefill(key));
    },

    onCloseDialog: function () {
      if (this._openDialogControl) {
        this._openDialogControl.close();
      }
    },

    /** Edit the selected row in its dialog (customData: table, dialog): copy the matching members. */
    onEdit: function (event) {
      var source = event.getSource();
      var context = this.selected(source.data("table"));
      if (context) {
        this.editRow(source.data("dialog"), context.getObject());
      }
    },

    /** Lists become text: one entry per line (labels, parameters) or comma separated (short lists). */
    editRow: function (dialog, row) {
      var form = models.emptyForms()[dialog];
      var commaLists = ["executables", "roles", "scopes"];
      Object.keys(form).forEach(function (name) {
        if (row[name] !== undefined && row[name] !== null) {
          form[name] = Array.isArray(row[name]) ? row[name].join(commaLists.indexOf(name) >= 0 ? ", " : "\n") : row[name];
        }
      });
      form.edit = true;
      this.openDialog(dialog, form);
    },

    /** MultiComboBox of the user dialog → form text "Viewer, Operator". */
    onUserRoles: function (event) {
      this.getModel("view").setProperty("/form/user/roles", event.getSource().getSelectedKeys().join(", "));
    },

    /** MultiComboBox of the role dialog → form text "Read, Operate". */
    onRoleScopes: function (event) {
      this.getModel("view").setProperty("/form/role/scopes", event.getSource().getSelectedKeys().join(", "));
    },

    /** The current form, or null (toast) if a required field is empty. */
    currentForm: function () {
      var key = this._current;
      var form = Object.assign({}, this.getModel("view").getProperty("/form/" + key));
      var missing = (DIALOGS[key].required || []).some(function (name) {
        return form[name] === "" || form[name] === undefined || form[name] === null;
      });
      if (missing) {
        this.toast("requiredMissing");
        return null;
      }
      return form;
    },

    /**
     * Save the current dialog: an entity create (def.set) through a
     * separate, unrendered list binding or a PATCH of an existing entity
     * (def.patch). Closes and refreshes on success.
     */
    onSave: function () {
      var form = this.currentForm();
      if (!form) {
        return;
      }
      var def = DIALOGS[this._current];
      var done = function () {
        this.onCloseDialog();
        this.toast(form.edit ? "saved" : "created");
        this.refreshAll();
      }.bind(this);
      if (def.patch && def.patch(form)) {
        var serviceUrl = this.getOwnerComponent().getManifestEntry("/sap.app/dataSources/mainService").uri;
        this.setBusy(true);
        session.patch(serviceUrl, models.entityPath(def.set, def.patch(form)), def.payload(form),
          this.getModel("session").getProperty("/token"))
          .then(done, this.showError.bind(this)).finally(function () {
            this.setBusy(false);
          }.bind(this));
        return;
      }
      var binding = this.getModel().bindList("/" + def.set);
      var created = binding.create(def.payload(form), true);
      this.setBusy(true);
      created.created().then(done, function (error) {
        if (!error.canceled) {
          this.showError(error);
        }
        created.delete().catch(function () { /* transient context already gone */ });
      }.bind(this)).finally(function () {
        this.setBusy(false);
        binding.destroy();
      }.bind(this));
    },

    /** Selected row context of a table, or null (toast). */
    selected: function (tableId) {
      var item = this.byId(tableId).getSelectedItem();
      if (!item) {
        this.toast("selectFirst");
        return null;
      }
      return item.getBindingContext();
    },

    /** Delete the selected row of the table named in the button's customData. */
    onDelete: function (event) {
      var context = this.selected(event.getSource().data("table"));
      if (!context) {
        return;
      }
      var name = context.getProperty("name") || context.getProperty("title") || context.getProperty("id");
      this.confirm("confirmDelete", [name]).then(function () {
        return context.delete().then(function () {
          this.toast("deleted");
          this.refreshAll();
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    /**
     * Action on the selected row of a table (customData: table, action,
     * toast, confirm (optional i18n key)). The toast gets the id, the
     * translated status and the status message of the result.
     */
    onOperation: function (event) {
      var source = event.getSource();
      var context = this.selected(source.data("table"));
      if (!context) {
        return;
      }
      var id = context.getProperty("id");
      var run = function () {
        this.invokeAction(source.data("action"), { id: id }).then(function (r) {
          r = r || {};
          this.toast(source.data("toast") || "done", [r.name || r.id || id, this.formatter.enumText.call(this, r.status),
            r.statusMessage || ""]);
        }.bind(this), this.showError.bind(this));
      }.bind(this);
      if (source.data("confirm")) {
        this.confirm(source.data("confirm"), [context.getProperty("name") || id]).then(run);
      } else {
        run();
      }
    },

    /** Synchronize executions and deployments with the runtimes now. */
    onReconcile: function () {
      this.invokeAction("Reconcile", {}).then(function (r) {
        MessageToast.show(r.summary);
      }, this.showError.bind(this));
    }
  });
});
