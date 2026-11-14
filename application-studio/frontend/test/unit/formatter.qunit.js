/* global QUnit */
sap.ui.define([
  "uim/studio/model/formatter"
], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("statusState", function (assert) {
    assert.strictEqual(formatter.statusState("running"), "Success");
    assert.strictEqual(formatter.statusState("deployed"), "Success");
    assert.strictEqual(formatter.statusState("starting"), "Information");
    assert.strictEqual(formatter.statusState("building"), "Information");
    assert.strictEqual(formatter.statusState("failed"), "Error");
    assert.strictEqual(formatter.statusState("hibernated"), "Warning");
    assert.strictEqual(formatter.statusState("disconnected"), "Warning");
    assert.strictEqual(formatter.statusState("pending"), "None");
  });

  QUnit.test("statusIcon", function (assert) {
    assert.strictEqual(formatter.statusIcon("resuming"), "sap-icon://synchronize");
    assert.strictEqual(formatter.statusIcon("running"), "");
  });

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("sapFioriElements"), "Sap Fiori Elements");
    assert.strictEqual(formatter.enumText("oauth2ClientCredentials"), "Oauth2 Client Credentials");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("lists, pairs, history and days", function (assert) {
    assert.strictEqual(formatter.joinList(["sap.fiori-tools", "sap.cf-tools"]), "sap.fiori-tools, sap.cf-tools");
    assert.strictEqual(formatter.joinList(null), "");
    assert.strictEqual(formatter.keyValues([{ key: "NODE_ENV", value: "development" }]), "NODE_ENV=development");
    assert.strictEqual(formatter.history([
      { runId: "mta-1", phase: "build", status: "succeeded" },
      { runId: "mta-2", phase: "deploy", status: "deployed" }
    ]), "mta-1 build succeeded; mta-2 deploy deployed");
    assert.strictEqual(formatter.days(0), "never");
    assert.strictEqual(formatter.days(1), "1 day");
    assert.strictEqual(formatter.days("7"), "7 days");
  });
});
