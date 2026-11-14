/* global QUnit */
sap.ui.define([
  "uim/connectivity/model/formatter"
], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("statusState", function (assert) {
    assert.strictEqual(formatter.statusState("reachable"), "Success");
    assert.strictEqual(formatter.statusState("connected"), "Success");
    assert.strictEqual(formatter.statusState("unchecked"), "Information");
    assert.strictEqual(formatter.statusState("misconfigured"), "Error");
    assert.strictEqual(formatter.statusState("revoked"), "Error");
    assert.strictEqual(formatter.statusState("deny"), "Error");
    assert.strictEqual(formatter.statusState("expiring"), "Warning");
    assert.strictEqual(formatter.statusState("maintenance"), "Warning");
    assert.strictEqual(formatter.statusState("whatever"), "None");
  });

  QUnit.test("statusIcon", function (assert) {
    assert.strictEqual(formatter.statusIcon("open"), "sap-icon://status-positive");
    assert.strictEqual(formatter.statusIcon("expired"), "sap-icon://status-negative");
    assert.strictEqual(formatter.statusIcon("maintenance"), "sap-icon://wrench");
    assert.strictEqual(formatter.statusIcon("unchecked"), "");
  });

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("onPremise"), "On Premise");
    assert.strictEqual(formatter.enumText("clientCertificateAuthentication"), "Client Certificate Authentication");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("hosts, resources, pairs and latency", function (assert) {
    assert.strictEqual(formatter.hostPort("erp.virtual", 443), "erp.virtual:443");
    assert.strictEqual(formatter.hostPort("erp.virtual", 0), "erp.virtual");
    assert.strictEqual(formatter.hostPort("", 443), "");
    assert.strictEqual(formatter.resource("https", "erp.virtual", 443, "/sap/opu", true), "https://erp.virtual:443/sap/opu (+ sub-paths)");
    assert.strictEqual(formatter.resource("rfc", "erp.virtual", 3300, "/", true), "rfc://erp.virtual:3300");
    assert.strictEqual(formatter.keyValues([{ key: "sap-client", value: "100" }]), "sap-client=100");
    assert.strictEqual(formatter.joinList(["a", "b"]), "a, b");
    assert.strictEqual(formatter.latency(25), "25 ms");
    assert.strictEqual(formatter.latency(0), "");
  });
});
