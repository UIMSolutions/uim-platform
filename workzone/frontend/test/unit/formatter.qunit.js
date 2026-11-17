sap.ui.define([
  "uim/workzone/model/formatter",
  "sap/ui/core/library"
], function (formatter, coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  QUnit.module("formatter");

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("inProgress"), "In Progress");
    assert.strictEqual(formatter.enumText("sap_horizon_dark"), "Sap horizon dark");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("statusState", function (assert) {
    assert.strictEqual(formatter.statusState("published"), ValueState.Success);
    assert.strictEqual(formatter.statusState("draft"), ValueState.Warning);
    assert.strictEqual(formatter.statusState("overdue"), ValueState.Error);
    assert.strictEqual(formatter.statusState("whatever"), ValueState.None);
  });

  QUnit.test("cellText", function (assert) {
    assert.strictEqual(formatter.cellText(["a", "b"]), "a, b");
    assert.strictEqual(formatter.cellText([{ key: "filter", value: "open" }]), "filter=open");
    assert.strictEqual(formatter.cellText([{ userId: "jane", displayName: "Jane", role: "owner" }]), "Jane (owner)");
    assert.strictEqual(formatter.cellText(true), "✓");
    assert.strictEqual(formatter.cellText(null), "");
    assert.ok(formatter.cellText("2026-11-20T09:00:00Z").length > 0);
  });

  QUnit.test("count", function (assert) {
    assert.strictEqual(formatter.count([1, 2]), 2);
    assert.strictEqual(formatter.count(undefined), 0);
  });
});
