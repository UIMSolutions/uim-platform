/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with demo data:
 *   ./build/uim-ai-core-cli seed --data-file=data/ai-core.json
 *   ./build/uim-ai-core-platform-service   → http://localhost:8090/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  var VIEW = "Main";
  Opa5.extendConfig({ viewNamespace: "uim.aicore.view.", autoWait: true, timeout: 30 });

  QUnit.module("AI Core");

  opaTest("lists executions and the KPI header", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.aicore", async: true } });
    Then.waitFor({
      viewName: VIEW, id: "executionsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function (table) { Opa5.assert.ok(table.getItems().length >= 1, "executions are listed"); }
    });
    Then.waitFor({
      viewName: VIEW, id: "kpis",
      success: function (box) { Opa5.assert.ok(box.getBindingContext(), "Statistics bound"); }
    });
  });

  opaTest("switches to deployments", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("deployments"); bar.fireSelect({ key: "deployments" }); }
    });
    Then.waitFor({
      viewName: VIEW, id: "deploymentsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "deployments are listed"); }
    });
  });

  opaTest("opens an execution", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("executions"); bar.fireSelect({ key: "executions" }); }
    });
    When.waitFor({
      viewName: VIEW, controlType: "sap.m.ColumnListItem",
      matchers: function (item) { return item.getParent() && item.getParent().getId().endsWith("executionsTable"); },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "ExecutionDetail", id: "executionForm",
      success: function () { Opa5.assert.ok(true, "execution detail is shown"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
