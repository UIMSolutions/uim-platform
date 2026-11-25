/* global QUnit */
sap.ui.define(["uim/integrationautomation/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("inProgress"), "In Progress");
    assert.strictEqual(formatter.enumText("sapS4HanaCloud"), "SAP S/4HANA Cloud");
    assert.strictEqual(formatter.enumText("sapSuccessFactors"), "SAP SuccessFactors");
    assert.strictEqual(formatter.enumText("restApi"), "REST API");
    assert.strictEqual(formatter.enumText("sapAriba"), "SAP Ariba");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("states", function (assert) {
    assert.strictEqual(formatter.workflowState("failed"), "Error");
    assert.strictEqual(formatter.taskState("completed"), "Success");
    assert.strictEqual(formatter.connectionState("error"), "Error");
    assert.strictEqual(formatter.priorityState("critical"), "Error");
    assert.strictEqual(formatter.progressState("completed"), "Success");
    assert.strictEqual(formatter.outcomeState("unknown"), "None");
    assert.strictEqual(formatter.typeIcon("approval"), "sap-icon://approvals");
  });

  QUnit.test("durations and routes", function (assert) {
    assert.strictEqual(formatter.duration(42), "42 s");
    assert.strictEqual(formatter.duration(3900), "1 h 5 min");
    assert.strictEqual(formatter.duration(0), "");
    assert.strictEqual(formatter.minutes(90), "1 h 30 min");
    assert.strictEqual(formatter.route("SF", "S/4"), "SF → S/4");
    assert.strictEqual(formatter.route("", ""), "");
  });
});
