/* global QUnit */
sap.ui.define(["uim/aicore/model/models"], function (models) {
  "use strict";

  QUnit.module("models");

  QUnit.test("lines", function (assert) {
    assert.deepEqual(models.lines("a=1\n b=2 ,\n\n"), ["a=1", "b=2"]);
    assert.deepEqual(models.lines(""), []);
  });

  QUnit.test("composite keys", function (assert) {
    assert.deepEqual(models.splitKey("default~abc"), { group: "default", id: "abc" });
    assert.deepEqual(models.splitKey("abc"), { group: "", id: "abc" });
    assert.strictEqual(models.entityPath("Executions", "default~abc"), "/Executions('default~abc')");
  });

  QUnit.test("forms", function (assert) {
    var forms = models.emptyForms();
    assert.strictEqual(forms.executable.type, "workflow");
    assert.strictEqual(forms.schedule.status, "ACTIVE");
    var view = models.createViewModel();
    assert.strictEqual(view.getProperty("/tab"), "executions");
    assert.strictEqual(view.getProperty("/group"), "");
  });
});
