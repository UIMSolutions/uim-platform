sap.ui.define([
  "uim/autoscaler/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (BaseController, Filter, FilterOperator) {
  "use strict";

  return BaseController.extend("uim.autoscaler.controller.Main", {
    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(function (event) {
        var tab = (event.getParameter("arguments") || {}).tab;
        if (tab) {
          this.getModel("view").setProperty("/tab", tab);
        }
        if (!this._filtered) { // the models are known now: apply the filters and resume the tables
          this._filtered = true;
          this.onBindingFilter();
          this.onEventFilter();
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

    // ── bindings ──────────────────────────────────────────────────────────
    /** "" all · autoscaled · suspended · unbound (no policy) */
    bindingFilters: function (key) {
      switch (key) {
      case "autoscaled":
        return [new Filter("autoscaled", FilterOperator.EQ, true)];
      case "suspended":
        return [new Filter("status", FilterOperator.EQ, "suspended")];
      case "unbound":
        return [new Filter("policyId", FilterOperator.EQ, null)];
      default:
        return [];
      }
    },

    onBindingFilter: function () {
      this.applyFilters("bindingsTable", this.bindingFilters(this.getModel("view").getProperty("/bindingFilter")));
    },

    // ── history ───────────────────────────────────────────────────────────
    /** "" all · scaleOut · scaleIn (succeeded) · failed */
    eventFilters: function (key) {
      if (key === "failed") {
        return [new Filter("status", FilterOperator.EQ, "failed")];
      }
      return key ? [new Filter("direction", FilterOperator.EQ, key), new Filter("status", FilterOperator.EQ, "succeeded")] : [];
    },

    onEventFilter: function () {
      this.applyFilters("eventsTable", this.eventFilters(this.getModel("view").getProperty("/eventFilter")));
    },

    applyFilters: function (tableId, filters) {
      var binding = this.byId(tableId).getBinding("items");
      binding.filter(filters);
      if (binding.isSuspended()) {
        binding.resume();
      }
    },

    onPurge: function () {
      this.confirm("confirmPurge").then(function () {
        this.invokeAction("PurgeMetrics", {}).then(function (r) {
          this.toast("purged", [r.samples, r.events]);
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
        this.toast("seeded", [r.policies, r.bindings, r.samples]);
      }.bind(this), this.showError.bind(this));
    }
  });
});
