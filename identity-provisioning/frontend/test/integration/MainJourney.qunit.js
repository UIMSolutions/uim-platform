/* global QUnit */
sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  Opa5.extendConfig({ viewNamespace: "uim.identityprovisioning.view.", autoWait: true });

  QUnit.module("Main journey (against a running backend with demo data)");

  opaTest("shows the jobs, runs one and opens its detail page", function (Given, When, Then) {
    var sCompletedBefore;
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.identityprovisioning" }, hash: "jobs" });

    Then.waitFor({
      id: "jobTable",
      viewName: "Main",
      check: function (oTable) { return oTable.getItems().length > 0; },
      success: function (oTable) {
        Opa5.assert.ok(true, oTable.getItems().length + " job(s) are shown");
        oTable.setSelectedItem(oTable.getItems()[0]);
        sCompletedBefore = oTable.getItems()[0].getBindingContext().getProperty("completedAt");
      }
    });

    When.waitFor({ id: "runJobButton", viewName: "Main", actions: new Press() });

    Then.waitFor({
      id: "jobTable",
      viewName: "Main",
      check: function (oTable) {
        // only displayed properties are loaded ($select) — completedAt changes with every run
        var oContext = oTable.getItems()[0].getBindingContext();
        return !!oContext && !!oContext.getProperty("completedAt") && oContext.getProperty("completedAt") !== sCompletedBefore;
      },
      success: function () {
        Opa5.assert.ok(true, "the job has been run");
      }
    });

    When.waitFor({
      controlType: "sap.m.ColumnListItem",
      viewName: "Main",
      matchers: function (oItem) { return oItem.getParent().getId().indexOf("jobTable") >= 0; },
      actions: new Press()
    });

    Then.waitFor({
      id: "jobLogTable",
      viewName: "JobDetail",
      check: function (oTable) { return oTable.getItems().length > 0; },
      success: function () {
        Opa5.assert.ok(true, "the log of the last run is shown");
      }
    });

    Then.iTeardownMyUIComponent();
  });

  opaTest("previews a transformation", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.identityprovisioning" }, hash: "transformations" });

    Then.waitFor({
      id: "transformationTable",
      viewName: "Main",
      check: function (oTable) { return oTable.getItems().length > 0; },
      success: function (oTable) {
        var oUsers = oTable.getItems().filter(function (oItem) {
          return oItem.getBindingContext().getProperty("scope") === "user";
        })[0] || oTable.getItems()[0];
        oTable.setSelectedItem(oUsers);
      }
    });

    When.waitFor({ id: "previewButton", viewName: "Main", actions: new Press() });
    When.waitFor({ id: "runPreviewButton", viewName: "Main", searchOpenDialogs: true, actions: new Press() });

    Then.waitFor({
      id: "previewResultTable",
      viewName: "Main",
      searchOpenDialogs: true,
      check: function (oTable) { return oTable.getItems().length > 0; },
      success: function () {
        Opa5.assert.ok(true, "the transformed attributes are shown");
      }
    });

    Then.iTeardownMyUIComponent();
  });
});
