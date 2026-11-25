/* global QUnit */
sap.ui.define(["uim/documentai/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("states of documents, schemas and values", function (assert) {
    assert.strictEqual(formatter.documentState("confirmed"), "Success");
    assert.strictEqual(formatter.documentState("failed"), "Error");
    assert.strictEqual(formatter.documentState("whatever"), "None");
    assert.strictEqual(formatter.schemaState("draft"), "Information");
    assert.strictEqual(formatter.valueState("high", false, false), "None");
    assert.strictEqual(formatter.valueState("low", false, false), "Error");
    assert.strictEqual(formatter.valueState("high", true, false), "Error", "missing required value");
    assert.strictEqual(formatter.valueState("low", false, true), "Success", "corrected");
    assert.strictEqual(formatter.percentState(95), "Success");
    assert.strictEqual(formatter.percentState(75), "Warning");
    assert.strictEqual(formatter.percentState(10), "Error");
  });

  QUnit.test("texts", function (assert) {
    assert.strictEqual(formatter.enumText("purchaseOrder"), "Purchase Order");
    assert.strictEqual(formatter.enumText("mlModel"), "ML Model");
    assert.strictEqual(formatter.enumText(""), "");
    assert.strictEqual(formatter.fileSize(182344), "178 KB");
    assert.strictEqual(formatter.fileSize(2310000), "2.2 MB");
    assert.strictEqual(formatter.fileSize(0), "");
    assert.strictEqual(formatter.percent(0.874), "87 %");
    assert.strictEqual(formatter.row(0), "");
    assert.strictEqual(formatter.row(2), "#2");
    assert.strictEqual(formatter.fileIcon("pdf"), "sap-icon://pdf-attachment");
  });
});
