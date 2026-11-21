sap.ui.define([
  "uim/aicore/controller/BaseController",
  "uim/aicore/model/models"
], function (BaseController, models) {
  "use strict";

  return BaseController.extend("uim.aicore.controller.DeploymentDetail", {
    onInit: function () {
      this.getRouter().getRoute("deployment").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      this._key = event.getParameter("arguments").key;
      this.bindTo("Deployments", this._key);
      this.getModel("view").setProperty("/nextConfiguration", "");
      // serving configurations of the same scenario
      this.getView().getElementBinding().getBoundContext().requestObject().then(function (d) {
        if (d) {
          this.filterTable("configurationSelect", { resourceGroupId: d.resourceGroupId, scenarioId: d.scenarioId, executableType: "serving" });
        }
      }.bind(this)).catch(this.showError.bind(this));
    },

    onAction: function (event) {
      var action = event.getSource().data("action");
      var id = models.splitKey(this._key).id;
      this.invokeAction(action, { key: this._key }).then(function () {
        this.toast(action === "ResumeDeployment" ? "restarted" : "stopped", [id]);
      }.bind(this), this.showError.bind(this));
    },

    onRollOut: function () {
      var next = this.getModel("view").getProperty("/nextConfiguration");
      if (!next) {
        this.toast("selectFirst");
        return;
      }
      this.getView().getBindingContext().setProperty("configurationId", next).then(function () {
        this.toast("rolledOut", [next]);
        this.refreshAll();
      }.bind(this), this.showError.bind(this));
    },

    onDelete: function () {
      var context = this.getView().getBindingContext();
      var id = models.splitKey(this._key).id;
      this.confirm("confirmDelete", [id]).then(function () {
        return context.delete().then(function () {
          this.toast("deleted");
          this.getRouter().navTo("main", { tab: "deployments" }, true);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    }
  });
});
