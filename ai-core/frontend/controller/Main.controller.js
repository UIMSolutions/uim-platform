sap.ui.define([
  "uim/aicore/controller/BaseController",
  "uim/aicore/model/models",
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

  /** Text areas → collections of "key=value" strings. */
  function withLines(form, names) {
    var result = Object.assign({}, form);
    names.forEach(function (name) {
      result[name] = models.lines(form[name]);
    });
    return compact(result);
  }

  /** Tables filtered by the selected resource group (tenant wide sets are not). */
  var GROUP_TABLES = ["executionsTable", "deploymentsTable", "scenariosTable", "executablesTable",
    "configurationsTable", "artifactsTable", "schedulesTable", "storeSecretsTable"];

  /** dialog key → fragment, entity set, required form fields, payload builder */
  var DIALOGS = {
    group: { fragment: "ResourceGroupDialog", set: "ResourceGroups", required: ["id"],
      payload: function (f) { return withLines(f, ["labels"]); } },
    scenario: { fragment: "ScenarioDialog", set: "Scenarios", required: ["resourceGroupId", "id", "name"],
      payload: function (f) { return withLines(f, ["labels"]); } },
    executable: { fragment: "ExecutableDialog", set: "Executables", required: ["resourceGroupId", "scenarioId", "id", "name"],
      payload: function (f) { return withLines(f, ["parameters", "inputArtifacts", "outputArtifacts", "labels"]); } },
    configuration: { fragment: "ConfigurationDialog", set: "Configurations",
      required: ["resourceGroupId", "name", "scenarioId", "executableId"],
      payload: function (f) { return withLines(f, ["parameterBindings", "inputArtifactBindings"]); } },
    execution: { fragment: "ExecutionDialog", set: "Executions", required: ["resourceGroupId", "configurationId"],
      payload: function (f) { return withLines(f, ["tags"]); } },
    deployment: { fragment: "DeploymentDialog", set: "Deployments", required: ["resourceGroupId", "configurationId"],
      payload: function (f) {
        return compact({ resourceGroupId: f.resourceGroupId, configurationId: f.configurationId, ttlSeconds: Number(f.ttlSeconds) || 0 });
      } },
    artifact: { fragment: "ArtifactDialog", set: "Artifacts", required: ["resourceGroupId", "scenarioId", "name", "url"],
      payload: function (f) { return withLines(f, ["labels"]); } },
    schedule: { fragment: "ScheduleDialog", set: "ExecutionSchedules", required: ["resourceGroupId", "configurationId", "cron"],
      payload: compact },
    dockerSecret: { fragment: "DockerSecretDialog", set: "DockerRegistrySecrets", required: ["id", "server", "username", "password"],
      payload: compact },
    storeSecret: { fragment: "ObjectStoreSecretDialog", set: "ObjectStoreSecrets", required: ["resourceGroupId", "id", "bucket"],
      payload: compact }
  };

  return BaseController.extend("uim.aicore.controller.Main", {
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

    /** Filter every group scoped table by the selected resource group ("" = all). */
    onGroupChange: function () {
      var group = this.byId("groupSelect").getSelectedKey();
      this.getModel("view").setProperty("/group", group);
      GROUP_TABLES.forEach(function (id) {
        this.filterTable(id, { resourceGroupId: group });
      }, this);
    },

    /** $search on the table named in the SearchField's customData. */
    onSearch: function (event) {
      var table = this.byId(event.getSource().data("table"));
      var query = event.getParameter("query");
      table.getBinding("items").changeParameters({ $search: query ? query : undefined });
    },

    // ── navigation ────────────────────────────────────────────────────────
    _navTo: function (route, event) {
      this.getRouter().navTo(route, { key: event.getSource().getBindingContext().getProperty("key") });
    },

    onExecutionPress: function (event) {
      this._navTo("execution", event);
    },

    onDeploymentPress: function (event) {
      this._navTo("deployment", event);
    },

    onScenarioPress: function (event) {
      this._navTo("scenario", event);
    },

    // ── selection helpers ─────────────────────────────────────────────────
    _selected: function (tableId) {
      var item = this.byId(tableId).getSelectedItem();
      if (!item) {
        this.toast("selectFirst");
        return null;
      }
      return item.getBindingContext();
    },

    _nameOf: function (context) {
      return context.getProperty("name") || context.getProperty("id") || context.getProperty("key");
    },

    // ── generic actions ───────────────────────────────────────────────────
    onDelete: function (event) {
      var context = this._selected(event.getSource().data("table"));
      if (!context) {
        return;
      }
      var name = this._nameOf(context);
      this.confirm("confirmDelete", [name]).then(function () {
        return context.delete().then(function () {
          this.toast("deleted");
          this.refreshAll();
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    onDeleteGroup: function () {
      var context = this._selected("groupsTable");
      if (!context) {
        return;
      }
      this.confirm("confirmDeleteGroup", [context.getProperty("id")]).then(function () {
        return context.delete().then(function () {
          this.toast("deleted");
          this.getModel("view").setProperty("/group", "");
          this.refreshAll();
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    /** Stop / restart the selected run (OData action name in customData). */
    onStop: function (event) {
      var source = event.getSource();
      var context = this._selected(source.data("table"));
      if (!context) {
        return;
      }
      var action = source.data("action");
      var run = function () {
        return this.invokeAction(action, { key: context.getProperty("key") }).then(function (r) {
          this.toast(action === "ResumeDeployment" ? "restarted" : "stopped", [r.id]);
        }.bind(this), this.showError.bind(this));
      }.bind(this);
      if (action === "ResumeDeployment") {
        run();
      } else {
        this.confirm("confirmStop", [context.getProperty("id")]).then(run);
      }
    },

    onSetStatus: function (event) {
      var source = event.getSource();
      var context = this._selected(source.data("table"));
      if (!context) {
        return;
      }
      var status = source.data("status");
      context.setProperty("status", status).then(function () {
        this.toast("statusChanged", [this._nameOf(context), this.formatter.enumText(status)]);
        this.refreshAll();
      }.bind(this), this.showError.bind(this));
    },

    onTriggerSchedule: function () {
      var context = this._selected("schedulesTable");
      if (!context) {
        return;
      }
      this.invokeAction("TriggerSchedule", { key: context.getProperty("key") }).then(function (r) {
        this.toast("triggered", [r.id]);
      }.bind(this), this.showError.bind(this));
    },

    /** Start the selected configuration: workflow → execution, serving → deployment. */
    onRunConfiguration: function () {
      var context = this._selected("configurationsTable");
      if (!context) {
        return;
      }
      var prefill = { resourceGroupId: context.getProperty("resourceGroupId"), configurationId: context.getProperty("id") };
      this._openDialog(context.getProperty("executableType") === "serving" ? "deployment" : "execution", prefill);
    },

    onReconcile: function () {
      this.invokeAction("Reconcile", {}).then(function (r) {
        var changes = r.resourceGroupsProvisioned + r.executionsStarted + r.executionsCompleted + r.executionsStopped
          + r.deploymentsStarted + r.deploymentsStopped + r.deploymentsExpired + r.schedulesFired;
        this.toast("reconciled", [changes, r.artifactsCreated]);
      }.bind(this), this.showError.bind(this));
    },

    onSeed: function () {
      this.invokeAction("SeedDemoData", {}).then(function (r) {
        this.toast("seeded", [r.scenarios, r.executions, r.deployments]);
      }.bind(this), this.showError.bind(this));
    },

    // ── dialogs ───────────────────────────────────────────────────────────
    _openDialog: function (key, prefill) {
      this._current = key;
      var defaults = models.emptyForms()[key];
      if ("resourceGroupId" in defaults) {
        defaults.resourceGroupId = this.getModel("view").getProperty("/group") || "default";
      }
      this.getModel("view").setProperty("/form/" + key, Object.assign(defaults, prefill || {}));
      if (!this._dialogs[key]) {
        this._dialogs[key] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.aicore.fragment." + DIALOGS[key].fragment,
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
     * POST through a separate, unrendered list binding (a transient row in
     * the table would turn its collection bindings into a deep create).
     */
    onSave: function () {
      var form = this._form();
      if (!form) {
        return;
      }
      var key = this._current;
      var def = DIALOGS[key];
      var payload = def.payload(form);
      var binding = this.getModel().bindList("/" + def.set);
      var context = binding.create(payload, true);
      this.setBusy(true);
      context.created().then(function () {
        var created = context.getObject() || {};
        this.onCloseDialog();
        if (key === "execution") {
          this.toast("started", [created.id]);
        } else if (key === "deployment") {
          this.toast("deployed", [created.id]);
        } else {
          this.toast("created");
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
    }
  });
});
