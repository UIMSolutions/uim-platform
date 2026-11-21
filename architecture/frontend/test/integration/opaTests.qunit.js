/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with the demo landscape (seedDemoData = true in config/default.json):
 *   cd backend && ./build/uim-architecture-platform-service
 *   → http://localhost:8122/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  var VIEW = "Main";
  Opa5.extendConfig({ viewNamespace: "uim.architecture.view.", autoWait: true, timeout: 30 });

  QUnit.module("Architecture repository");

  opaTest("lists building blocks and the KPI header", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.architecture", async: true } });
    Then.waitFor({
      viewName: VIEW, id: "blocksTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function (table) { Opa5.assert.ok(table.getItems().length >= 1, "building blocks are listed"); }
    });
    Then.waitFor({
      viewName: VIEW, id: "coverageKpi",
      check: function (kpi) { return kpi.getNumber() !== ""; },
      success: function (kpi) { Opa5.assert.ok(Number(kpi.getNumber()) >= 0, "coverage KPI is shown"); }
    });
  });

  opaTest("shows the gap analysis", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("analysis"); bar.fireSelect({ key: "analysis" }); }
    });
    Then.waitFor({
      viewName: VIEW, id: "gapsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "gaps are listed"); }
    });
  });

  opaTest("opens a building block and analyzes its impact", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("blocks"); bar.fireSelect({ key: "blocks" }); }
    });
    When.waitFor({
      viewName: VIEW, controlType: "sap.m.ColumnListItem",
      matchers: function (item) { return item.getParent() && item.getParent().getId().endsWith("blocksTable"); },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "BlockDetail", id: "blockForm",
      success: function () { Opa5.assert.ok(true, "detail page is shown"); }
    });
    When.waitFor({
      viewName: "BlockDetail", controlType: "sap.m.Button",
      matchers: function (b) { return b.getIcon() === "sap-icon://tree"; },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "BlockDetail", id: "impactSummary",
      check: function (strip) { return strip.getVisible(); },
      success: function () { Opa5.assert.ok(true, "impact analysis result is shown"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
