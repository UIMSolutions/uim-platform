/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with demo data (authMode "open"):
 *   ./build/uim-data-quality-cli seed --data-file=data/data-quality.json
 *   DQ_AUTH_MODE=open ./build/uim-data-quality-platform-service
 *   → http://localhost:8086/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  var VIEW = "Main";
  Opa5.extendConfig({ viewNamespace: "uim.dataquality.view.", autoWait: true, timeout: 30 });

  QUnit.module("Data Quality");

  opaTest("lists datasets and the KPI header", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.dataquality", async: true } });
    Then.waitFor({
      viewName: VIEW, id: "datasetsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function (table) { Opa5.assert.ok(table.getItems().length >= 1, "datasets are listed"); }
    });
    Then.waitFor({
      viewName: VIEW, id: "kpis",
      success: function (box) { Opa5.assert.ok(box.getBindingContext(), "Statistics bound"); }
    });
  });

  opaTest("shows the violations", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("violations"); bar.fireSelect({ key: "violations" }); }
    });
    Then.waitFor({
      viewName: VIEW, id: "violationsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "violations are listed"); }
    });
  });

  opaTest("opens a dataset with its scorecard", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("datasets"); bar.fireSelect({ key: "datasets" }); }
    });
    When.waitFor({
      viewName: VIEW, controlType: "sap.m.ColumnListItem",
      matchers: function (item) { return item.getParent() && item.getParent().getId().endsWith("datasetsTable"); },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "DatasetDetail", id: "recordsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "records of the dataset are shown"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
