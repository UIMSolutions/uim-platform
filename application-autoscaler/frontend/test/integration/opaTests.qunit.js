/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with demo data (authMode "open"):
 *   ./build/uim-application-autoscaler-cli seed --data-file=data/application-autoscaler.json
 *   AUTOSCALER_AUTH_MODE=open ./build/uim-application-autoscaler-platform-service
 *   → http://localhost:8097/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  var VIEW = "Main";
  Opa5.extendConfig({ viewNamespace: "uim.autoscaler.view.", autoWait: true, timeout: 30 });

  QUnit.module("Application Autoscaler");

  opaTest("lists the bindings and the KPI header", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.autoscaler", async: true } });
    Then.waitFor({
      viewName: VIEW, id: "bindingsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function (table) { Opa5.assert.ok(table.getItems().length >= 1, "bindings are listed"); }
    });
    Then.waitFor({
      viewName: VIEW, id: "kpis",
      success: function (box) { Opa5.assert.ok(box.getBindingContext(), "Statistics bound"); }
    });
  });

  opaTest("shows the policies", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("policies"); bar.fireSelect({ key: "policies" }); }
    });
    Then.waitFor({
      viewName: VIEW, id: "policiesTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "policies are listed"); }
    });
  });

  opaTest("opens a policy with its rules", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, controlType: "sap.m.ColumnListItem",
      matchers: function (item) { return item.getParent() && item.getParent().getId().endsWith("policiesTable"); },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "PolicyDetail", id: "rulesTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "the rules of the policy are shown"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
