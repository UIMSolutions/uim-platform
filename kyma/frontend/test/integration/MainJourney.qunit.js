/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.kyma.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend)");

  opaTest("shows the environments tab and switches to functions", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.kyma" }, hash: "environments" });

    Then.waitFor({
      id: "environmentTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "environment table is bound");
      }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      viewName: "Main",
      matchers: function (oFilter) { return oFilter.getKey() === "functions"; },
      actions: new Press()
    });

    Then.waitFor({
      id: "functionTable",
      viewName: "Main",
      success: function () {
        Opa5.assert.ok(true, "functions tab opened");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
