sap.ui.define([
  "uim/integrationautomation/controller/BaseController",
  "uim/integrationautomation/model/models"
], function (BaseController, models) {
  "use strict";

  return BaseController.extend("uim.integrationautomation.controller.WorkflowDetail", {
    onInit: function () {
      this.getRouter().getRoute("workflow").attachPatternMatched(this.onMatched, this);
    },

    /** Bind the header to the workflow and filter its tasks and log. */
    onMatched: function (event) {
      this.workflowId = event.getParameter("arguments").id;
      this.getView().bindElement({
        path: models.entityPath("Workflows", this.workflowId),
        parameters: { $select: "id,scenarioId" }
      });
      this.filterTable("tasksTable", { workflowId: this.workflowId });
      this.onOutcomeFilter();
    },

    onWorkflowAction: function (event) {
      this.invokeAction(event.getSource().data("action"), { id: this.workflowId }).then(function (r) {
        this.toast("workflowChanged", [r.name, this.formatter.enumText(r.status)]);
      }.bind(this), this.showError.bind(this));
    },

    onTerminate: function () {
      this.openDialog("taskAction", {
        id: this.workflowId, action: "TerminateWorkflow", param: "reason", required: false,
        title: this.text("terminateWorkflow"), label: this.text("reason"), toast: "workflowChanged",
        name: this.getView().getBindingContext().getProperty("name")
      });
    }
  });
});
