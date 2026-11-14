/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.studio.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend)");

  opaTest("shows the dev spaces tab and switches to build configurations", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.studio" }, hash: "devSpaces" });

    Then.waitFor({
      id: "devSpaceTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "dev space table is bound");
      }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      viewName: "Main",
      matchers: function (oFilter) { return oFilter.getKey() === "buildConfigurations"; },
      actions: new Press()
    });

    Then.waitFor({
      id: "buildTable",
      viewName: "Main",
      success: function () {
        Opa5.assert.ok(true, "build configurations tab opened");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
