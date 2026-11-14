/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press",
  "sap/ui/test/matchers/PropertyStrictEquals"
], function (opaTest, Opa5, Press, PropertyStrictEquals) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.transport.view.", autoWait: true });

  QUnit.module("Main");

  opaTest("Shows the KPI header and the tabs", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.transport" } });

    Then.waitFor({
      id: "kpiHeader",
      viewName: "Main",
      success: function () { Opa5.assert.ok(true, "KPI header is displayed"); }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      matchers: new PropertyStrictEquals({ name: "key", value: "nodes" }),
      actions: new Press()
    });

    Then.waitFor({
      id: "nodeTable",
      viewName: "Main",
      success: function () { Opa5.assert.ok(true, "Node table is displayed"); }
    });

    Then.iTeardownMyUIComponent();
  });
});
