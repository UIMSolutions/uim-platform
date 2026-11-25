/* global QUnit */
sap.ui.define(["uim/documentai/model/models", "uim/documentai/model/dialogs"], function (models, dialogs) {
  "use strict";

  QUnit.module("models");

  QUnit.test("lists, pairs and paths", function (assert) {
    assert.deepEqual(models.lines("en,\n de\n\n"), ["en", "de"]);
    assert.deepEqual(models.pairs("senderName=ACME, Inc.\n\nsenderCity=Berlin"), ["senderName=ACME, Inc.", "senderCity=Berlin"]);
    assert.strictEqual(models.entityPath("Documents", "o'k"), "/Documents('o''k')");
    assert.strictEqual(models.fileTypeOf("Scan.JPG"), "jpeg");
    assert.strictEqual(models.fileTypeOf("virus.exe"), "");
  });

  QUnit.test("every dialog has an empty form", function (assert) {
    var forms = models.emptyForms();
    Object.keys(dialogs).forEach(function (key) {
      assert.ok(forms[key], "form " + key);
    });
  });

  QUnit.module("dialogs");

  QUnit.test("upload payload", function (assert) {
    var f = Object.assign(models.emptyForms().upload, { fileName: "a.pdf", labels: "a=1\nb=2", pageCount: "3" });
    var p = dialogs.upload.payload(f);
    assert.deepEqual(p.labels, ["a=1", "b=2"]);
    assert.strictEqual(p.pageCount, 3);
    assert.strictEqual(p.extractNow, undefined, "UI only");
    assert.strictEqual(p.schemaId, undefined, "empty references are left to the backend");
  });

  QUnit.test("resource payloads: create compact, PATCH without immutable members", function (assert) {
    var create = dialogs.schemaField.payload(Object.assign(models.emptyForms().schemaField,
      { schemaId: "invoice", name: "iban", sequenceNumber: "30" }));
    assert.strictEqual(create.sequenceNumber, 30);
    assert.strictEqual(create.schemaId, "invoice");
    assert.strictEqual(create.id, undefined);
    var patch = dialogs.schemaField.payload(Object.assign(models.emptyForms().schemaField,
      { id: "f1", schemaId: "invoice", name: "iban", edit: true }));
    assert.strictEqual(patch.schemaId, undefined);
    assert.strictEqual(patch.id, undefined);
    assert.strictEqual(patch.description, "", "empty texts clear values on PATCH");
    assert.strictEqual(dialogs.schemaField.patch({ edit: true, id: "f1" }), "f1");
    var training = dialogs.training.payload(Object.assign(models.emptyForms().training, { schemaId: "s", name: "n", startNow: true }));
    assert.strictEqual(training.startNow, undefined);
    var enrichment = dialogs.enrichment.payload(Object.assign(models.emptyForms().enrichment,
      { name: "ACME", attributes: "senderName=ACME, Inc." }));
    assert.deepEqual(enrichment.attributes, ["senderName=ACME, Inc."]);
  });
});
