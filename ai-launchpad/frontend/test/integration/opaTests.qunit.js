/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with demo content (authMode "open"):
 *   ./build/uim-ai-launchpad-cli seed --data-file=data/ai-launchpad.json
 *   AILP_AUTH_MODE=open ./build/uim-ai-launchpad-platform-service
 *   → http://localhost:8097/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.ailaunchpad.view.", autoWait: true, timeout: 30 });

  QUnit.module("AI Launchpad");

  opaTest("shows the launchpad with tile groups", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.ailaunchpad", async: true } });
    Then.waitFor({
      viewName: "Launchpad", id: "groups",
      check: function (box) { return box.getItems().length > 1; },
      success: function (box) { Opa5.assert.ok(box.getItems().length >= 4, "tile groups are shown"); }
    });
  });

  opaTest("opens the executions from their tile", function (Given, When, Then) {
    When.waitFor({
      viewName: "Launchpad", controlType: "sap.m.GenericTile",
      matchers: function (tile) { return tile.getBindingContext("launchpad").getProperty("id") === "executions"; },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "Lifecycle", id: "executionsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "executions are listed"); }
    });
  });

  opaTest("runs a prompt in the playground", function (Given, When, Then) {
    When.waitFor({ viewName: "Lifecycle", id: "page", success: function () { window.location.hash = "#/genai/playground"; } });
    When.waitFor({
      viewName: "GenAI", id: "playgroundPrompt",
      success: function (combo) { combo.setSelectedKey("classify-ticket"); combo.fireSelectionChange(); }
    });
    When.waitFor({
      viewName: "GenAI", controlType: "sap.m.TextArea",
      matchers: function (area) { return area.getBindingPath("value") === "value"; },
      success: function (areas) { areas[0].setValue("My invoice is wrong"); areas[0].fireChange({ value: "My invoice is wrong" }); }
    });
    When.waitFor({ viewName: "GenAI", id: "runPromptButton", actions: new Press() });
    Then.waitFor({
      viewName: "GenAI", id: "playgroundOutput",
      check: function (area) { return area.getValue().indexOf("invoice") >= 0; },
      success: function () { Opa5.assert.ok(true, "the simulated answer is shown"); }
    });
  });

  opaTest("shows the audit log", function (Given, When, Then) {
    When.waitFor({ viewName: "GenAI", id: "page", success: function () { window.location.hash = "#/admin/logs"; } });
    Then.waitFor({
      viewName: "Admin", id: "logsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "log entries are listed"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
