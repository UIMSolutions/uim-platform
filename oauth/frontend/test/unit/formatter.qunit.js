/* global QUnit */
sap.ui.define(["uim/oauth/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("statusState maps client, token and code states", function (assert) {
    assert.strictEqual(formatter.statusState("active"), "Success");
    assert.strictEqual(formatter.statusState("blocked"), "Error");
    assert.strictEqual(formatter.statusState("revoked"), "Error");
    assert.strictEqual(formatter.statusState("expired"), "Warning");
    assert.strictEqual(formatter.statusState("used"), "Information");
    assert.strictEqual(formatter.statusState("unknown"), "None");
  });

  QUnit.test("enumText handles grant types, camelCase and snake_case", function (assert) {
    assert.strictEqual(formatter.enumText("client_credentials"), "Client Credentials");
    assert.strictEqual(formatter.enumText("replayDetected"), "Replay Detected");
    assert.strictEqual(formatter.enumText("public"), "Public");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("list joins collections", function (assert) {
    assert.strictEqual(formatter.list(["authorization_code", "refresh_token"]), "Authorization Code, Refresh Token");
    assert.strictEqual(formatter.list(["orders.read"]), "orders.read");
    assert.strictEqual(formatter.list([]), "–");
    assert.strictEqual(formatter.list(null), "–");
  });

  QUnit.test("duration and swatch", function (assert) {
    assert.strictEqual(formatter.duration(900), "15 min");
    assert.strictEqual(formatter.duration(3600), "1 h");
    assert.strictEqual(formatter.duration(86400), "1 d");
    assert.strictEqual(formatter.duration(61), "61 s");
    assert.strictEqual(formatter.duration(0), "–");
    assert.strictEqual(formatter.swatch("#0a6ed1"), "#0a6ed1");
    assert.strictEqual(formatter.swatch("red; x"), "Neutral");
  });

  QUnit.test("shortToken and clientTypeIcon", function (assert) {
    assert.strictEqual(formatter.shortToken("abc"), "abc");
    assert.strictEqual(formatter.shortToken(new Array(60).join("x")).length, 33);
    assert.strictEqual(formatter.clientTypeIcon("public"), "sap-icon://iphone");
    assert.strictEqual(formatter.clientTypeIcon("confidential"), "sap-icon://locked");
  });
});
