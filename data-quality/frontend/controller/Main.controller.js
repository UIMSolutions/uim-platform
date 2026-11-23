sap.ui.define([
  "uim/dataquality/controller/BaseController",
  "uim/dataquality/model/models",
  "uim/dataquality/model/dialogs"
], function (BaseController, models, DIALOGS) {
  "use strict";

  /** Tables filtered by the selected dataset (tenant wide sets are not). */
  var DATASET_TABLES = ["violationsTable", "jobsTable", "groupsTable"];

  return BaseController.extend("uim.dataquality.controller.Main", {
    dialogs: function () {
      return DIALOGS;
    },

    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(function (event) {
        var tab = (event.getParameter("arguments") || {}).tab;
        if (tab) {
          this.getModel("view").setProperty("/tab", tab);
        }
      }, this);
    },

    onAfterRendering: function () {
      // the Users table is only resumed for administrators (others get 403)
      if (this.getModel("session").getProperty("/isAdmin") && this.getModel("session").getProperty("/loginRequired")) {
        var binding = this.byId("usersTable").getBinding("items");
        if (binding && binding.isSuspended()) {
          binding.resume();
        }
      }
    },

    onTabSelect: function (event) {
      this.getRouter().navTo("main", { tab: event.getParameter("key") }, true);
    },

    /** Prefill dialogs with the selected dataset. */
    dialogPrefill: function () {
      var dataset = this.getModel("view").getProperty("/dataset");
      return dataset ? { datasetId: dataset } : {};
    },

    /** Filter the dataset scoped tables ("" = all datasets). */
    onDatasetFilter: function () {
      var dataset = this.byId("datasetFilter").getSelectedKey();
      this.getModel("view").setProperty("/dataset", dataset);
      DATASET_TABLES.forEach(function (id) {
        var values = { datasetId: dataset };
        if (id === "violationsTable") {
          values.severity = this.getModel("view").getProperty("/severity");
        }
        this.filterTable(id, values);
      }, this);
    },

    onSeverityFilter: function (event) {
      this.getModel("view").setProperty("/severity", event.getParameter("item").getKey());
      this.onDatasetFilter();
    },

    /** $search on the table named in the SearchField's customData. */
    onSearch: function (event) {
      var table = this.byId(event.getSource().data("table"));
      var query = event.getParameter("query");
      table.getBinding("items").changeParameters({ $search: query ? query : undefined });
    },

    onDatasetPress: function (event) {
      this.getRouter().navTo("dataset", { id: event.getSource().getBindingContext().getProperty("id") });
    },

    onViolationPress: function (event) {
      this.getRouter().navTo("dataset", { id: event.getSource().getBindingContext().getProperty("datasetId") });
    },

    // ── datasets ──────────────────────────────────────────────────────────
    /** Validate / profile / score the selected dataset (customData: action). */
    onDatasetAction: function (event) {
      var context = this.selected("datasetsTable");
      if (context) {
        this.runDatasetAction(event.getSource().data("action"), context.getProperty("id"));
      }
    },

    onDetect: function () {
      var context = this.selected("datasetsTable");
      if (context) {
        this.openDialog("detect", { datasetId: context.getProperty("id") });
      }
    },

    onImport: function () {
      var context = this.byId("datasetsTable").getSelectedItem();
      this.openDialog("importCsv", context ? { datasetId: context.getBindingContext().getProperty("id"), createDataset: false } : {});
    },

    onEditDataset: function () {
      var context = this.selected("datasetsTable");
      if (context) {
        var d = context.getObject();
        this.openDialog("dataset", { id: d.id, name: d.name, category: d.category, description: d.description, edit: true });
      }
    },

    // ── rules ─────────────────────────────────────────────────────────────
    /** Edit the selected rule in its dialog (customData: table, dialog). */
    onEditRule: function (event) {
      var source = event.getSource();
      var context = this.selected(source.data("table"));
      if (!context) {
        return;
      }
      var rule = Object.assign({}, context.getObject());
      if (rule.allowedValues) {
        rule.allowedValues = rule.allowedValues.join("\n");
      }
      var dialog = source.data("dialog");
      var form = models.emptyForms()[dialog];
      Object.keys(form).forEach(function (name) {
        if (rule[name] !== undefined && rule[name] !== null) {
          form[name] = rule[name];
        }
      });
      form.id = rule.id;
      this.openDialog(dialog, form);
    },

    // ── cleansing jobs ────────────────────────────────────────────────────
    onRunJob: function (event) {
      var context = this.selected("jobsTable");
      if (!context) {
        return;
      }
      var action = event.getSource().data("action");
      this.invokeAction(action, { key: context.getProperty("key") }).then(function (r) {
        this.toast(action === "RunCleansingJob" ? "jobRun" : "jobCancelled", [r.id, this.formatter.enumText(r.status),
          r.changedRecords, r.changedFields]);
      }.bind(this), this.showError.bind(this));
    },

    // ── duplicates ────────────────────────────────────────────────────────
    onResolve: function () {
      var context = this.selected("groupsTable");
      if (!context) {
        return;
      }
      var group = context.getObject();
      if (group.resolved) {
        this.toast("alreadyResolved");
        return;
      }
      this.openDialog("resolve", {
        key: group.key,
        survivorRecordId: group.survivorRecordId,
        candidates: (group.candidates || []).map(models.candidate)
      });
    },

    // ── users ─────────────────────────────────────────────────────────────
    onEditUser: function () {
      var context = this.selected("usersTable");
      if (context) {
        var u = context.getObject();
        this.openDialog("user", { id: u.id, displayName: u.displayName, scopes: (u.scopes || []).join("\n"), password: "", edit: true });
      }
    },

    onLockUser: function (event) {
      var context = this.selected("usersTable");
      if (!context) {
        return;
      }
      var locked = event.getSource().data("locked") === "true";
      context.setProperty("locked", locked).then(function () {
        this.toast(locked ? "userLocked" : "userUnlocked", [context.getProperty("id")]);
      }.bind(this), this.showError.bind(this));
    },

    // ── demo ──────────────────────────────────────────────────────────────
    onSeed: function () {
      this.invokeAction("SeedDemoData", {}).then(function (r) {
        this.toast("seeded", [r.datasets, r.records, r.violations]);
      }.bind(this), this.showError.bind(this));
    }
  });
});
