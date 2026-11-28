sap.ui.define([
  "uim/ailaunchpad/controller/BaseController"
], function (BaseController) {
  "use strict";

  var REFRESH_MS = 15000;

  /**
   * The ML life cycle: scenarios, configurations, executions, deployments,
   * models and datasets. While the page is shown, executions, deployments
   * and the header refresh every 15 s (the reconcile worker moves them on).
   */
  return BaseController.extend("uim.ailaunchpad.controller.Lifecycle", {
    onInit: function () {
      this.attachPage("lifecycle", "lifecycleTitle", "scenarios", function () {
        this.startAutoRefresh();
      });
    },

    startAutoRefresh: function () {
      if (this._timer) {
        return;
      }
      this._timer = window.setInterval(function () {
        var view = this.getModel("view");
        var tab = view.getProperty("/tab");
        if (view.getProperty("/page") !== "lifecycle" || document.hidden || view.getProperty("/busy")) {
          return;
        }
        if (tab === "executions" || tab === "deployments") {
          this.byId(tab + "Table").getBinding("items").refresh();
          var kpis = this.byId("page").getHeader().getContent()[0].getElementBinding();
          if (kpis) {
            kpis.refresh();
          }
        }
      }.bind(this), REFRESH_MS);
    },

    onExit: function () {
      window.clearInterval(this._timer);
    },

    onExecutionFilter: function () {
      var status = this.getModel("view").getProperty("/executionFilter");
      this.applyFilters("executionsTable", this.eqFilters({ status: status }));
    },

    /** Start an execution of the selected configuration. */
    onStartExecution: function () {
      var context = this.selected("configurationsTable");
      if (context) {
        this.openDialog("execution", { configurationId: context.getProperty("id") });
      }
    },

    /** Deploy the selected configuration. */
    onDeploy: function () {
      var context = this.selected("configurationsTable");
      if (context) {
        this.openDialog("deployment", { configurationId: context.getProperty("id") });
      }
    }
  });
});
