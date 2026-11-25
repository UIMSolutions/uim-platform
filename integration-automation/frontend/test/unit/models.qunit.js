/* global QUnit */
sap.ui.define(["uim/integrationautomation/model/models", "uim/integrationautomation/model/dialogs"], function (models, dialogs) {
  "use strict";

  QUnit.module("models");

  QUnit.test("lines and entity paths", function (assert) {
    assert.deepEqual(models.lines("a\n b,\n\n"), ["a", "b"]);
    assert.strictEqual(models.entityPath("Workflows", "o'neil"), "/Workflows('o''neil')");
  });

  QUnit.test("every dialog has an empty form", function (assert) {
    var forms = models.emptyForms();
    Object.keys(dialogs).forEach(function (key) {
      assert.ok(forms[key], "form " + key);
    });
  });

  QUnit.test("create payloads are compact, edits keep immutables out", function (assert) {
    var form = Object.assign(models.emptyForms().scenarioTask, { scenarioId: "sc", name: "Call", sequenceNumber: "30",
      dependsOn: "a\nb" });
    var created = dialogs.scenarioTask.payload(form);
    assert.strictEqual(created.sequenceNumber, 30);
    assert.deepEqual(created.dependsOn, ["a", "b"]);
    assert.notOk("id" in created, "no empty id");
    var changed = dialogs.scenarioTask.payload(Object.assign({}, form, { id: "t1", edit: true }));
    assert.notOk("scenarioId" in changed, "scenarioId is immutable");
    assert.strictEqual(changed.destinationId, null);
    assert.deepEqual(dialogs.scenario.payload(Object.assign(models.emptyForms().scenario, { name: "S", prerequisites: "x\ny" }))
      .prerequisites, ["x", "y"]);
  });

  QUnit.test("task actions send their text parameter", function (assert) {
    assert.deepEqual(dialogs.taskAction.payload({ id: "t", param: "reason", text: "done elsewhere" }), { id: "t", reason: "done elsewhere" });
    assert.deepEqual(dialogs.taskAction.payload({ id: "t", param: "result", text: "" }), { id: "t" });
    assert.strictEqual(dialogs.taskAction.check({ required: true, text: " " }), false);
    assert.strictEqual(dialogs.taskAction.action({ action: "SkipTask" }), "SkipTask");
  });
});
