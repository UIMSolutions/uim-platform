/* global QUnit */
sap.ui.define(["uim/servicemanager/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("statusState maps lifecycle states", function (assert) {
    assert.strictEqual(formatter.statusState("created"), "Success");
    assert.strictEqual(formatter.statusState("creating"), "Information");
    assert.strictEqual(formatter.statusState("deleting"), "Warning");
    assert.strictEqual(formatter.statusState("registrationFailed"), "Error");
    assert.strictEqual(formatter.statusState("unknown"), "None");
  });

  QUnit.test("enumText splits camelCase", function (assert) {
    assert.strictEqual(formatter.enumText("cloudFoundry"), "Cloud Foundry");
    assert.strictEqual(formatter.enumText("inProgress"), "In Progress");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("prettyJson formats valid JSON and keeps other text", function (assert) {
    assert.strictEqual(formatter.prettyJson("{\"a\":1}"), "{\n  \"a\": 1\n}");
    assert.strictEqual(formatter.prettyJson("not json"), "not json");
  });
});
