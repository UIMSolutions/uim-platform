/* global QUnit */
sap.ui.define(["uim/autoscaler/model/models", "uim/autoscaler/model/dialogs"], function (models, dialogs) {
  "use strict";

  QUnit.module("models and dialogs");

  QUnit.test("lines and paths", function (assert) {
    assert.deepEqual(models.lines("1, 2\n 3,,"), ["1", "2", "3"]);
    assert.deepEqual(models.lines(["1"]), ["1"]);
    assert.strictEqual(models.entityPath("Bindings", "o'k"), "/Bindings('o''k')");
    assert.ok(models.isPercentMetric("cpu") && !models.isPercentMetric("throughput"));
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

  QUnit.test("schedule payload: days as lists, other kind cleared", function (assert) {
    var f = Object.assign(models.emptyForms().schedule, { policyId: "web", daysOfWeek: "1, 2", startDateTime: "x" });
    var p = dialogs.schedule.payload(f);
    assert.deepEqual(p.daysOfWeek, ["1", "2"]);
    assert.strictEqual(p.startDateTime, undefined, "compact create drops cleared members");
    f.kind = "specificDate";
    f.edit = true;
    p = dialogs.schedule.payload(f);
    assert.deepEqual(p.daysOfWeek, []);
    assert.strictEqual(p.kind, undefined, "kind is immutable");
    assert.strictEqual(p.policyId, undefined, "policyId is immutable");
  });

  QUnit.test("rule payload: numbers, custom name only for custom metrics", function (assert) {
    var p = dialogs.rule.payload(Object.assign(models.emptyForms().rule, { policyId: "web", threshold: "75", customMetricName: "x" }));
    assert.strictEqual(p.threshold, 75);
    assert.strictEqual(p.customMetricName, undefined);
  });
});
