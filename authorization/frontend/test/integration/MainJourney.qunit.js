/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.authorization.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend with demo data)");

  opaTest("lists the policies and evaluates an authorization request", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.authorization" }, hash: "policies" });

    Then.waitFor({
      id: "policyTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "policy table is bound");
      }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      viewName: "Main",
      matchers: function (oFilter) { return oFilter.getKey() === "check"; },
      actions: new Press()
    });

    When.waitFor({ id: "checkButton", viewName: "Main", actions: new Press() });

    Then.waitFor({
      id: "checkOutcome",
      viewName: "Main",
      matchers: function (oStatus) { return oStatus.getText() !== ""; },
      success: function (oStatus) {
        Opa5.assert.strictEqual(oStatus.getText(), "Permit", "alice may read US incidents (demo data)");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
