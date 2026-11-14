/* global QUnit */
sap.ui.define([
  "uim/transport/model/formatter",
  "sap/ui/core/library"
], function (formatter, coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  QUnit.module("formatter");

  QUnit.test("statusState", function (assert) {
    assert.strictEqual(formatter.statusState("success"), ValueState.Success);
    assert.strictEqual(formatter.statusState("warning"), ValueState.Warning);
    assert.strictEqual(formatter.statusState("failed"), ValueState.Error);
    assert.strictEqual(formatter.statusState("initial"), ValueState.Information);
    assert.strictEqual(formatter.statusState("x"), ValueState.None);
  });

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("cloudFoundry"), "Cloud Foundry");
    assert.strictEqual(formatter.enumText("import"), "Import");
    assert.strictEqual(formatter.enumText(null), "");
  });

  QUnit.test("routeText / pending / finished", function (assert) {
    assert.strictEqual(formatter.routeText("DEV", "QA"), "DEV → QA");
    assert.ok(formatter.isPending("repeating"));
    assert.notOk(formatter.isPending("success"));
    assert.ok(formatter.isFinished("failed"));
    assert.strictEqual(formatter.nodeTypeIcon("abap"), "sap-icon://it-system");
  });
});
