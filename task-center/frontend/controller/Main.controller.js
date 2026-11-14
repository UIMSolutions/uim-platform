sap.ui.define([
  "uim/taskcenter/controller/BaseController",
  "uim/taskcenter/model/models",
  "sap/ui/core/Fragment",
  "sap/m/MessageBox"
], function (BaseController, models, Fragment, MessageBox) {
  "use strict";

  function splitList(text) {
    return String(text || "").split(",").map(function (s) { return s.trim(); }).filter(Boolean);
  }

  function withoutEmpty(object) {
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
    task: {
      fragment: "CreateTaskDialog", table: "tasksTable", required: ["title"],
      payload: function (f) { return withoutEmpty(f); }
    },
    provider: {
      fragment: "CreateProviderDialog", table: "providersTable", required: ["name"],
      payload: function (f) { return withoutEmpty(f); }
    },
    definition: {
      fragment: "CreateDefinitionDialog", table: "definitionsTable", required: ["name"],
      payload: function (f) {
        var p = withoutEmpty(Object.assign({}, f, { dueInDays: Number(f.dueInDays) || 0 }));
        p.allowedActions = splitList(f.allowedActions);
        p.requiresClaim = !!f.requiresClaim;
        return p;
      }
    },
    substitution: {
      fragment: "CreateSubstitutionDialog", table: "substitutionsTable", required: ["substituteId"],
      payload: function (f) {
        var p = withoutEmpty(f);
        p.isAutoForward = !!f.isAutoForward;
        return p;
      }
    },
    filter: {
      fragment: "CreateFilterDialog", table: "filtersTable", required: ["name"],
      payload: function (f) {
        var p = withoutEmpty(f);
        p.isDefault = !!f.isDefault;
        return p;
      }
    }
  };

  return BaseController.extend("uim.taskcenter.controller.Main", {
    onInit: function () {
      this._dialogs = {};
      this.getRouter().getRoute("main").attachPatternMatched(function (event) {
        var tab = (event.getParameter("arguments") || {}).tab;
        if (tab) {
          this.getModel("view").setProperty("/tab", tab);
        }
        this._applyInboxFilter();
      }, this);
    },

    onTabSelect: function (event) {
      this.getRouter().navTo("main", { tab: event.getParameter("key") }, true);
    },

    onRefresh: function () {
      this.refreshAll();
    },

    // ── acting user / inbox scope / saved filters ─────────────────────────
    onUserChange: function (event) {
      this.getOwnerComponent().applyUser(event.getParameter("value").trim());
      this._applyInboxFilter();
      this.refreshAll(); // availableActions depend on the user
    },

    onScopeChange: function () {
      this._applyInboxFilter();
    },

    onSavedFilter: function (event) {
      var item = event.getParameter("selectedItem");
      this.getModel("view").setProperty("/filter", item ? item.getKey() : "");
      this._applyInboxFilter();
    },

    onClearFilter: function () {
      this.byId("savedFilter").setSelectedKey(null);
      this.getModel("view").setProperty("/filter", "");
      this._applyInboxFilter();
    },

    /** $filter of the inbox = scope (mine/all) AND the selected saved filter. */
    _applyInboxFilter: function () {
      var view = this.getModel("view");
      var expression = this.formatter.inboxFilter(view.getProperty("/scope"), view.getProperty("/user"), view.getProperty("/filter"));
      var binding = this.byId("tasksTable").getBinding("items");
      if (binding) {
        binding.changeParameters({ $filter: expression || undefined });
      }
    },

    /** $search on the table named in the SearchField's customData. */
    onSearch: function (event) {
      var table = this.byId(event.getSource().data("table"));
      var query = event.getParameter("query");
      table.getBinding("items").changeParameters({ $search: query ? query : undefined });
    },

    onTaskPress: function (event) {
      this.getRouter().navTo("task", { id: event.getSource().getBindingContext().getProperty("id") });
    },

    onActionPress: function (event) {
      this.getRouter().navTo("task", { id: event.getSource().getBindingContext().getProperty("taskId") });
    },

    _selected: function (tableId) {
      var item = this.byId(tableId).getSelectedItem();
      if (!item) {
        this.toast("selectFirst");
        return null;
      }
      return item.getBindingContext();
    },

    // ── generic row operations ────────────────────────────────────────────
    onDelete: function (event) {
      var context = this._selected(event.getSource().data("table"));
      if (!context) {
        return;
      }
      var name = context.getProperty("name") || context.getProperty("title") || context.getProperty("substituteId")
        || context.getProperty("id");
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

    /** PATCH one property of the selected row (activate, deactivate, make default). */
    onSetProperty: function (event) {
      var source = event.getSource();
      var context = this._selected(source.data("table"));
      if (!context) {
        return;
      }
      var value = source.data("value");
      value = value === "true" ? true : value === "false" ? false : value;
      context.setProperty(source.data("property"), value).then(function () {
        this.toast("saved");
        this.refreshAll();
      }.bind(this), this.showError.bind(this));
    },

    // ── provider sync ─────────────────────────────────────────────────────
    onSyncProvider: function () {
      var context = this._selected("providersTable");
      if (!context) {
        return;
      }
      this.invokeAction("SyncProvider", { providerId: context.getProperty("id") }).then(this._syncDone.bind(this),
        this.showError.bind(this));
    },

    onSyncAll: function () {
      this.invokeAction("SyncAllProviders", {}).then(function (result) {
        var rows = (result && result.value) || [];
        if (!rows.length) {
          this.toast("syncNothing");
        }
        rows.forEach(this._syncDone.bind(this));
      }.bind(this), this.showError.bind(this));
    },

    _syncDone: function (r) {
      if (r.error) {
        MessageBox.warning(this.text("syncFailed", [r.providerName, r.error]));
      } else {
        this.toast("syncDone", [r.providerName, r.created, r.updated, r.skipped]);
      }
    },

    // ── create dialogs ────────────────────────────────────────────────────
    _openDialog: function (key) {
      this._current = key;
      var form = models.emptyForms()[key];
      if (key === "substitution" || key === "filter") {
        form.userId = this.getModel("view").getProperty("/user");
      }
      this.getModel("view").setProperty("/form/" + key, form);
      if (!this._dialogs[key]) {
        this._dialogs[key] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.taskcenter.fragment." + DIALOGS[key].fragment,
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

    onCloseDialog: function () {
      if (this._openDialogControl) {
        this._openDialogControl.close();
      }
    },

    /** POST a new entity through the list binding of the dialog's table. */
    onSave: function () {
      var key = this._current;
      var def = DIALOGS[key];
      var form = Object.assign({}, this.getModel("view").getProperty("/form/" + key));
      if (def.required.some(function (name) { return !form[name]; })) {
        this.toast("requiredMissing");
        return;
      }
      var payload = def.payload(form);
      var context = this.byId(def.table).getBinding("items").create(payload, true);
      this.setBusy(true);
      context.created().then(function () {
        this.onCloseDialog();
        this.toast("created", [payload.name || payload.title || payload.substituteId]);
        this.refreshAll();
      }.bind(this), function (error) {
        if (!error.canceled) {
          this.showError(error);
        }
        context.delete().catch(function () { /* transient context already gone */ });
      }.bind(this)).finally(function () {
        this.setBusy(false);
      }.bind(this));
    }
  });
});
