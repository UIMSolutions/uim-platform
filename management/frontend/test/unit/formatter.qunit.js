/* global QUnit */
sap.ui.define([
  "uim/management/model/formatter",
  "sap/ui/core/library"
], function (formatter, coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  QUnit.module("formatter");

  QUnit.test("statusState", function (assert) {
    assert.strictEqual(formatter.statusState("active"), ValueState.Success);
    assert.strictEqual(formatter.statusState("subscribed"), ValueState.Success);
    assert.strictEqual(formatter.statusState("suspended"), ValueState.Warning);
    assert.strictEqual(formatter.statusState("error"), ValueState.Error);
    assert.strictEqual(formatter.statusState("moveInProgress"), ValueState.Information);
    assert.strictEqual(formatter.statusState("whatever"), ValueState.None);
  });

  QUnit.test("severityState", function (assert) {
    assert.strictEqual(formatter.severityState("critical"), ValueState.Error);
    assert.strictEqual(formatter.severityState("warning"), ValueState.Warning);
    assert.strictEqual(formatter.severityState("info"), ValueState.Information);
  });

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("cloudFoundry"), "Cloud Foundry");
    assert.strictEqual(formatter.enumText("subaccountLifecycle"), "Subaccount Lifecycle");
    assert.strictEqual(formatter.enumText("default_"), "Default");
    assert.strictEqual(formatter.enumText(null), "");
  });

  QUnit.test("quota / quotaPercent / usage", function (assert) {
    assert.strictEqual(formatter.quota(2, 4, false), "2 / 4");
    assert.strictEqual(formatter.quota(2, 0, true), "∞");
    assert.strictEqual(formatter.quotaPercent(2, 4, false), 50);
    assert.strictEqual(formatter.quotaPercent(9, 4, false), 100);
    assert.strictEqual(formatter.quotaPercent(1, 0, false), 0);
    assert.strictEqual(formatter.usage(3, 25), "3 / 25");
  });

  QUnit.test("canSuspend / canReactivate / joinList", function (assert) {
    assert.ok(formatter.canSuspend("active"));
    assert.notOk(formatter.canSuspend("suspended"));
    assert.ok(formatter.canReactivate("suspended"));
    assert.strictEqual(formatter.joinList(["eu10", "us10"]), "eu10, us10");
    assert.strictEqual(formatter.joinList(null), "");
  });
});
