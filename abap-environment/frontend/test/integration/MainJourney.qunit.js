/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.abap.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend)");

  opaTest("shows the systems tab and switches to transports", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.abap" }, hash: "systems" });

    Then.waitFor({
      id: "systemTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "system table is bound");
      }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      viewName: "Main",
      matchers: function (oFilter) { return oFilter.getKey() === "transports"; },
      actions: new Press()
    });

    Then.waitFor({
      id: "transportTable",
      viewName: "Main",
      success: function () {
        Opa5.assert.ok(true, "transports tab opened");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
