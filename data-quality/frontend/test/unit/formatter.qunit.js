/* global QUnit */
sap.ui.define(["uim/dataquality/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("scores", function (assert) {
    assert.strictEqual(formatter.score(81.84999999999999), "81.8");
    assert.strictEqual(formatter.score(null), "–");
    assert.strictEqual(formatter.percentText(100), "100.0 %");
    assert.strictEqual(formatter.percentValue(120), 100);
    assert.strictEqual(formatter.percentValue(null), 0);
    assert.strictEqual(formatter.scoreState(85), "Success");
    assert.strictEqual(formatter.scoreState(65), "Warning");
    assert.strictEqual(formatter.scoreState(10), "Error");
    assert.strictEqual(formatter.scoreState(null), "None");
  });

  QUnit.test("states and texts", function (assert) {
    assert.strictEqual(formatter.ratingState("fair"), "Warning");
    assert.strictEqual(formatter.severityState("critical"), "Error");
    assert.strictEqual(formatter.statusState("completed"), "Success");
    assert.strictEqual(formatter.enumText("referenceData"), "Reference Data");
    assert.strictEqual(formatter.enumText("crossField"), "Cross Field");
    assert.strictEqual(formatter.list(["a", "b"]), "a, b");
    assert.strictEqual(formatter.candidates(["c1=100", "c2=93.5"]), "c1, c2 (93.5)");
    assert.strictEqual(formatter.millis(350), "350 ms");
    assert.strictEqual(formatter.millis(2400), "2.4 s");
    assert.deepEqual(formatter.keys("a\nb, c"), ["a", "b", "c"]);
  });
});
