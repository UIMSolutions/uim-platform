/* global QUnit */
sap.ui.define([
  "uim/auditlog/model/formatter",
  "sap/ui/core/library"
], function (formatter, coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  QUnit.module("formatter");

  QUnit.test("severityState", function (assert) {
    assert.strictEqual(formatter.severityState("critical"), ValueState.Error);
    assert.strictEqual(formatter.severityState("warning"), ValueState.Warning);
    assert.strictEqual(formatter.severityState("info"), ValueState.Information);
    assert.strictEqual(formatter.severityState("x"), ValueState.None);
  });

  QUnit.test("outcomeState", function (assert) {
    assert.strictEqual(formatter.outcomeState("success"), ValueState.Success);
    assert.strictEqual(formatter.outcomeState("denied"), ValueState.Warning);
    assert.strictEqual(formatter.outcomeState("failure"), ValueState.Error);
  });

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("securityEvents"), "Security Events");
    assert.strictEqual(formatter.enumText("loginFailed"), "Login Failed");
    assert.strictEqual(formatter.enumText(null), "");
  });

  QUnit.test("attributes / joinList / downloadHref", function (assert) {
    assert.strictEqual(formatter.attributes([{ name: "a", oldValue: "1", newValue: "2" }]), "a: 1 → 2");
    assert.strictEqual(formatter.joinList(["x", "y"]), "x, y");
    assert.strictEqual(formatter.downloadHref("/api/v1/exports/1/download"), "api/v1/exports/1/download");
  });
});
