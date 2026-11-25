sap.ui.define([
  "uim/integrationautomation/controller/BaseController",
  "uim/integrationautomation/model/models"
], function (BaseController, models) {
  "use strict";

  return BaseController.extend("uim.integrationautomation.controller.ScenarioDetail", {
    onInit: function () {
      this.getRouter().getRoute("scenario").attachPatternMatched(this.onMatched, this);
    },

    /** Bind the header to the scenario, filter its templates and workflows. */
    onMatched: function (event) {
      this.scenarioId = event.getParameter("arguments").id;
      this.getView().bindElement({
        path: models.entityPath("Scenarios", this.scenarioId),
        parameters: { $select: "id,name,description,category,version,sourceSystemType,targetSystemType,prerequisites,status" }
      });
      this.filterTable("templatesTable", { scenarioId: this.scenarioId });
      this.filterTable("scenarioWorkflowsTable", { scenarioId: this.scenarioId });
    },

    scenario: function () {
      return this.getView().getBindingContext().getObject() || {};
    },

    onScenarioAction: function (event) {
      this.invokeAction(event.getSource().data("action"), { id: this.scenarioId }).then(function (r) {
        this.toast("scenarioChanged", [r.name, this.formatter.enumText(r.status)]);
      }.bind(this), this.showError.bind(this));
    },

    onCopy: function () {
      this.openDialog("taskAction", {
        id: this.scenarioId, action: "CopyScenario", param: "newId", required: false, title: this.text("copyScenario"),
        label: this.text("newId"), toast: "scenarioCopied", name: this.scenario().name
      });
    },

    onEditScenario: function () {
      var s = this.scenario();
      this.openDialog("scenario", {
        id: s.id, name: s.name, description: s.description, category: s.category, version: s.version,
        sourceSystemType: s.sourceSystemType, targetSystemType: s.targetSystemType,
        prerequisites: (s.prerequisites || []).join("\n"), edit: true
      });
    },

    /** A new template after the last one (sequence + 10). */
    onCreateTemplate: function () {
      var last = 0;
      this.byId("templatesTable").getItems().forEach(function (item) {
        last = Math.max(last, Number(item.getBindingContext().getProperty("sequenceNumber")) || 0);
      });
      this.openDialog("scenarioTask", { scenarioId: this.scenarioId, sequenceNumber: last + 10 });
    },

    onNewWorkflow: function () {
      this.openDialog("workflow", { scenarioId: this.scenarioId, name: "" });
    }
  });
});
