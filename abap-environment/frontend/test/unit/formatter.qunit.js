/* global QUnit */
sap.ui.define([
  "uim/abap/model/formatter"
], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("statusState", function (assert) {
    assert.strictEqual(formatter.statusState("active"), "Success");
    assert.strictEqual(formatter.statusState("imported"), "Success");
    assert.strictEqual(formatter.statusState("provisioning"), "Information");
    assert.strictEqual(formatter.statusState("importing"), "Information");
    assert.strictEqual(formatter.statusState("failed"), "Error");
    assert.strictEqual(formatter.statusState("suspended"), "Warning");
    assert.strictEqual(formatter.statusState("locked"), "Warning");
    assert.strictEqual(formatter.statusState("whatever"), "None");
  });

  QUnit.test("statusIcon", function (assert) {
    assert.strictEqual(formatter.statusIcon("cloning"), "sap-icon://synchronize");
    assert.strictEqual(formatter.statusIcon("scheduled"), "");
    assert.strictEqual(formatter.statusIcon("active"), "");
  });

  QUnit.test("enumText", function (assert) {
    assert.strictEqual(formatter.enumText("notCloned"), "Not Cloned");
    assert.strictEqual(formatter.enumText("transportOfCopies"), "Transport Of Copies");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("lists, pairs and tasks", function (assert) {
    assert.strictEqual(formatter.joinList(["a", "b"]), "a, b");
    assert.strictEqual(formatter.joinList(null), "");
    assert.strictEqual(formatter.keyValues([{ key: "days", value: "30" }]), "days=30");
    assert.strictEqual(formatter.tasks([{ taskId: "DEVK900001-01", status: "released", objects: ["R3TR CLAS ZCL_A"] },
      { taskId: "DEVK900001-02", status: "modifiable", objects: [] }]),
      "DEVK900001-01 (released, 1 object); DEVK900001-02 (modifiable, 0 objects)");
  });
});
