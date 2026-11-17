sap.ui.define([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  // Runs against a live backend serving the app (dub run in backend/).
  QUnit.module("Navigation");

  opaTest("shows the overview with KPI tiles", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.workzone", async: true } });
    Then.waitFor({
      id: "kpiHeader",
      viewName: "Overview",
      success: function () { Opa5.assert.ok(true, "KPI header is shown"); }
    });
  });

  opaTest("opens the workspace list from a tile", function (Given, When, Then) {
    When.waitFor({
      controlType: "sap.m.GenericTile",
      viewName: "Overview",
      matchers: function (oTile) { return oTile.data("set") === "Workspaces"; },
      actions: new Press()
    });
    Then.waitFor({
      id: "resourceTable",
      viewName: "Resource",
      success: function () { Opa5.assert.ok(true, "Workspace table is shown"); }
    });
    Then.iTeardownMyUIComponent();
  });
});
