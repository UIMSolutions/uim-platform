/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.auditlog.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend)");

  opaTest("shows the audit log tab", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.auditlog" }, hash: "logs" });

    Then.waitFor({
      id: "auditLogTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "audit log table is bound");
      }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      viewName: "Main",
      matchers: function (oFilter) { return oFilter.getKey() === "retention"; },
      actions: new Press()
    });

    Then.waitFor({
      id: "retentionTable",
      viewName: "Main",
      success: function () {
        Opa5.assert.ok(true, "retention tab opened");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
