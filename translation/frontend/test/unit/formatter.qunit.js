/* global QUnit */
sap.ui.define([
  "uim/translation/model/formatter"
], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("statusState", function (assert) {
    assert.strictEqual(formatter.statusState("completed"), "Success");
    assert.strictEqual(formatter.statusState("reviewed"), "Success");
    assert.strictEqual(formatter.statusState("inProgress"), "Warning");
    assert.strictEqual(formatter.statusState("partial"), "Warning");
    assert.strictEqual(formatter.statusState("failed"), "Error");
    assert.strictEqual(formatter.statusState("untranslated"), "Error");
    assert.strictEqual(formatter.statusState("pending"), "Information");
    assert.strictEqual(formatter.statusState("archived"), "None");
  });

  QUnit.test("statusIcon", function (assert) {
    assert.strictEqual(formatter.statusIcon("translated"), "sap-icon://status-positive");
    assert.strictEqual(formatter.statusIcon("failed"), "sap-icon://status-negative");
    assert.strictEqual(formatter.statusIcon("processing"), "sap-icon://synchronize");
    assert.strictEqual(formatter.statusIcon("draft"), "");
  });

  QUnit.test("quality and progress", function (assert) {
    assert.strictEqual(formatter.qualityState(92), "Success");
    assert.strictEqual(formatter.qualityState(65), "Warning");
    assert.strictEqual(formatter.qualityState(40), "Error");
    assert.strictEqual(formatter.qualityState(0), "None");
    assert.strictEqual(formatter.percentState(100), "Success");
    assert.strictEqual(formatter.percentState(50), "Warning");
    assert.strictEqual(formatter.percentState(0), "None");
    assert.strictEqual(formatter.percent(undefined), 0);
    assert.ok(formatter.isDraft("draft") && !formatter.isDraft("active"));
    assert.ok(formatter.isOpen("completed") && !formatter.isOpen("archived") && !formatter.isOpen(undefined));
  });

  QUnit.test("texts", function (assert) {
    assert.strictEqual(formatter.enumText("inProgress"), "In Progress");
    assert.strictEqual(formatter.enumText("companyMltr"), "Company Mltr");
    assert.strictEqual(formatter.enumText(""), "");
    assert.strictEqual(formatter.joinList(["de", "fr"]), "de, fr");
    assert.strictEqual(formatter.languagePair("en", ["de", "fr"]), "en → de, fr");
    assert.strictEqual(formatter.languagePair("", ["de"]), "");
    assert.strictEqual(formatter.translations([{ language: "de", text: "Sichern", reviewed: true },
      { language: "fr", text: "Enregistrer" }]), "de: Sichern ✓ · fr: Enregistrer");
    assert.strictEqual(formatter.translations(null), "");
  });
});
