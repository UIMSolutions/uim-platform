sap.ui.define([
  "uim/appevents/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (BaseController, Filter, FilterOperator) {
  "use strict";

  return BaseController.extend("uim.appevents.controller.Main", {
    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(function (event) {
        var tab = (event.getParameter("arguments") || {}).tab;
        if (tab) {
          this.getModel("view").setProperty("/tab", tab);
        }
        if (!this._filtered) { // the models are known now: apply the filters and resume the tables
          this._filtered = true;
          this.onMessageFilter();
          this.onDeadLetterFilter();
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

    // ── messages ──────────────────────────────────────────────────────────
    /** "" all · open (pending, retrying, queued) · retrying · delivered · failed (dead letter, dropped) */
    messageFilters: function (key) {
      function any(statuses) {
        return [new Filter({ filters: statuses.map(function (s) { return new Filter("status", FilterOperator.EQ, s); }),
          and: false })];
      }
      switch (key) {
      case "open":
        return any(["pending", "retrying", "queued"]);
      case "retrying":
        return any(["retrying"]);
      case "delivered":
        return any(["delivered"]);
      case "failed":
        return any(["deadLettered", "dropped"]);
      default:
        return [];
      }
    },

    onMessageFilter: function () {
      this.applyFilters("messagesTable", this.messageFilters(this.getModel("view").getProperty("/messageFilter")));
    },

    // ── dead letters ──────────────────────────────────────────────────────
    onDeadLetterFilter: function () {
      var key = this.getModel("view").getProperty("/deadLetterFilter");
      this.applyFilters("deadLettersTable", key ? [new Filter("status", FilterOperator.EQ, key)] : []);
    },

    onPurge: function () {
      this.confirm("confirmPurge").then(function () {
        this.invokeAction("PurgeMessages", {}).then(function (r) {
          this.toast("purged", [r.messages, r.deadLetters]);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    // ── landscape ─────────────────────────────────────────────────────────
    onAssign: function () {
      var context = this.selected("formationsTable");
      if (context) {
        this.openDialog("assign", { id: context.getProperty("id"), name: context.getProperty("name") });
      }
    },

    onUnassign: function () {
      var context = this.selected("systemsTable");
      if (!context) {
        return;
      }
      this.confirm("confirmUnassign", [context.getProperty("name"), context.getProperty("formationName")]).then(function () {
        this.invokeAction("UnassignSystem", { systemId: context.getProperty("id") }).then(function (r) {
          this.toast("systemUnassigned", [r.name]);
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
        this.toast("seeded", [r.systems, r.subscriptions, r.events]);
      }.bind(this), this.showError.bind(this));
    }
  });
});
