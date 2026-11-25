sap.ui.define([
  "uim/integrationautomation/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (BaseController, Filter, FilterOperator) {
  "use strict";

  var OPEN = new Filter({ filters: [new Filter("status", FilterOperator.EQ, "pending"),
    new Filter("status", FilterOperator.EQ, "inProgress")], and: false });

  return BaseController.extend("uim.integrationautomation.controller.Main", {
    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(function (event) {
        var tab = (event.getParameter("arguments") || {}).tab;
        if (tab) {
          this.getModel("view").setProperty("/tab", tab);
        }
        if (!this._filtered) { // the models are known now: apply the filters and resume the tables
          this._filtered = true;
          this.onWorkflowFilter();
          this.onTaskFilter();
          this.onOutcomeFilter();
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

    // ── workflows ─────────────────────────────────────────────────────────
    onWorkflowFilter: function () {
      this.filterTable("workflowsTable", { status: this.getModel("view").getProperty("/workflowStatus") });
    },

    // ── tasks (inbox) ─────────────────────────────────────────────────────
    /** mine: open tasks assigned to me · ready: can start now · open · failed · all */
    taskFilters: function (key) {
      switch (key) {
      case "mine":
        return [new Filter({ filters: [new Filter("assignedTo", FilterOperator.EQ, this.getModel("session").getProperty("/user")),
          OPEN], and: true })];
      case "ready":
        return [new Filter("ready", FilterOperator.EQ, true)];
      case "open":
        return [OPEN];
      case "failed":
        return [new Filter("status", FilterOperator.EQ, "failed")];
      default:
        return [];
      }
    },

    onTaskFilter: function () {
      var binding = this.byId("tasksTable").getBinding("items");
      binding.filter(this.taskFilters(this.getModel("view").getProperty("/taskFilter")));
      if (binding.isSuspended()) {
        binding.resume();
      }
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
        this.toast("seeded", [r.systems, r.scenarios, r.workflows]);
      }.bind(this), this.showError.bind(this));
    }
  });
});
