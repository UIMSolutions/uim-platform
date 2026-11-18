/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press",
  "sap/ui/test/actions/EnterText",
  "sap/ui/test/matchers/PropertyStrictEquals"
], function (opaTest, Opa5, Press, EnterText, PropertyStrictEquals) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.objectstore.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend)");

  opaTest("shows the buckets and opens the create bucket dialog", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.objectstore" }, hash: "buckets" });

    Then.waitFor({
      id: "bucketTable",
      viewName: "Main",
      success: function (oTable) {
        Opa5.assert.ok(oTable.getBinding("items"), "the bucket table is bound to /Buckets");
      }
    });

    When.waitFor({
      id: "createBucketButton",
      viewName: "Main",
      actions: new Press()
    });

    Then.waitFor({
      id: "createDialog",
      viewName: "Main",
      matchers: new PropertyStrictEquals({ name: "title", value: "New Bucket" }),
      success: function () {
        Opa5.assert.ok(true, "the create dialog is open");
      }
    });

    Then.iTeardownMyUIComponent();
  });

  opaTest("evaluates access policies in the tools tab", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.objectstore" }, hash: "tools" });

    When.waitFor({
      id: "evaluateButton",
      viewName: "Main",
      actions: new Press()
    });

    Then.waitFor({
      id: "tabs",
      viewName: "Main",
      matchers: new PropertyStrictEquals({ name: "selectedKey", value: "tools" }),
      success: function () {
        Opa5.assert.ok(true, "the tools tab is shown");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
