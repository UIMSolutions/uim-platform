/* global QUnit */
sap.ui.define(["uim/autoscaler/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("states and icons", function (assert) {
    assert.strictEqual(formatter.statusState("succeeded"), "Success");
    assert.strictEqual(formatter.statusState("failed"), "Error");
    assert.strictEqual(formatter.directionIcon("scaleOut"), "sap-icon://trend-up");
    assert.strictEqual(formatter.bindingState("suspended", true), "Warning");
    assert.strictEqual(formatter.bindingState("active", true), "Success");
    assert.strictEqual(formatter.bindingState("active", false), "None");
    assert.strictEqual(formatter.utilizationState(95), "Error");
    assert.strictEqual(formatter.utilizationState(10), "Success");
  });

  QUnit.test("texts", function (assert) {
    assert.strictEqual(formatter.limits(2, 10), "2 … 10");
    assert.strictEqual(formatter.limits("0", "0"), "–");
    assert.strictEqual(formatter.instanceChange(3, 5), "3 → 5");
    assert.strictEqual(formatter.delta(2), "+2");
    assert.strictEqual(formatter.delta(-1), "-1");
    assert.strictEqual(formatter.seconds(120), "2 min");
    assert.strictEqual(formatter.seconds(90), "90 s");
    assert.strictEqual(formatter.threshold(">=", 80, "%"), ">= 80 %");
    assert.strictEqual(formatter.number("12.345"), "12.35");
    assert.strictEqual(formatter.scheduleWindow("recurring", "Mon–Fri", "08:00", "18:00"), "Mon–Fri 08:00–18:00");
    assert.strictEqual(formatter.scheduleWindow("specificDate", "", "", "", "2026-12-24T08:00", "2026-12-26T20:00"),
      "2026-12-24 08:00 – 2026-12-26 20:00");
  });
});
