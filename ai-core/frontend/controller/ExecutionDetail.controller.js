sap.ui.define([
  "uim/aicore/controller/BaseController",
  "uim/aicore/model/models"
], function (BaseController, models) {
  "use strict";

  return BaseController.extend("uim.aicore.controller.ExecutionDetail", {
    onInit: function () {
      this.getRouter().getRoute("execution").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      this._key = event.getParameter("arguments").key;
      var parts = models.splitKey(this._key);
      this.bindTo("Executions", this._key);
      this.filterTable("outputsTable", { resourceGroupId: parts.group, executionId: parts.id });
      this.filterTable("metricsTable", { resourceGroupId: parts.group, executionId: parts.id });
    },

    onStop: function () {
      var id = models.splitKey(this._key).id;
      this.confirm("confirmStop", [id]).then(function () {
        return this.invokeAction("StopExecution", { key: this._key }).then(function () {
          this.toast("stopped", [id]);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    onClearMetrics: function () {
      this.invokeAction("ClearMetrics", { key: this._key }).then(function (r) {
        this.toast("metricsCleared", [r.count]);
      }.bind(this), this.showError.bind(this));
    },

    onDelete: function () {
      var context = this.getView().getBindingContext();
      var id = models.splitKey(this._key).id;
      this.confirm("confirmDelete", [id]).then(function () {
        return context.delete().then(function () {
          this.toast("deleted");
          this.getRouter().navTo("main", { tab: "executions" }, true);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    }
  });
});
