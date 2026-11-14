/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.agentry.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend)");

  opaTest("shows the applications and switches to devices", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.agentry" }, hash: "apps" });

    Then.waitFor({
      id: "appTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "application table is bound");
      }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      viewName: "Main",
      matchers: function (oFilter) { return oFilter.getKey() === "devices"; },
      actions: new Press()
    });

    Then.waitFor({
      id: "deviceTable",
      viewName: "Main",
      success: function () {
        Opa5.assert.ok(true, "devices tab opened");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
