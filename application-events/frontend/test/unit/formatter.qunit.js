/* global QUnit */
sap.ui.define(["uim/appevents/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("states and icons", function (assert) {
    assert.strictEqual(formatter.messageState("delivered"), "Success");
    assert.strictEqual(formatter.messageState("deadLettered"), "Error");
    assert.strictEqual(formatter.messageState("retrying"), "Warning");
    assert.strictEqual(formatter.healthState("error"), "Error");
    assert.strictEqual(formatter.statusState("paused"), "Warning");
    assert.strictEqual(formatter.statusState("unknown"), "None");
    assert.strictEqual(formatter.channelIcon("queue"), "sap-icon://inbox");
  });

  QUnit.test("texts", function (assert) {
    assert.strictEqual(formatter.attempts(2, 6), "2 / 6");
    assert.strictEqual(formatter.route("S/4", "CRM"), "S/4 → CRM");
    assert.strictEqual(formatter.bytes(1048576), "1 MiB");
    assert.strictEqual(formatter.bytes(2048), "2 KiB");
    assert.strictEqual(formatter.bytes(300), "300 B");
    assert.strictEqual(formatter.shortType("sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1"),
      "…BusinessPartner.Created.v1");
    assert.strictEqual(formatter.shortType("a.b"), "a.b");
    assert.strictEqual(formatter.json('{"a":1}'), '{\n  "a": 1\n}');
    assert.strictEqual(formatter.json("plain"), "plain");
    assert.strictEqual(formatter.payloadState("{"), "Error");
    assert.strictEqual(formatter.payloadState(""), "None");
    assert.strictEqual(formatter.enumText.call({}, ""), "");
  });
});
