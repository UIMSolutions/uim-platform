/* global QUnit */
sap.ui.define([
  "uim/objectstore/model/formatter",
  "uim/objectstore/model/fields"
], function (formatter, fields) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("bytes and quota", function (assert) {
    assert.strictEqual(formatter.bytes(0), "0 B");
    assert.strictEqual(formatter.bytes("512"), "512 B");
    assert.strictEqual(formatter.bytes(1536), "1.5 KiB");
    assert.strictEqual(formatter.bytes("5368709120"), "5.0 GiB", "Int64 arrives as string");
    assert.strictEqual(formatter.quota("0"), "∞");
    assert.strictEqual(formatter.usagePercent("50", "200"), 25);
    assert.strictEqual(formatter.usagePercent("50", "0"), 0, "unlimited");
    assert.strictEqual(formatter.usageState("95", "100"), "Error");
  });

  QUnit.test("status and enum texts", function (assert) {
    assert.strictEqual(formatter.statusState("active"), "Success");
    assert.strictEqual(formatter.statusState("revoked"), "Error");
    assert.strictEqual(formatter.statusState("archived"), "Warning");
    assert.strictEqual(formatter.enumText("infrequentAccess"), "Infrequent Access");
    assert.strictEqual(formatter.enumText("sseKms"), "SSE-KMS");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("lists, keys and icons", function (assert) {
    assert.strictEqual(formatter.joinList(["read", "list"]), "read, list");
    assert.strictEqual(formatter.joinList([{ key: "team", value: "web" }]), "team=web");
    assert.strictEqual(formatter.leafName("a/b/c.txt"), "c.txt");
    assert.strictEqual(formatter.leafName("a/b/"), "b/");
    assert.strictEqual(formatter.fileIcon("image/png"), "sap-icon://attachment-photo");
    assert.strictEqual(formatter.fileIcon("", true), "sap-icon://folder-blank");
  });

  QUnit.module("fields");

  QUnit.test("toPayload converts dialog values", function (assert) {
    assert.deepEqual(fields.toPayload({ type: "list", value: "a, b,,c" }), ["a", "b", "c"]);
    assert.deepEqual(fields.toPayload({ type: "keyvalues", value: "team=web, env" }),
      [{ key: "team", value: "web" }, { key: "env", value: "" }]);
    assert.strictEqual(fields.toPayload({ type: "bytes", value: "1024" }), "1024");
    assert.strictEqual(fields.toPayload({ type: "number", value: "30" }), 30);
    assert.strictEqual(fields.toPayload({ type: "date", value: "2026-12-31" }), "2026-12-31T00:00:00Z");
    assert.ok(fields.CREATE_FIELDS.Buckets.some(function (f) { return f.name === "versioningEnabled"; }));
  });
});
