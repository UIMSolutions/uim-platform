/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with demo data:
 *   ./build/uim-oauth-cli seed --data-file=data/oauth.json
 *   ./build/uim-oauth-platform-service        → http://localhost:8114/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press",
  "sap/ui/test/matchers/AggregationLengthEquals",
  "sap/ui/test/matchers/Properties"
], function (opaTest, Opa5, Press, AggregationLengthEquals, Properties) {
  "use strict";

  var VIEW = "Main";
  Opa5.extendConfig({ viewNamespace: "uim.oauth.view.", autoWait: true, timeout: 30 });

  QUnit.module("OAuth administration");

  opaTest("lists the clients and the KPI header", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.oauth", async: true } });
    Then.waitFor({
      viewName: VIEW, id: "clientsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function (table) { Opa5.assert.ok(table.getItems().length >= 1, "clients are listed"); }
    });
    Then.waitFor({
      viewName: VIEW, id: "kpis",
      success: function (box) { Opa5.assert.ok(box.getBindingContext(), "Statistics bound"); }
    });
  });

  opaTest("switches to the scopes tab", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("scopes"); bar.fireSelect({ key: "scopes" }); }
    });
    Then.waitFor({
      viewName: VIEW, id: "scopesTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "scopes are listed"); }
    });
  });

  opaTest("opens a client", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("clients"); bar.fireSelect({ key: "clients" }); }
    });
    When.waitFor({
      viewName: VIEW, controlType: "sap.m.ColumnListItem",
      matchers: function (item) { return item.getParent() && item.getParent().getId().endsWith("clientsTable"); },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "ClientDetail", id: "clientForm",
      success: function () { Opa5.assert.ok(true, "client detail is shown"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
