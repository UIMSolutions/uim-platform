/* global QUnit */
sap.ui.define([
  "uim/kyma/model/formatter"
], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("statusState", function (assert) {
    assert.strictEqual(formatter.statusState("running"), "Success");
    assert.strictEqual(formatter.statusState("building"), "Information");
    assert.strictEqual(formatter.statusState("failed"), "Error");
    assert.strictEqual(formatter.statusState("paused"), "Warning");
    assert.strictEqual(formatter.statusState("whatever"), "None");
  });

  QUnit.test("statusIcon", function (assert) {
    assert.strictEqual(formatter.statusIcon("provisioning"), "sap-icon://synchronize");
    assert.strictEqual(formatter.statusIcon("running"), "");
  });

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("notReady"), "Not Ready");
    assert.strictEqual(formatter.enumText("api-gateway"), "Api gateway");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("lists and pairs", function (assert) {
    assert.strictEqual(formatter.joinList(["a", "b"]), "a, b");
    assert.strictEqual(formatter.joinList(null), "");
    assert.strictEqual(formatter.keyValues([{ key: "app", value: "shop" }]), "app=shop");
    assert.strictEqual(formatter.accessRules([{ path: "/*", methods: ["GET"], accessStrategy: "noAuth" }]), "GET /* (noAuth)");
    assert.strictEqual(formatter.hostUrl("a.example.com"), "https://a.example.com");
  });
});
