/* global QUnit */
sap.ui.define(["uim/datasphere/model/models", "uim/datasphere/model/dialogs"], function (models, dialogs) {
  "use strict";

  QUnit.module("models");

  QUnit.test("lines keeps commas, list splits them", function (assert) {
    assert.deepEqual(models.lines("A:DECIMAL(15,2)\n B:INTEGER \n\n"), ["A:DECIMAL(15,2)", "B:INTEGER"]);
    assert.deepEqual(models.list("DE, AT;CH\n"), ["DE", "AT", "CH"]);
    assert.deepEqual(models.lines(["x"]), ["x"]);
  });

  QUnit.test("sqlSources mirrors the server", function (assert) {
    assert.deepEqual(models.sqlSources("select o.A from s4_orders o left join \"Customers\" c on 1=1 -- FROM X\nwhere x = 'FROM Y'"),
      ["S4_ORDERS", "Customers"]);
  });

  QUnit.test("entity paths, JSON rows and times", function (assert) {
    assert.strictEqual(models.entityPath("Views", "it's"), "/Views('it''s')");
    assert.ok(models.isJsonObject("{\"COUNTRY\":\"DE\"}"));
    assert.notOk(models.isJsonObject("[1]"));
    assert.notOk(models.isJsonObject(""));
    assert.strictEqual(models.isoOrEmpty("2026-12-01T02:00:00Z"), "2026-12-01T02:00:00Z");
    assert.strictEqual(models.isoOrEmpty(""), "");
  });

  QUnit.test("dialog payloads", function (assert) {
    var forms = models.emptyForms();
    var table = Object.assign(forms.remoteTable, { spaceId: "S", connectionId: "H", name: "T", remoteObject: "O",
      columns: "A:NVARCHAR(10) key\nB:DECIMAL(15,2)" });
    assert.deepEqual(dialogs.remoteTable.payload(table).columns, ["A:NVARCHAR(10) key", "B:DECIMAL(15,2)"]);
    var conn = Object.assign(forms.connection, { id: "H", edit: true, password: "" });
    var patch = dialogs.connection.payload(conn);
    assert.notOk("password" in patch, "an empty password keeps the stored one");
    assert.notOk("spaceId" in patch, "immutable members are not sent on edit");
    var task = Object.assign(forms.task, { spaceId: "S", name: "t", targetObjectId: "x", frequency: "daily" });
    assert.notOk("intervalMinutes" in dialogs.task.payload(task));
  });
});
