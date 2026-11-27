/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with demo content (authMode "open"):
 *   ./build/uim-datasphere-cli seed --data-file=data/datasphere.json
 *   DATASPHERE_AUTH_MODE=open ./build/uim-datasphere-platform-service
 *   → http://localhost:8095/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  var VIEW = "Main";
  Opa5.extendConfig({ viewNamespace: "uim.datasphere.view.", autoWait: true, timeout: 30 });

  QUnit.module("Datasphere");

  opaTest("lists the spaces and the KPI header", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.datasphere", async: true } });
    Then.waitFor({
      viewName: VIEW, id: "spacesTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function (table) { Opa5.assert.ok(table.getItems().length >= 1, "spaces are listed"); }
    });
    Then.waitFor({
      viewName: VIEW, id: "kpis",
      success: function (box) { Opa5.assert.ok(box.getBindingContext(), "Statistics bound"); }
    });
  });

  opaTest("shows the run monitor", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("monitor"); bar.fireSelect({ key: "monitor" }); }
    });
    Then.waitFor({
      viewName: VIEW, id: "runsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "runs are listed"); }
    });
  });

  opaTest("opens a space with its members", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("spaces"); bar.fireSelect({ key: "spaces" }); }
    });
    When.waitFor({
      viewName: VIEW, controlType: "sap.m.ColumnListItem",
      matchers: function (item) {
        return item.getParent() && item.getParent().getId().endsWith("spacesTable")
          && item.getBindingContext().getProperty("memberCount") > 1;
      },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "SpaceDetail", id: "membersTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "the members of the space are shown"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
