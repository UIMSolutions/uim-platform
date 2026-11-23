/* global QUnit */
sap.ui.define(["uim/dataquality/model/models", "uim/dataquality/model/dialogs"], function (models, dialogs) {
  "use strict";

  QUnit.module("models");

  QUnit.test("helpers", function (assert) {
    assert.deepEqual(models.lines("a\n b,\n\n"), ["a", "b"]);
    assert.deepEqual(models.fieldLines("name=Müller, Jürgen\n\nage=42"), ["name=Müller, Jürgen", "age=42"]);
    assert.deepEqual(models.splitKey("customers~c-1"), { dataset: "customers", id: "c-1" });
    assert.deepEqual(models.candidate("c-1=93.5"), { recordId: "c-1", score: 93.5 });
    assert.strictEqual(models.entityPath("Records", "it's~1"), "/Records('it''s~1')");
  });

  QUnit.test("every dialog has an empty form", function (assert) {
    var forms = models.emptyForms();
    Object.keys(dialogs).forEach(function (key) {
      assert.ok(forms[key], key + " form");
      assert.ok(dialogs[key].set || dialogs[key].action, key + " target");
    });
  });

  QUnit.test("payloads", function (assert) {
    var rule = Object.assign(models.emptyForms().validationRule, { name: "Status", fieldName: "status",
      ruleType: "enumeration", allowedValues: "active\nblocked" });
    var payload = dialogs.validationRule.payload(rule);
    assert.deepEqual(payload.allowedValues, ["active", "blocked"]);
    assert.notOk("pattern" in payload, "empty texts are left to the backend defaults");
    assert.strictEqual(dialogs.validationRule.patch(rule), undefined, "create, not patch");
    var user = dialogs.user.payload({ id: "ops", displayName: "", password: "", scopes: "Read\nManage", edit: true });
    assert.notOk("password" in user, "an empty password keeps the current one");
    assert.deepEqual(user.scopes, ["Read", "Manage"]);
  });
});
