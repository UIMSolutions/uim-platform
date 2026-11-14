/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.connectivity.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend)");

  opaTest("shows the destinations tab and switches to Cloud Connectors", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.connectivity" }, hash: "destinations" });

    Then.waitFor({
      id: "destinationTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "destination table is bound");
      }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      viewName: "Main",
      matchers: function (oFilter) { return oFilter.getKey() === "connectors"; },
      actions: new Press()
    });

    Then.waitFor({
      id: "connectorTable",
      viewName: "Main",
      success: function () {
        Opa5.assert.ok(true, "Cloud Connectors tab opened");
      }
    });

    Then.waitFor({
      id: "healthCheckButton",
      viewName: "Main",
      success: function (oButton) {
        Opa5.assert.ok(oButton.getEnabled(), "health check can be started");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
