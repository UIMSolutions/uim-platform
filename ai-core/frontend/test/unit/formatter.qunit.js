/* global QUnit */
sap.ui.define(["uim/aicore/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("status → value state and icon", function (assert) {
    assert.strictEqual(formatter.statusState("COMPLETED"), "Success");
    assert.strictEqual(formatter.statusState("RUNNING"), "Information");
    assert.strictEqual(formatter.statusState("DEAD"), "Error");
    assert.strictEqual(formatter.statusState("whatever"), "None");
    assert.strictEqual(formatter.statusIcon("PENDING"), "sap-icon://pending");
  });

  QUnit.test("enum texts", function (assert) {
    assert.strictEqual(formatter.enumText("RUNNING"), "Running");
    assert.strictEqual(formatter.enumText("CASCADE-UPDATE"), "Cascade Update");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("durations and time to live", function (assert) {
    assert.strictEqual(formatter.duration(45), "45 s");
    assert.strictEqual(formatter.duration(200), "3 min 20 s");
    assert.strictEqual(formatter.duration(7500), "2 h 5 min");
    assert.strictEqual(formatter.duration(0), "–");
    assert.strictEqual(formatter.ttl(0), "∞");
    assert.strictEqual(formatter.ttl(3600), "1 h");
  });

  QUnit.test("run state guards", function (assert) {
    assert.ok(formatter.canStop("RUNNING") && formatter.canStop("PENDING") && !formatter.canStop("STOPPED"));
    assert.ok(formatter.canDelete("COMPLETED") && !formatter.canDelete("STOPPING"));
    assert.ok(formatter.canRestart("STOPPED") && !formatter.canRestart("RUNNING"));
  });

  QUnit.test("lists, metrics, icons", function (assert) {
    assert.strictEqual(formatter.list(["a=1", "b=2"]), "a=1, b=2");
    assert.strictEqual(formatter.list([]), "–");
    assert.strictEqual(formatter.metric(0.123456), "0.1235");
    assert.strictEqual(formatter.kindIcon("model"), "sap-icon://machine");
    assert.strictEqual(formatter.typeIcon("serving"), "sap-icon://cloud");
  });
});
