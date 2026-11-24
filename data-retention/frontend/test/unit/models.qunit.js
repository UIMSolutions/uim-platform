/* global QUnit */
sap.ui.define(["uim/dataretention/model/models", "uim/dataretention/model/dialogs"], function (models, dialogs) {
  "use strict";

  QUnit.module("models");

  QUnit.test("lines and entity paths", function (assert) {
    assert.deepEqual(models.lines("S4-SD\n S4-FI,\n\n"), ["S4-SD", "S4-FI"]);
    assert.strictEqual(models.entityPath("DataSubjects", "o'neil"), "/DataSubjects('o''neil')");
    assert.strictEqual(models.dateTime("2026-12-01"), "2026-12-01T00:00:00Z");
    assert.strictEqual(models.dateTime(""), "");
  });

  QUnit.test("every dialog has an empty form", function (assert) {
    var forms = models.emptyForms();
    Object.keys(dialogs).forEach(function (key) {
      assert.ok(forms[key], "form " + key);
    });
  });

  QUnit.test("create payloads are compact, edits keep immutables out", function (assert) {
    var created = dialogs.residenceRule.payload({ id: "", businessPurposeId: "", legalGroundId: "g1", duration: "6",
      periodUnit: "months", active: true, edit: false });
    assert.deepEqual(created, { legalGroundId: "g1", duration: 6, periodUnit: "months", active: true });
    var changed = dialogs.residenceRule.payload({ id: "r1", businessPurposeId: "p", legalGroundId: "g1", duration: 2,
      periodUnit: "years", active: false, edit: true });
    assert.deepEqual(changed, { duration: 2, periodUnit: "years", active: false });
    assert.deepEqual(dialogs.applicationGroup.payload({ id: "erp", name: "ERP", description: "", scope: "global",
      applicationIds: "A\nB", active: true, edit: false }).applicationIds, ["A", "B"]);
    assert.strictEqual(dialogs.dataSubject.payload({ id: "ds", externalId: "C", displayName: "", businessPurposeId: "p",
      legalGroundId: "", applicationGroupId: "", dataSubjectRoleId: "", legalEntityId: "", referenceDate: "", edit: true })
      .referenceDate, null);
  });
});
