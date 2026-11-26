/* global QUnit */
sap.ui.define(["uim/appevents/model/models", "uim/appevents/model/dialogs"], function (models, dialogs) {
  "use strict";

  QUnit.module("models and dialogs");

  QUnit.test("lines, paths and JSON", function (assert) {
    assert.deepEqual(models.lines("1, 2\n 3,,"), ["1", "2", "3"]);
    assert.strictEqual(models.entityPath("Subscriptions", "o'k"), "/Subscriptions('o''k')");
    assert.ok(models.isJson("") && models.isJson('{"a":1}') && !models.isJson("{"));
    assert.strictEqual(models.prettyJson('{"a":1}'), '{\n  "a": 1\n}');
  });

  QUnit.test("event type patterns match like the server", function (assert) {
    var bp = "sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1";
    assert.ok(models.matchesEventType("*", bp));
    assert.ok(models.matchesEventType("sap.s4.beh.businesspartner.v1.*", bp));
    assert.ok(models.matchesEventType("sap.s4.beh.*.v1.*.Created.v1", bp));
    assert.notOk(models.matchesEventType("sap.s4.beh.*.v1.*.Changed.v1", bp));
    assert.notOk(models.matchesEventType(bp + ".*", bp));
  });

  QUnit.test("every dialog has an empty form", function (assert) {
    var forms = models.emptyForms();
    Object.keys(dialogs).forEach(function (key) {
      assert.ok(forms[key], "form " + key);
      (dialogs[key].required || []).forEach(function (name) {
        assert.ok(name in forms[key], key + "." + name);
      });
    });
  });

  QUnit.test("channel payload: queues have no endpoint, immutables on edit", function (assert) {
    var f = Object.assign(models.emptyForms().channel, { name: "q", channelType: "queue", endpoint: "https://x",
      consumerSystemId: "crm", maxSizeBytes: "2048" });
    var p = dialogs.channel.payload(f);
    assert.strictEqual(p.endpoint, undefined, "compact create drops the cleared endpoint");
    assert.strictEqual(p.maxSizeBytes, 2048);
    f.edit = true;
    f.id = "q";
    p = dialogs.channel.payload(f);
    assert.strictEqual(p.channelType, undefined, "channelType is immutable");
    assert.strictEqual(p.consumerSystemId, undefined, "consumerSystemId is immutable");
    assert.strictEqual(p.id, undefined);
  });

  QUnit.test("publish payload: data as JSON text, empty template dropped", function (assert) {
    var f = Object.assign(models.emptyForms().publish, { type: " a.b ", source: "s4" });
    var p = dialogs.publish.payload(f);
    assert.strictEqual(p.type, "a.b");
    assert.strictEqual(p.data, undefined);
    f.data = '{"country":"DE"}';
    assert.strictEqual(dialogs.publish.payload(f).data, '{"country":"DE"}');
    assert.strictEqual(dialogs.publish.action(f), "PublishEvent");
    f.preview = true;
    assert.strictEqual(dialogs.publish.action(f), "PreviewRouting");
    f.data = "{";
    assert.notOk(dialogs.publish.check(f));
  });

  QUnit.test("filter payload: exists clears the value", function (assert) {
    var p = dialogs.filter.payload(Object.assign(models.emptyForms().filter, { subscriptionId: "s", attribute: "subject",
      operator: "exists", value: "x" }));
    assert.strictEqual(p.value, undefined);
    assert.strictEqual(p.operator, "exists");
  });
});
