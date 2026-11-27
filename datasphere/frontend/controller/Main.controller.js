sap.ui.define([
  "uim/datasphere/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (BaseController, Filter, FilterOperator) {
  "use strict";

  /** Tables of space-scoped sets: filtered by the space selection of the header. */
  var SPACE_TABLES = ["connectionsTable", "remoteTablesTable", "viewsTable", "dataFlowsTable", "tasksTable", "taskChainsTable",
    "accessControlsTable", "catalogTable"];

  return BaseController.extend("uim.datasphere.controller.Main", {
    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(function (event) {
        var tab = (event.getParameter("arguments") || {}).tab;
        if (tab) {
          this.getModel("view").setProperty("/tab", tab);
        }
        if (!this._filtered) { // the models are known now: apply the filters and resume the tables
          this._filtered = true;
          this.onSpaceFilter();
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

    // ── space filter ──────────────────────────────────────────────────────
    onSpaceFilter: function () {
      var space = this.getModel("view").getProperty("/space");
      SPACE_TABLES.forEach(function (id) {
        this.filterTable(id, { spaceId: space });
      }.bind(this));
      this.onRunFilter();
    },

    onAllSpaces: function () {
      this.getModel("view").setProperty("/space", "");
      this.onSpaceFilter();
    },

    /** New space-scoped objects belong to the selected space. */
    dialogPrefill: function (key) {
      var space = this.getModel("view").getProperty("/space");
      return key !== "space" && key !== "user" && space ? { spaceId: space } : {};
    },

    // ── monitor ───────────────────────────────────────────────────────────
    /** "" all · failed · completed · taskChain (chain runs only) */
    runFilters: function (key) {
      var filters = [];
      var space = this.getModel("view").getProperty("/space");
      if (space) {
        filters.push(new Filter("spaceId", FilterOperator.EQ, space));
      }
      if (key === "failed" || key === "completed") {
        filters.push(new Filter("status", FilterOperator.EQ, key));
      } else if (key === "taskChain") {
        filters.push(new Filter("objectType", FilterOperator.EQ, "taskChain"));
      }
      return filters;
    },

    onRunFilter: function () {
      this.applyFilters("runsTable", this.runFilters(this.getModel("view").getProperty("/runFilter")));
    },

    onPurge: function () {
      this.confirm("confirmPurge").then(function () {
        this.invokeAction("PurgeRuns", {}).then(function (r) {
          this.toast("purged", [r.runs]);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
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
        this.toast("seeded", [r.spaces, r.remoteTables, r.views, r.runs]);
      }.bind(this), this.showError.bind(this));
    }
  });
});
