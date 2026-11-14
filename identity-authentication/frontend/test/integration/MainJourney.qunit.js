/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.ias.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend)");

  opaTest("shows the users and switches to sessions", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.ias" }, hash: "users" });

    Then.waitFor({
      id: "userTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "user table is bound");
      }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      viewName: "Main",
      matchers: function (oFilter) { return oFilter.getKey() === "sessions"; },
      actions: new Press()
    });

    Then.waitFor({
      id: "sessionTable",
      viewName: "Main",
      success: function () {
        Opa5.assert.ok(true, "sessions tab opened");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
