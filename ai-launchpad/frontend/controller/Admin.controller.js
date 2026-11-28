sap.ui.define([
  "uim/ailaunchpad/controller/BaseController",
  "sap/m/MessageBox"
], function (BaseController, MessageBox) {
  "use strict";

  var ADMIN_TABLES = ["usersTable", "rolesTable", "logsTable", "tilesTable"];

  /**
   * Administration: users, roles, the audit log and the launchpad tiles.
   * The tables are only resumed for administrators (others would get 403).
   */
  return BaseController.extend("uim.ailaunchpad.controller.Admin", {
    onInit: function () {
      this.attachPage("admin", "adminTitle", "users", function () {
        if (!this.getModel("session").getProperty("/isAdmin")) {
          return;
        }
        ADMIN_TABLES.forEach(function (id) {
          var binding = this.byId(id).getBinding("items");
          if (binding && binding.isSuspended()) {
            binding.resume();
          }
        }.bind(this));
      });
    },

    // ── users ─────────────────────────────────────────────────────────────
    onLockUser: function (event) {
      var context = this.selected("usersTable");
      if (!context) {
        return;
      }
      var locked = event.getSource().data("locked") === "true";
      context.setProperty("locked", locked).then(function () {
        this.toast(locked ? "userLocked" : "userUnlocked", [context.getProperty("id")]);
        this.refreshAll();
      }.bind(this), function (error) {
        context.getBinding().resetChanges();
        this.showError(error);
      }.bind(this));
    },

    // ── audit log ─────────────────────────────────────────────────────────
    onLogFilter: function () {
      var view = this.getModel("view");
      this.applyFilters("logsTable", this.eqFilters({
        severity: view.getProperty("/logSeverity"),
        category: view.getProperty("/logCategory")
      }));
    },

    onLogDetails: function (event) {
      var item = event.getParameter("listItem") || event.getSource().getSelectedItem();
      if (!item) {
        return;
      }
      var e = item.getBindingContext().getObject();
      var text = [
        this.text("colTime") + ": " + this.formatter.dateTime(e.createdAt),
        this.text("colUser") + ": " + e.actor,
        this.text("colEvent") + ": " + e.eventType,
        this.text("colSubject") + ": " + e.subject,
        "",
        e.message,
        "",
        this.formatter.prettyJson(e.details)
      ].join("\n");
      MessageBox.show(text, { title: this.text("logEntry"), icon: e.severity === "info" ? MessageBox.Icon.INFORMATION
        : MessageBox.Icon.WARNING, contentWidth: "36rem" });
      item.setSelected(false);
    },

    onPurgeLogs: function () {
      this.confirm("confirmPurge").then(function () {
        this.invokeAction("PurgeLogs", {}).then(function (r) {
          this.toast("purged", [r.entries]);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    // ── tiles ─────────────────────────────────────────────────────────────
    onRestoreTiles: function () {
      this.confirm("confirmRestoreTiles").then(function () {
        this.invokeAction("RestoreDefaultTiles", {}).then(function (r) {
          this.toast("tilesRestored", [r.tiles]);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    }
  });
});
