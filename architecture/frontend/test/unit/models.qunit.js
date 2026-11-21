/* global QUnit */
sap.ui.define(["uim/architecture/model/models"], function (models) {
  "use strict";

  QUnit.module("models");

  QUnit.test("lines and entity paths", function (assert) {
    assert.deepEqual(models.lines("a\n b,\n\n"), ["a", "b"]);
    assert.strictEqual(models.entityPath("BuildingBlocks", "o'k"), "/BuildingBlocks('o''k')");
  });

  QUnit.test("create payload contains the non-empty values", function (assert) {
    var form = models.emptyBlockForm("solution");
    form.name = " Sales Cloud ";
    form.realizesId = "abb-crm";
    form.tags = "crm\nsaas";
    var payload = models.formToPayload(form, null);
    assert.deepEqual(payload, { kind: "solution", name: "Sales Cloud", versionLabel: "1.0.0", realizesId: "abb-crm", tags: ["crm", "saas"] });
  });

  QUnit.test("edit payload contains only the changes", function (assert) {
    var row = { id: "abb-crm", kind: "architecture", name: "CRM", owner: "ea", versionLabel: "1.0.0", tags: ["crm"],
      interfaces: [], validUntil: "2027-01-01" };
    var form = models.blockToForm(row);
    assert.strictEqual(form.mode, "edit");
    assert.strictEqual(form.tags, "crm");
    form.owner = "architecture-board";
    form.validUntil = "";
    assert.deepEqual(models.formToPayload(form, row), { owner: "architecture-board", validUntil: null });
    assert.deepEqual(models.formToPayload(models.blockToForm(row), row), {}, "unchanged → empty");
  });
});
