/* global QUnit */
sap.ui.define(["uim/architecture/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("lifecycle states and transitions", function (assert) {
    assert.strictEqual(formatter.statusState("active"), "Success");
    assert.strictEqual(formatter.statusState("deprecated"), "Warning");
    assert.strictEqual(formatter.statusState("unknown"), "None");
    assert.deepEqual(formatter.nextStatuses("proposed"), ["approved", "retired"]);
    assert.deepEqual(formatter.nextStatuses("retired"), []);
    assert.ok(formatter.deletable("approved"));
    assert.notOk(formatter.deletable("active"));
    assert.notOk(formatter.deletable("deprecated"));
  });

  QUnit.test("kinds, coverage and texts", function (assert) {
    assert.strictEqual(formatter.kindIcon("data"), "sap-icon://database");
    assert.strictEqual(formatter.coverageState(95), "Success");
    assert.strictEqual(formatter.coverageState("80"), "Warning");
    assert.strictEqual(formatter.coverageState(10), "Error");
    assert.strictEqual(formatter.riskState(0), "Success");
    assert.strictEqual(formatter.riskState(2, "Error"), "Error");
    assert.strictEqual(formatter.camelText("implementationAndMigration"), "Implementation And Migration");
    assert.strictEqual(formatter.joinList(["a", "b"]), "a, b");
    assert.strictEqual(formatter.relationshipText("A", "serving", "B"), "A → serving → B");
  });
});
