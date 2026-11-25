/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with demo data (authMode "open"):
 *   ./build/uim-integration-automation-cli seed --data-file=data/integration-automation.json
 *   IA_AUTH_MODE=open ./build/uim-integration-automation-platform-service
 *   → http://localhost:8090/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  var VIEW = "Main";
  Opa5.extendConfig({ viewNamespace: "uim.integrationautomation.view.", autoWait: true, timeout: 30 });

  QUnit.module("Integration Automation");

  opaTest("lists workflows and the KPI header", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.integrationautomation", async: true } });
    Then.waitFor({
      viewName: VIEW, id: "workflowsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function (table) { Opa5.assert.ok(table.getItems().length >= 1, "workflows are listed"); }
    });
    Then.waitFor({
      viewName: VIEW, id: "kpis",
      success: function (box) { Opa5.assert.ok(box.getBindingContext(), "Statistics bound"); }
    });
  });

  opaTest("shows the open tasks", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("tasks"); bar.fireSelect({ key: "tasks" }); }
    });
    Then.waitFor({
      viewName: VIEW, id: "tasksTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "open tasks are listed"); }
    });
  });

  opaTest("opens a workflow with its tasks", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("workflows"); bar.fireSelect({ key: "workflows" }); }
    });
    When.waitFor({
      viewName: VIEW, controlType: "sap.m.ColumnListItem",
      matchers: function (item) { return item.getParent() && item.getParent().getId().endsWith("workflowsTable"); },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "WorkflowDetail", id: "tasksTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "the tasks of the workflow are shown"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
