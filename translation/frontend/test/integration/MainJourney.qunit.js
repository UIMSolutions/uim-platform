/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press",
  "sap/ui/test/actions/EnterText"
], function (opaTest, Opa5, Press, EnterText) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.translation.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend)");

  opaTest("translates texts in the workbench and opens the projects tab", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.translation" }, hash: "translate" });

    When.waitFor({
      id: "translatorInput",
      viewName: "Main",
      actions: new EnterText({ text: "Save\nCancel", clearTextFirst: true })
    });

    When.waitFor({
      id: "translateButton",
      viewName: "Main",
      actions: new Press()
    });

    Then.waitFor({
      id: "translationResultTable",
      viewName: "Main",
      check: function (oTable) { return oTable.getItems().length === 2; },
      success: function () {
        Opa5.assert.ok(true, "two translations are shown");
      }
    });

    When.waitFor({
      controlType: "sap.m.IconTabFilter",
      viewName: "Main",
      matchers: function (oFilter) { return oFilter.getKey() === "projects"; },
      actions: new Press()
    });

    Then.waitFor({
      id: "projectTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "project table is bound");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
