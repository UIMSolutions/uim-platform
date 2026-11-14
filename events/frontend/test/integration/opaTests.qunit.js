/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require(["sap/ui/test/Opa5", "sap/ui/test/opaQunit", "sap/ui/test/matchers/AggregationFilled"],
  function (Opa5, opaTest, AggregationFilled) {
    "use strict";

    Opa5.extendConfig({ viewNamespace: "uim.eventmesh.view.", autoWait: true });

    QUnit.module("Main journey");

    opaTest("The queues table and KPI header load from the OData service", function (Given, When, Then) {
      Given.iStartMyUIComponent({ componentConfig: { name: "uim.eventmesh" } });
      Then.waitFor({
        id: "queuesTable", viewName: "Main",
        success: function () { Opa5.assert.ok(true, "queues table rendered"); }
      });
      Then.waitFor({
        id: "kpis", viewName: "Main", matchers: new AggregationFilled({ name: "items" }),
        success: function () { Opa5.assert.ok(true, "statistics header rendered"); }
      });
      Then.iTeardownMyUIComponent();
    });

    QUnit.start();
  });
