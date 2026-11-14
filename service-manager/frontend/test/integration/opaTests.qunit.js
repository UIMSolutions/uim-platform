/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require(["sap/ui/test/Opa5", "sap/ui/test/opaQunit", "sap/ui/test/matchers/AggregationFilled"],
  function (Opa5, opaTest, AggregationFilled) {
    "use strict";

    Opa5.extendConfig({ viewNamespace: "uim.servicemanager.view.", autoWait: true });

    QUnit.module("Main journey");

    opaTest("The instances table and KPI header load from the OData service", function (Given, When, Then) {
      Given.iStartMyUIComponent({ componentConfig: { name: "uim.servicemanager" } });
      Then.waitFor({
        id: "instancesTable", viewName: "Main",
        success: function () { Opa5.assert.ok(true, "instances table rendered"); }
      });
      Then.waitFor({
        id: "kpis", viewName: "Main", matchers: new AggregationFilled({ name: "items" }),
        success: function () { Opa5.assert.ok(true, "statistics header rendered"); }
      });
      Then.iTeardownMyUIComponent();
    });

    QUnit.start();
  });
