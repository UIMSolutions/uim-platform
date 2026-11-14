/* global QUnit */
sap.ui.define([
  "uim/authorization/model/formatter",
  "sap/ui/core/library"
], function (formatter, coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  QUnit.module("formatter");

  QUnit.test("statusState / kindState", function (assert) {
    assert.strictEqual(formatter.statusState("active"), ValueState.Success);
    assert.strictEqual(formatter.statusState("disabled"), ValueState.Warning);
    assert.strictEqual(formatter.statusState("x"), ValueState.None);
    assert.strictEqual(formatter.kindState("base"), ValueState.Information);
    assert.strictEqual(formatter.kindState("custom"), ValueState.None);
  });

  QUnit.test("allowed*", function (assert) {
    assert.strictEqual(formatter.allowedState(true), ValueState.Success);
    assert.strictEqual(formatter.allowedState(false), ValueState.Error);
    assert.strictEqual(formatter.allowedState(undefined), ValueState.None);
    assert.strictEqual(formatter.allowedText(true), "Permit");
    assert.strictEqual(formatter.allowedText(false), "Deny");
    assert.strictEqual(formatter.allowedIcon(true), "sap-icon://accept");
  });

  QUnit.test("enumText / joinList / conditionsText", function (assert) {
    assert.strictEqual(formatter.enumText("notIn"), "Not In");
    assert.strictEqual(formatter.enumText("in_"), "In");
    assert.strictEqual(formatter.enumText(null), "");
    assert.strictEqual(formatter.joinList(["Read", "Write"]), "Read, Write");
    assert.strictEqual(formatter.joinList(null), "");
    assert.strictEqual(formatter.conditionsText(""), "—");
    assert.strictEqual(formatter.conditionsText("country eq US"), "country eq US");
  });

  QUnit.test("canEnable / canDisable / principalIcon", function (assert) {
    assert.ok(formatter.canEnable("disabled"));
    assert.notOk(formatter.canEnable("active"));
    assert.ok(formatter.canDisable("active"));
    assert.strictEqual(formatter.principalIcon("group"), "sap-icon://group");
    assert.strictEqual(formatter.principalIcon("user"), "sap-icon://employee");
  });
});
