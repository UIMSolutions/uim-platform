/* global QUnit */
sap.ui.define([
  "uim/identityprovisioning/model/formatter"
], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("statusState / statusIcon", function (assert) {
    assert.strictEqual(formatter.statusState("active"), "Success");
    assert.strictEqual(formatter.statusState("completed"), "Success");
    assert.strictEqual(formatter.statusState("failed"), "Error");
    assert.strictEqual(formatter.statusState("error"), "Error");
    assert.strictEqual(formatter.statusState("configuring"), "Warning");
    assert.strictEqual(formatter.statusState("scheduled"), "Information");
    assert.strictEqual(formatter.statusState("cancelled"), "None");
    assert.strictEqual(formatter.statusIcon("running"), "sap-icon://synchronize");
    assert.strictEqual(formatter.operationIcon("delete"), "sap-icon://delete");
  });

  QUnit.test("enumText / interval", function (assert) {
    assert.strictEqual(formatter.enumText("oauth2ClientCredentials"), "Oauth2 Client Credentials");
    assert.strictEqual(formatter.enumText("successFactors"), "Success Factors");
    assert.strictEqual(formatter.enumText(""), "");
    assert.strictEqual(formatter.interval(0), "On demand");
    assert.strictEqual(formatter.interval(60), "Every 60 min");
  });

  QUnit.test("mappings / conditions", function (assert) {
    assert.strictEqual(formatter.mappings([]), "pass-through");
    assert.strictEqual(formatter.mappings([
      { sourcePath: "email", targetPath: "emails[0].value", mandatory: true },
      { sourcePath: "", targetPath: "userType", defaultValue: "employee" }
    ]), "email → emails[0].value*, 'employee' → userType");
    assert.strictEqual(formatter.conditions([
      { attribute: "department", operator: "notEquals", value: "HR" },
      { attribute: "email", operator: "present", value: "" }
    ]), "department notEquals HR and email present");
  });

  QUnit.test("key/value lines round trip", function (assert) {
    var a = formatter.parseKeyValues("sim.users=8\n\n ldap.user.filter = (objectClass=person) \nflag");
    assert.deepEqual(a, [
      { key: "sim.users", value: "8" },
      { key: "ldap.user.filter", value: "(objectClass=person)" },
      { key: "flag", value: "" }
    ]);
    assert.deepEqual(formatter.parseKeyValues("a=1,b=2"), [{ key: "a", value: "1" }, { key: "b", value: "2" }]);
    assert.strictEqual(formatter.keyValueLines(a.slice(0, 1)), "sim.users=8");
    assert.strictEqual(formatter.keyValues(a.slice(0, 1)), "sim.users=8");
  });

  QUnit.test("action visibility", function (assert) {
    assert.ok(formatter.isRunnable("completed"));
    assert.notOk(formatter.isRunnable("cancelled"));
    assert.notOk(formatter.isRunnable("running"));
    assert.ok(formatter.canActivate("error"));
    assert.notOk(formatter.canActivate("active"));
  });
});
