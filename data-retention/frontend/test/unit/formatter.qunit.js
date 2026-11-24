/* global QUnit */
sap.ui.define(["uim/dataretention/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("lifecycle and phase states", function (assert) {
    assert.strictEqual(formatter.lifecycleState("blocked"), "Warning");
    assert.strictEqual(formatter.lifecycleState("markedForDeletion"), "Error");
    assert.strictEqual(formatter.phaseState("withinResidence"), "Success");
    assert.strictEqual(formatter.phaseState("endOfRetention"), "Error");
    assert.strictEqual(formatter.phaseState(null), "None");
    assert.strictEqual(formatter.statusState("rejected"), "Error");
  });

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("markedForDeletion"), "Marked For Deletion");
    assert.strictEqual(formatter.enumText("archiveAndDestruct"), "Archive And Destruct");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("days to the end of retention", function (assert) {
    assert.strictEqual(formatter.days(120), "in 120 days");
    assert.strictEqual(formatter.days(-1), "1 day ago");
    assert.strictEqual(formatter.days(0), "today");
    assert.strictEqual(formatter.days(null), "");
    assert.strictEqual(formatter.daysState(30), "Warning");
    assert.strictEqual(formatter.daysState(-5), "Error");
    assert.strictEqual(formatter.daysState(400), "None");
  });

  QUnit.test("period", function (assert) {
    assert.strictEqual(formatter.period(10, "years"), "10 years");
    assert.strictEqual(formatter.period(1, "months"), "1 month");
  });
});
