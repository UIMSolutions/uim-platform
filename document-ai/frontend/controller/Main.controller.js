sap.ui.define([
  "uim/documentai/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (BaseController, Filter, FilterOperator) {
  "use strict";

  return BaseController.extend("uim.documentai.controller.Main", {
    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(function (event) {
        var tab = (event.getParameter("arguments") || {}).tab;
        if (tab) {
          this.getModel("view").setProperty("/tab", tab);
        }
        if (!this._filtered) { // the models are known now: apply the filters and resume the tables
          this._filtered = true;
          this.onDocumentFilter();
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

    // ── documents ─────────────────────────────────────────────────────────
    /** "" all · review (needs review) · or a status */
    documentFilters: function (key) {
      if (key === "review") {
        return [new Filter("needsReview", FilterOperator.EQ, true)];
      }
      return key ? [new Filter("status", FilterOperator.EQ, key)] : [];
    },

    onDocumentFilter: function () {
      var binding = this.byId("documentsTable").getBinding("items");
      binding.filter(this.documentFilters(this.getModel("view").getProperty("/documentStatus")));
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
        this.toast("seeded", [r.schemas, r.documents, r.enrichmentRecords]);
      }.bind(this), this.showError.bind(this));
    }
  });
});
