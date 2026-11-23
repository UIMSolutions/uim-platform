sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/routing/History",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "sap/ui/core/Fragment",
  "uim/dataquality/model/formatter",
  "uim/dataquality/model/models",
  "uim/dataquality/model/session"
], function (Controller, UIComponent, History, Filter, FilterOperator, MessageBox, MessageToast, Fragment, formatter, models, session) {
  "use strict";

  return Controller.extend("uim.dataquality.controller.BaseController", {
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

    // ── session (built-in JWT login) ───────────────────────────────────────
    onUserMenu: function (event) {
      var button = event.getSource();
      if (!this._userMenu) {
        this._userMenu = Fragment.load({ id: this.getView().getId(), name: "uim.dataquality.fragment.UserMenu", controller: this })
          .then(function (menu) {
            this.getView().addDependent(menu);
            return menu;
          }.bind(this));
      }
      this._userMenu.then(function (menu) { menu.openBy(button); });
    },

    onLogout: function () {
      this.getOwnerComponent().logout();
    },

    onChangePassword: function () {
      if (!this._passwordDialog) {
        this._passwordDialog = Fragment.load({ id: this.getView().getId(), name: "uim.dataquality.fragment.PasswordDialog", controller: this })
          .then(function (dialog) {
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

    /** Invoke an unbound OData action and refresh on success; resolves with the result. */
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

    /** EQ filters from {property: value}; empty values are skipped. */
    eqFilters: function (values) {
      return Object.keys(values).filter(function (name) {
        return values[name];
      }).map(function (name) {
        return new Filter(name, FilterOperator.EQ, values[name]);
      });
    },

    /** Apply filters to the items of a (possibly suspended) table and resume it. */
    filterTable: function (tableId, values) {
      var binding = this.byId(tableId).getBinding("items");
      binding.filter(this.eqFilters(values));
      if (binding.isSuspended()) {
        binding.resume();
      }
    },

    /** Bind the view to "/<set>('<key>')". */
    bindTo: function (set, key) {
      this.getView().bindElement({ path: models.entityPath(set, key) });
    },

    // ── dialogs (shared by Main and DatasetDetail) ─────────────────────────
    /**
     * Open the dialog of a form key (see DIALOGS of the subclass): reset the
     * form to its defaults plus prefill, load the fragment once.
     */
    openDialog: function (key, prefill) {
      var def = this.dialogs()[key];
      this._dialogs = this._dialogs || {};
      this._current = key;
      this.getModel("view").setProperty("/form/" + key, Object.assign(models.emptyForms()[key], prefill || {}));
      if (!this._dialogs[key]) {
        this._dialogs[key] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.dataquality.fragment." + def.fragment,
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
      this.openDialog(event.getSource().data("dialog"), this.dialogPrefill ? this.dialogPrefill(event.getSource().data("dialog")) : {});
    },

    onCloseDialog: function () {
      if (this._openDialogControl) {
        this._openDialogControl.close();
      }
    },

    /** The current form, or null (toast) if a required field is empty. */
    currentForm: function () {
      var key = this._current;
      var form = Object.assign({}, this.getModel("view").getProperty("/form/" + key));
      var missing = (this.dialogs()[key].required || []).some(function (name) {
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
     * separate, unrendered list binding, a PATCH of an existing entity
     * (def.patch) or an action (def.action). Closes and refreshes on success.
     */
    onSave: function () {
      var form = this.currentForm();
      if (!form) {
        return;
      }
      var def = this.dialogs()[this._current];
      var done = function (result) {
        this.onCloseDialog();
        this.toast(def.toast || "saved", def.toastArgs ? def.toastArgs(result || {}, form) : []);
        this.refreshAll();
      }.bind(this);
      if (def.action) {
        this.invokeAction(def.action, def.payload(form)).then(done, this.showError.bind(this));
        return;
      }
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
      created.created().then(function () {
        done(created.getObject());
      }, function (error) {
        if (!error.canceled) {
          this.showError(error);
        }
        created.delete().catch(function () { /* transient context already gone */ });
      }.bind(this)).finally(function () {
        this.setBusy(false);
        binding.destroy();
      }.bind(this));
    },

    /** Cleansing job dialog: MultiComboBox selection → rule ids. */
    onJobRules: function (event) {
      this.getModel("view").setProperty("/form/cleansingJob/ruleIds",
        event.getSource().getSelectedKeys().join("\n"));
    },

    /** Resolve dialog: radio button → survivor. */
    onSurvivor: function (event) {
      var candidates = this.getModel("view").getProperty("/form/resolve/candidates");
      this.getModel("view").setProperty("/form/resolve/survivorRecordId", candidates[event.getParameter("selectedIndex")].recordId);
    },

    /** Dialogs of the subclass: key → { fragment, set | action, required, payload, toast }. */
    dialogs: function () {
      return {};
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
      var name = context.getProperty("name") || context.getProperty("id") || context.getProperty("key");
      this.confirm("confirmDelete", [name]).then(function () {
        return context.delete().then(function () {
          this.toast("deleted");
          this.refreshAll();
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    /** Set the status of the selected rule (customData: table, status). */
    onSetStatus: function (event) {
      var source = event.getSource();
      var context = this.selected(source.data("table"));
      if (!context) {
        return;
      }
      var status = source.data("status");
      context.setProperty("status", status).then(function () {
        this.toast("statusChanged", [context.getProperty("name"), this.formatter.enumText(status)]);
      }.bind(this), this.showError.bind(this));
    },

    /** Invoke a dataset action (customData: action) for a dataset id. */
    runDatasetAction: function (action, datasetId) {
      return this.invokeAction(action, { datasetId: datasetId }).then(function (r) {
        var f = this.formatter;
        switch (action) {
        case "ValidateDataset":
          this.toast("validated", [r.records, r.invalidRecords, r.violations, f.score(r.overallScore)]);
          break;
        case "ProfileDataset":
          this.toast("profiled", [r.columns, r.records]);
          break;
        default:
          this.toast("scored", [f.score(r.overallScore), f.enumText(r.rating)]);
        }
        return r;
      }.bind(this), this.showError.bind(this));
    },

    onNavBack: function () {
      if (History.getInstance().getPreviousHash() !== undefined) {
        window.history.go(-1);
      } else {
        this.getRouter().navTo("main", {}, true);
      }
    },

    onRefresh: function () {
      this.refreshAll();
    }
  });
});
