/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with demo data (authMode "open"):
 *   ./build/uim-application-events-cli seed --data-file=data/application-events.json
 *   APPEVENTS_AUTH_MODE=open ./build/uim-application-events-platform-service
 *   → http://localhost:8132/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  var VIEW = "Main";
  Opa5.extendConfig({ viewNamespace: "uim.appevents.view.", autoWait: true, timeout: 30 });

  QUnit.module("Application Event Hub");

  opaTest("lists the subscriptions and the KPI header", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.appevents", async: true } });
    Then.waitFor({
      viewName: VIEW, id: "subscriptionsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function (table) { Opa5.assert.ok(table.getItems().length >= 1, "subscriptions are listed"); }
    });
    Then.waitFor({
      viewName: VIEW, id: "kpis",
      success: function (box) { Opa5.assert.ok(box.getBindingContext(), "Statistics bound"); }
    });
  });

  opaTest("shows the event catalog", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("catalog"); bar.fireSelect({ key: "catalog" }); }
    });
    Then.waitFor({
      viewName: VIEW, id: "topicsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "event types are listed"); }
    });
  });

  opaTest("opens a subscription with its filters", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("subscriptions"); bar.fireSelect({ key: "subscriptions" }); }
    });
    When.waitFor({
      viewName: VIEW, controlType: "sap.m.ColumnListItem",
      matchers: function (item) {
        return item.getParent() && item.getParent().getId().endsWith("subscriptionsTable")
          && item.getBindingContext().getProperty("filterCount") > 0;
      },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "SubscriptionDetail", id: "filtersTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "the filters of the subscription are shown"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
