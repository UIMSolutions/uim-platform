/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.management.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend)");

  opaTest("shows the subaccounts and opens the service plan tab", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.management" }, hash: "subaccounts" });

    Then.waitFor({
      id: "subaccountTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "subaccount table is bound");
      }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      viewName: "Main",
      matchers: function (oFilter) { return oFilter.getKey() === "servicePlans"; },
      actions: new Press()
    });

    Then.waitFor({
      id: "servicePlanTable",
      viewName: "Main",
      success: function () {
        Opa5.assert.ok(true, "service plan tab opened");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
