sap.ui.define([
  "uim/dataretention/controller/BaseController"
], function (BaseController) {
  "use strict";

  /** Tables filtered by the selected application group. */
  var GROUP_TABLES = ["subjectsTable", "requestsTable", "jobsTable", "purposesTable"];

  return BaseController.extend("uim.dataretention.controller.Main", {
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

    /** Prefill dialogs with the selected application group. */
    dialogPrefill: function (dialog) {
      var group = this.getModel("view").getProperty("/group");
      if (!group) {
        return {};
      }
      return dialog === "check" ? { applicationGroupId: group } : dialog === "archivingJob" ? { applicationGroupId: group }
        : dialog === "businessPurpose" ? { applicationGroupId: group } : {};
    },

    /** Filter the group scoped tables ("" = all groups). */
    onFilter: function () {
      var view = this.getModel("view");
      var group = this.byId("groupFilter").getSelectedKey();
      view.setProperty("/group", group);
      GROUP_TABLES.forEach(function (id) {
        var values = { applicationGroupId: group };
        if (id === "subjectsTable") {
          values.lifecycleStatus = view.getProperty("/lifecycle");
        }
        this.filterTable(id, values);
      }, this);
    },

    onLifecycleFilter: function (event) {
      this.getModel("view").setProperty("/lifecycle", event.getParameter("item").getKey());
      this.onFilter();
    },

    onPurposePress: function (event) {
      this.getRouter().navTo("purpose", { id: event.getSource().getBindingContext().getProperty("id") });
    },

    // ── data subjects ─────────────────────────────────────────────────────
    onLegalHold: function () {
      var context = this.selected("subjectsTable");
      if (context) {
        var s = context.getObject();
        this.openDialog("legalHold", { id: s.id, legalHold: !s.legalHold, reason: s.legalHoldReason || "" });
      }
    },

    onRequestDeletion: function () {
      var context = this.selected("subjectsTable");
      this.openDialog("deletionRequest", context ? { dataSubjectId: context.getProperty("id") } : {});
    },

    // ── bulk operations ───────────────────────────────────────────────────
    onProcessPending: function () {
      this.invokeAction("ProcessPendingRequests", {}).then(function (r) {
        this.toast("processedAll", [r.started, r.completed, r.rejected, r.failed]);
      }.bind(this), this.showError.bind(this));
    },

    onRunDue: function () {
      this.invokeAction("RunDueJobs", {}).then(function (r) {
        this.toast("ranDue", [r.started, r.completed, r.failed]);
      }.bind(this), this.showError.bind(this));
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
        this.toast("seeded", [r.businessPurposes, r.dataSubjects, r.deletionRequests]);
      }.bind(this), this.showError.bind(this));
    }
  });
});
