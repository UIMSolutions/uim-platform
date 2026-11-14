/* global QUnit */
sap.ui.define(["uim/eventmesh/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("statusState maps lifecycle and message states", function (assert) {
    assert.strictEqual(formatter.statusState("active"), "Success");
    assert.strictEqual(formatter.statusState("paused"), "Warning");
    assert.strictEqual(formatter.statusState("deadLettered"), "Error");
    assert.strictEqual(formatter.statusState("queued"), "Information");
    assert.strictEqual(formatter.statusState("unknown"), "None");
  });

  QUnit.test("enumText splits camelCase", function (assert) {
    assert.strictEqual(formatter.enumText("nonExclusive"), "Non Exclusive");
    assert.strictEqual(formatter.enumText("atLeastOnce"), "At Least Once");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("bytes formats sizes (Int64 as string too)", function (assert) {
    assert.strictEqual(formatter.bytes(512), "512 B");
    assert.strictEqual(formatter.bytes(1536), "1.5 KB");
    assert.strictEqual(formatter.bytes("10485760"), "10 MB");
    assert.strictEqual(formatter.bytes(null), "–");
    assert.strictEqual(formatter.optionalBytes(0), "–");
    assert.strictEqual(formatter.optionalBytes("2048"), "2 KB");
  });

  QUnit.test("fillState warns at 80 % and errors when full", function (assert) {
    assert.strictEqual(formatter.fillState(1, 10), "Success");
    assert.strictEqual(formatter.fillState(8, 10), "Warning");
    assert.strictEqual(formatter.fillState(10, 10), "Error");
    assert.strictEqual(formatter.fillState(5, 0), "None");
  });

  QUnit.test("bindingTarget and prettyJson", function (assert) {
    assert.strictEqual(formatter.bindingTarget(null, "ch1"), "ch1");
    assert.strictEqual(formatter.bindingTarget("q1", null), "q1");
    assert.strictEqual(formatter.prettyJson("{\"a\":1}"), "{\n  \"a\": 1\n}");
    assert.strictEqual(formatter.prettyJson("not json"), "not json");
  });
});
