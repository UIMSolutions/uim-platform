sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/routing/History",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "sap/ui/core/Fragment",
  "uim/integrationautomation/model/formatter",
  "uim/integrationautomation/model/models",
  "uim/integrationautomation/model/session",
  "uim/integrationautomation/model/dialogs"
], function (Controller, UIComponent, History, Filter, FilterOperator, MessageBox, MessageToast, Fragment, formatter, models,
  session, DIALOGS) {
  "use strict";

  return Controller.extend("uim.integrationautomation.controller.BaseController", {
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
        this._userMenu = Fragment.load({ id: this.getView().getId(), name: "uim.integrationautomation.fragment.UserMenu", controller: this })
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
        this._passwordDialog = Fragment.load({ id: this.getView().getId(), name: "uim.integrationautomation.fragment.PasswordDialog",
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

    /** Run an action on the selected row (customData: table, action, toast); the row id is the parameter "id". */
    onRowAction: function (event) {
      var source = event.getSource();
      var context = this.selected(source.data("table"));
      if (!context) {
        return;
      }
      var toastKey = source.data("toast") || "done";
      this.invokeAction(source.data("action"), { id: context.getProperty("id") }).then(function (r) {
        this.toast(toastKey, [r.name || r.id, this.formatter.enumText(r.status), r.lastTestMessage || r.result || ""]);
      }.bind(this), this.showError.bind(this));
    },

    /** EQ filters from {property: value}; empty values are skipped. */
    eqFilters: function (values) {
      return Object.keys(values).filter(function (name) {
        return values[name] !== "" && values[name] !== undefined && values[name] !== null;
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
          name: "uim.integrationautomation.fragment." + def.fragment,
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
      var row = context.getObject();
      var dialog = source.data("dialog");
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
     * (def.keepOpen: the result is shown in the dialog instead).
     */
    onSave: function () {
      var form = this.currentForm();
      if (!form) {
        return;
      }
      var key = this._current;
      var def = this.dialogs()[key];
      if (def.check && !def.check(form)) {
        this.toast("requiredMissing");
        return;
      }
      var finish = function (result) {
        result = result || {};
        if (def.keepOpen) {
          this.getModel("view").setProperty("/form/" + key + "/result", result);
          return;
        }
        this.onCloseDialog();
        var toastKey = typeof def.toast === "function" ? def.toast(result, form) : def.toast || "saved";
        this.toast(toastKey, def.toastArgs ? def.toastArgs(result, form) : []);
        this.refreshAll();
      }.bind(this);
      var done = function (result) {
        if (def.after) {
          def.after(result || {}, form, this).then(finish, function (error) {
            this.onCloseDialog();
            this.refreshAll();
            this.showError(error);
          }.bind(this));
          return;
        }
        finish(result);
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
      var name = context.getProperty("name") || context.getProperty("externalId") || context.getProperty("id");
      this.confirm("confirmDelete", [name]).then(function () {
        return context.delete().then(function () {
          this.toast("deleted");
          this.refreshAll();
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    // ── workflows and tasks ───────────────────────────────────────────────
    /**
     * Task / workflow operation on the selected row (customData: table,
     * action, toast and optionally param, required, title, label). With a
     * param, a dialog asks for the text (result, error message, reason).
     */
    onTaskAction: function (event) {
      var source = event.getSource();
      var context = this.selected(source.data("table"));
      if (!context) {
        return;
      }
      var param = source.data("param");
      if (!param) {
        this.onRowAction(event);
        return;
      }
      this.openDialog("taskAction", {
        id: context.getProperty("id"), action: source.data("action"), param: param,
        required: source.data("required") === "true", title: this.text(source.data("title")),
        label: this.text(source.data("label")), toast: source.data("toast") || "done",
        name: context.getProperty("name")
      });
    },

    /** Assign the selected task (customData: table). */
    onAssign: function (event) {
      var context = this.selected(event.getSource().data("table"));
      if (context) {
        var task = context.getObject();
        this.openDialog("assign", { id: task.id, name: task.name, assignedTo: task.assignedTo || "", priority: task.priority });
      }
    },

    /** Run the ready automated and notification tasks (of one workflow if the view has one). */
    onRunAutomation: function () {
      this.invokeAction("RunAutomatedTasks", this.workflowId ? { workflowId: this.workflowId } : {}).then(function (r) {
        this.toast("automationRan", [r.executed, r.succeeded, r.failed, r.notified]);
      }.bind(this), this.showError.bind(this));
    },

    /** Open the workflow of a row (a workflow, or a task: its workflow). */
    onWorkflowPress: function (event) {
      var context = event.getSource().getBindingContext();
      var own = context.getPath().indexOf("/Workflows(") === 0;
      this.getRouter().navTo("workflow", { id: context.getProperty(own ? "id" : "workflowId") });
    },

    /** Open the scenario of a row (a scenario, or a workflow: its scenario). */
    onScenarioPress: function (event) {
      var context = event.getSource().getBindingContext();
      var own = context.getPath().indexOf("/Scenarios(") === 0;
      this.getRouter().navTo("scenario", { id: context.getProperty(own ? "id" : "scenarioId") });
    },

    /** Filter the execution log by outcome (and by the workflow of a detail view). */
    onOutcomeFilter: function () {
      var values = { outcome: this.getModel("view").getProperty("/outcome") };
      if (this.workflowId) {
        values.workflowId = this.workflowId;
      }
      this.filterTable("logTable", values);
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
