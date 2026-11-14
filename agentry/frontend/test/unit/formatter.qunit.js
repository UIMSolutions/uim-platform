/* global QUnit */
sap.ui.define([
  "uim/agentry/model/formatter",
  "sap/ui/core/library"
], function (formatter, coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  QUnit.module("formatter");

  QUnit.test("statusState", function (assert) {
    assert.strictEqual(formatter.statusState("published"), ValueState.Success);
    assert.strictEqual(formatter.statusState("inProgress"), ValueState.Warning);
    assert.strictEqual(formatter.statusState("rolledBack"), ValueState.Error);
    assert.strictEqual(formatter.statusState("x"), ValueState.None);
  });

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("inProgress"), "In Progress");
    assert.strictEqual(formatter.enumText("rolledBack"), "Rolled Back");
    assert.strictEqual(formatter.enumText(null), "");
  });

  QUnit.test("bytes / sum / bytesSum (Edm.Int64 as string)", function (assert) {
    assert.strictEqual(formatter.bytes("512"), "512 B");
    assert.strictEqual(formatter.bytes(1536), "1.5 KiB");
    assert.strictEqual(formatter.sum("2", 3), 5);
    assert.strictEqual(formatter.bytesSum("1048576", "1048576"), "2.0 MiB");
    assert.strictEqual(formatter.bytes("2,048"), "2.0 KiB");
    assert.strictEqual(formatter.platformText("ios"), "iOS");
  });

  QUnit.test("deployment helpers", function (assert) {
    assert.strictEqual(formatter.deploymentPercent(3, 1, 8), 50);
    assert.strictEqual(formatter.deploymentPercent(0, 0, 0), 0);
    assert.strictEqual(formatter.deploymentTarget("group", "d1", "north"), "north");
    assert.strictEqual(formatter.deploymentTarget("device", "d1", "north"), "d1");
    assert.strictEqual(formatter.deploymentTarget("tenant", "", ""), "—");
  });
});
