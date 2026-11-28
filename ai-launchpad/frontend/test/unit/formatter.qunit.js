/* global QUnit */
sap.ui.define([
  "uim/ailaunchpad/model/formatter"
], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("status → value state and icon", function (assert) {
    assert.strictEqual(formatter.state("running"), "Information");
    assert.strictEqual(formatter.state("completed"), "Success");
    assert.strictEqual(formatter.state("failed"), "Error");
    assert.strictEqual(formatter.state("warning"), "Warning");
    assert.strictEqual(formatter.state("whatever"), "None");
    assert.ok(formatter.stateIcon("dead").indexOf("sap-icon://") === 0);
  });

  QUnit.test("durations, KPIs and lists", function (assert) {
    assert.strictEqual(formatter.duration(45), "45 s");
    assert.strictEqual(formatter.duration(125), "2 min 5 s");
    assert.strictEqual(formatter.duration(3720), "1 h 2 min");
    assert.strictEqual(formatter.duration(null), "");
    assert.strictEqual(formatter.kpi(null), "");
    assert.strictEqual(formatter.kpi(0), "0");
    assert.strictEqual(formatter.kpiColor("warningsLast24h", 3), "Critical");
    assert.strictEqual(formatter.kpiColor("prompts", 3), "Neutral");
    assert.deepEqual(formatter.splitList("Viewer, Operator;Admin"), ["Viewer", "Operator", "Admin"]);
    assert.strictEqual(formatter.join(["a", "b"]), "a, b");
    assert.ok(formatter.isActive("pending") && formatter.isActive("running") && !formatter.isActive("stopped"));
  });

  QUnit.test("log details", function (assert) {
    assert.strictEqual(formatter.prettyJson("{\"a\":1}"), "{\n  \"a\": 1\n}");
    assert.strictEqual(formatter.prettyJson("not json"), "not json");
    assert.strictEqual(formatter.dateTime(""), "");
  });
});
