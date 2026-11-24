/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with demo data (authMode "open"):
 *   ./build/uim-data-retention-cli seed --data-file=data/data-retention.json
 *   DR_AUTH_MODE=open ./build/uim-data-retention-platform-service
 *   → http://localhost:8112/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  var VIEW = "Main";
  Opa5.extendConfig({ viewNamespace: "uim.dataretention.view.", autoWait: true, timeout: 30 });

  QUnit.module("Data Retention");

  opaTest("lists data subjects and the KPI header", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.dataretention", async: true } });
    Then.waitFor({
      viewName: VIEW, id: "subjectsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function (table) { Opa5.assert.ok(table.getItems().length >= 1, "data subjects are listed"); }
    });
    Then.waitFor({
      viewName: VIEW, id: "kpis",
      success: function (box) { Opa5.assert.ok(box.getBindingContext(), "Statistics bound"); }
    });
  });

  opaTest("shows the deletion requests", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("requests"); bar.fireSelect({ key: "requests" }); }
    });
    Then.waitFor({
      viewName: VIEW, id: "requestsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "deletion requests are listed"); }
    });
  });

  opaTest("opens a business purpose with its legal grounds", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("purposes"); bar.fireSelect({ key: "purposes" }); }
    });
    When.waitFor({
      viewName: VIEW, controlType: "sap.m.ColumnListItem",
      matchers: function (item) { return item.getParent() && item.getParent().getId().endsWith("purposesTable"); },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "BusinessPurposeDetail", id: "groundsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "legal grounds of the purpose are shown"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
