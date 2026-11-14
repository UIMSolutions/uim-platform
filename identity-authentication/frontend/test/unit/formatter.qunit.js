/* global QUnit */
sap.ui.define([
  "uim/ias/model/formatter",
  "sap/ui/core/library"
], function (formatter, coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  QUnit.module("formatter");

  QUnit.test("statusState", function (assert) {
    assert.strictEqual(formatter.statusState("active"), ValueState.Success);
    assert.strictEqual(formatter.statusState("pendingVerification"), ValueState.Warning);
    assert.strictEqual(formatter.statusState("locked"), ValueState.Error);
    assert.strictEqual(formatter.statusState("critical"), ValueState.Error);
    assert.strictEqual(formatter.statusState("x"), ValueState.None);
  });

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("pendingVerification"), "Pending Verification");
    assert.strictEqual(formatter.enumText("ip_range"), "Ip range");
    assert.strictEqual(formatter.enumText(null), "");
  });

  QUnit.test("mfa / lists / coverage", function (assert) {
    assert.strictEqual(formatter.mfaText("none"), "");
    assert.strictEqual(formatter.mfaText("totp"), "TOTP");
    assert.strictEqual(formatter.rulesText("group:in:a; mfa:eq:true"), "group:in:a\nmfa:eq:true");
    assert.strictEqual(formatter.listCount("openid profile,email"), 3);
    assert.strictEqual(formatter.coverageColor(90), "Good");
    assert.strictEqual(formatter.coverageColor(10), "Error");
    assert.strictEqual(formatter.failedState(2), ValueState.Warning);
  });
});
