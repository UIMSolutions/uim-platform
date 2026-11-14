/* global QUnit */
sap.ui.define(["uim/taskcenter/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("statusState maps task, provider and rule states", function (assert) {
    assert.strictEqual(formatter.statusState("completed"), "Success");
    assert.strictEqual(formatter.statusState("inProgress"), "Warning");
    assert.strictEqual(formatter.statusState("failed"), "Error");
    assert.strictEqual(formatter.statusState("open"), "Information");
    assert.strictEqual(formatter.statusState("error"), "Error");
    assert.strictEqual(formatter.statusState("unknown"), "None");
  });

  QUnit.test("priority and outcome states", function (assert) {
    assert.strictEqual(formatter.priorityState("veryHigh"), "Error");
    assert.strictEqual(formatter.priorityState("high"), "Warning");
    assert.strictEqual(formatter.priorityState("low"), "None");
    assert.strictEqual(formatter.outcomeState("approved"), "Success");
    assert.strictEqual(formatter.outcomeState("rejected"), "Error");
  });

  QUnit.test("enumText splits camelCase", function (assert) {
    assert.strictEqual(formatter.enumText("inProgress"), "In Progress");
    assert.strictEqual(formatter.enumText("veryHigh"), "Very High");
    assert.strictEqual(formatter.enumText(""), "");
  });

  QUnit.test("canDo checks availableActions", function (assert) {
    assert.ok(formatter.canDo(["claim", "forward"], "claim"));
    assert.notOk(formatter.canDo(["claim"], "approve"));
    assert.notOk(formatter.canDo(null, "claim"));
  });

  QUnit.test("actionList and actionFlags", function (assert) {
    assert.strictEqual(formatter.actionList(["approve", "reject"]), "approve, reject");
    assert.strictEqual(formatter.actionList([]), "*");
    assert.ok(formatter.actionFlags(["claim"]).claim);
    assert.notOk(formatter.actionFlags(["claim"]).approve);
  });

  QUnit.test("dueState: overdue error, due soon warning", function (assert) {
    var today = new Date().toISOString().slice(0, 10);
    assert.strictEqual(formatter.dueState("2020-01-01", true), "Error");
    assert.strictEqual(formatter.dueState(today, false), "Warning");
    assert.strictEqual(formatter.dueState("2999-12-31", false), "None");
    assert.strictEqual(formatter.dueState("2020-01-01", false), "None"); // finished task
    assert.strictEqual(formatter.dueState(null, false), "None");
  });

  QUnit.test("assigneeText shows substitutions", function (assert) {
    assert.strictEqual(formatter.assigneeText("ben", "dora"), "ben (↪ dora)");
    assert.strictEqual(formatter.assigneeText("ben", null), "ben");
    assert.strictEqual(formatter.assigneeText("", null), "–");
  });

  QUnit.test("inboxFilter combines scope and saved filter", function (assert) {
    assert.strictEqual(formatter.inboxFilter("mine", "anna", ""), "assignee eq 'anna'");
    assert.strictEqual(formatter.inboxFilter("mine", "o'brien", "priority eq 'high'"), "assignee eq 'o''brien' and (priority eq 'high')");
    assert.strictEqual(formatter.inboxFilter("all", "anna", ""), "");
  });

  QUnit.test("bytes and prettyJson", function (assert) {
    assert.strictEqual(formatter.bytes(512), "512 B");
    assert.strictEqual(formatter.bytes("184320"), "180 KB");
    assert.strictEqual(formatter.bytes(null), "–");
    assert.strictEqual(formatter.prettyJson("{\"a\":1}"), "{\n  \"a\": 1\n}");
    assert.strictEqual(formatter.prettyJson("not json"), "not json");
  });
});
