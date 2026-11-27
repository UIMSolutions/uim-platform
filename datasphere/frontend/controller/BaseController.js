sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/routing/History",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "sap/ui/core/Fragment",
  "uim/datasphere/model/formatter",
  "uim/datasphere/model/models",
  "uim/datasphere/model/session",
  "uim/datasphere/model/dialogs"
], function (Controller, UIComponent, History, Filter, FilterOperator, MessageBox, MessageToast, Fragment, formatter, models,
  session, DIALOGS) {
  "use strict";

  return Controller.extend("uim.datasphere.controller.BaseController", {
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
        this._userMenu = Fragment.load({ id: this.getView().getId(), name: "uim.datasphere.fragment.UserMenu", controller: this })
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
        this._passwordDialog = Fragment.load({ id: this.getView().getId(), name: "uim.datasphere.fragment.PasswordDialog",
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

    filterTable: function (tableId, values) {
      this.applyFilters(tableId, this.eqFilters(values));
    },

    /** $search on the table named in the SearchField's customData. */
    onSearch: function (event) {
      var table = this.byId(event.getSource().data("table"));
      var query = event.getParameter("query");
      table.getBinding("items").changeParameters({ $search: query ? query : undefined });
    },

    /** Bind the view to "/<set>('<key>')". */
    bindTo: function (set, key) {
      this.getView().bindElement({ path: models.entityPath(set, key) });
    },

    // ── dialogs ─────────────────────────────────────────────────────────────
    dialogs: function () {
      return DIALOGS;
    },

    /** Prefill of a dialog opened from a toolbar (override). */
    dialogPrefill: function () {
      return {};
    },

    /** Open the dialog of a form key: reset the form to its defaults plus prefill, load the fragment once. */
    openDialog: function (key, prefill) {
      var def = this.dialogs()[key];
      this._dialogs = this._dialogs || {};
      this._current = key;
      this.getModel("view").setProperty("/form/" + key, Object.assign(models.emptyForms()[key], prefill || {}));
      if (!this._dialogs[key]) {
        this._dialogs[key] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.datasphere.fragment." + def.fragment,
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
      if (!context) {
        return;
      }
      this.editRow(source.data("dialog"), context.getObject());
    },

    /** Edit the object of a detail page (customData: dialog). */
    onEditObject: function (event) {
      var context = this.getView().getBindingContext();
      if (context) {
        this.editRow(event.getSource().data("dialog"), context.getObject());
      }
    },

    editRow: function (dialog, row) {
      var form = models.emptyForms()[dialog];
      Object.keys(form).forEach(function (name) {
        if (row[name] !== undefined && row[name] !== null) {
          form[name] = Array.isArray(row[name]) ? row[name].join("\n") : row[name];
        }
      });
      form.edit = true;
      this.openDialog(dialog, form);
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
     * (def.patch) or an action (def.action). Closes and refreshes on success
     * (def.keepOpen: the result is shown by dialogResult).
     */
    onSave: function () {
      var form = this.currentForm();
      if (!form) {
        return;
      }
      var key = this._current;
      var def = this.dialogs()[key];
      if (def.check && !def.check(form)) {
        this.toast(key === "accessCheck" ? "invalidRow" : "requiredMissing");
        return;
      }
      var done = function (result) {
        result = result || {};
        if (def.keepOpen) {
          this.dialogResult(key, result, form);
          return;
        }
        this.onCloseDialog();
        this.toast(def.toast || "saved", def.toastArgs ? def.toastArgs(result, form) : []);
        this.refreshAll();
      }.bind(this);
      var action = typeof def.action === "function" ? def.action(form) : def.action;
      if (action) {
        this.invokeAction(action, def.payload(form)).then(done, this.showError.bind(this));
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

    /** Dialogs that keep their result: the access check shows the decision in the dialog. */
    dialogResult: function (key, result) {
      if (key === "accessCheck") {
        this.getModel("view").setProperty("/form/accessCheck/result", result);
      }
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
      var name = context.getProperty("name") || context.getProperty("title") || context.getProperty("summary")
        || context.getProperty("id");
      this.confirm("confirmDelete", [name]).then(function () {
        return context.delete().then(function () {
          this.toast("deleted");
          this.refreshAll();
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    // ── operations ──────────────────────────────────────────────────────────
    /** The context of the pressed button's row, the selected row of a table (customData table) or the page object. */
    targetContext: function (event) {
      var source = event.getSource();
      var tableId = source.data && source.data("table");
      if (tableId) {
        return this.selected(tableId);
      }
      var own = source.getBindingContext();
      var page = this.getView().getBindingContext();
      return own && (!page || own.getPath() !== page.getPath()) && own.getPath().indexOf("(") > 0 ? own : page;
    },

    /**
     * Action on the selected row of a table or on the bound object of a
     * detail view (customData: table (optional), action, toast, confirm
     * (optional i18n key), run ("true": the result is a run, shown in a box)).
     */
    onOperation: function (event) {
      var source = event.getSource();
      var context = this.targetContext(event);
      if (!context) {
        return;
      }
      var parameters = { id: context.getProperty("id") };
      var run = function () {
        return this.invokeAction(source.data("action"), parameters).then(function (r) {
          r = r || {};
          if (source.data("run") === "true") {
            this.showRun(r);
            return;
          }
          var name = r.businessName || r.name || r.id;
          var status = this.formatter.enumText.call(this, r.status || r.deploymentStatus || r.replicationStatus);
          this.toast(source.data("toast") || "done", [name, status, r.statusMessage || ""]);
        }.bind(this), this.showError.bind(this));
      }.bind(this);
      if (source.data("confirm")) {
        var label = context.getProperty("businessName") || context.getProperty("name") || context.getProperty("id");
        this.confirm(source.data("confirm"), [label]).then(run);
      } else {
        run();
      }
    },

    /** Pause or resume the schedule of a task / task chain (customData: table, kind = Task | TaskChain). */
    onPauseResume: function (event) {
      var source = event.getSource();
      var context = this.targetContext(event);
      if (!context) {
        return;
      }
      var kind = source.data("kind") || "Task";
      var paused = context.getProperty("status") === "paused";
      this.invokeAction((paused ? "Resume" : "Pause") + kind, { id: context.getProperty("id") }).then(function (r) {
        this.toast(paused ? "resumed" : "paused", [r.name]);
      }.bind(this), this.showError.bind(this));
    },

    /** A run in a message box: success, warning (cancelled) or error. */
    showRun: function (r) {
      var text = this.text("runText", [this.formatter.enumText.call(this, r.objectType), r.objectName,
        this.formatter.enumText.call(this, r.status), this.formatter.count(r.rowsProcessed), this.formatter.duration(r.durationMs)])
        + (r.message ? "\n\n" + r.message : "");
      var box = r.status === "completed" ? MessageBox.success : r.status === "cancelled" ? MessageBox.warning : MessageBox.error;
      box(text, { title: this.text("runTitle") });
    },

    /** Lock / unlock the selected / pressed space. */
    onLockUnlock: function (event) {
      var context = this.targetContext(event);
      if (!context) {
        return;
      }
      if (context.getProperty("status") === "locked") {
        this.invokeAction("UnlockSpace", { id: context.getProperty("id") }).then(function (r) {
          this.toast("spaceUnlocked", [r.name]);
        }.bind(this), this.showError.bind(this));
        return;
      }
      this.openDialog("lock", { id: context.getProperty("id"), name: context.getProperty("name") });
    },

    /** Row access check of the selected / pressed view (data access controls). */
    onCheckAccess: function (event) {
      var context = this.targetContext(event);
      if (!context) {
        return;
      }
      this.openDialog("accessCheck", { viewId: context.getProperty("id"), viewName: context.getProperty("businessName"),
        user: this.getModel("session").getProperty("/user") || "" });
    },

    onRunCheck: function () {
      this.getModel("view").setProperty("/form/accessCheck/result", null);
      this.onSave();
    },

    /** Run the due schedules now. */
    onRunDue: function () {
      this.invokeAction("RunDueSchedules", {}).then(function (r) {
        MessageBox.information(r.summary + (r.messages ? "\n\n" + r.messages : ""), { title: this.text("runDue") });
      }.bind(this), this.showError.bind(this));
    },

    /** Show the SQL of a view / the definition of an object. */
    onShowDefinition: function (event) {
      var context = this.targetContext(event);
      if (!context) {
        return;
      }
      var o = context.getObject();
      var parts = [];
      if (o.sqlExpression) {
        parts.push(o.sqlExpression);
      }
      if (o.transforms && o.transforms.length) {
        parts.push(this.text("colTransforms") + ":\n  " + o.transforms.join("\n  "));
      }
      if (o.columns && o.columns.length) {
        parts.push(this.text("colColumns") + ":\n  " + o.columns.join("\n  "));
      }
      MessageBox.information(parts.join("\n\n") || this.text("noDefinition"),
        { title: o.businessName || o.name, contentWidth: "40rem" });
    },

    onSpacePress: function (event) {
      var context = event.getSource().getBindingContext();
      var own = context.getPath().indexOf("/Spaces(") === 0;
      var id = context.getProperty(own ? "id" : "spaceId");
      if (id) {
        this.getRouter().navTo("space", { id: id });
      }
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
