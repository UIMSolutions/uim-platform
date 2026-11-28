/* global QUnit */
sap.ui.define([
  "uim/ailaunchpad/model/models",
  "uim/ailaunchpad/model/dialogs"
], function (models, dialogs) {
  "use strict";

  QUnit.module("models");

  QUnit.test("tile targets and groups", function (assert) {
    assert.deepEqual(models.parseTarget("lifecycle/executions"), { route: "lifecycle", tab: "executions" });
    assert.deepEqual(models.parseTarget("admin"), { route: "admin", tab: "" });
    var tiles = [
      { title: "Workspaces", subtitle: "", groupName: "AI Runtimes" },
      { title: "Executions", subtitle: "Training runs", groupName: "ML Operations" },
      { title: "Connections", subtitle: "", groupName: "AI Runtimes" }
    ];
    var groups = models.groupTiles(tiles, "");
    assert.deepEqual(groups.map(function (g) { return g.name; }), ["AI Runtimes", "ML Operations"]);
    assert.strictEqual(groups[0].tiles.length, 2);
    assert.strictEqual(models.groupTiles(tiles, "training")[0].tiles[0].title, "Executions");
  });

  QUnit.test("lists, paths and placeholders", function (assert) {
    assert.deepEqual(models.lines("epochs=3\n\n lr=0.1 "), ["epochs=3", "lr=0.1"]);
    assert.deepEqual(models.list("training, serving"), ["training", "serving"]);
    assert.strictEqual(models.entityPath("Prompts", "o'k"), "/Prompts('o''k')");
    assert.deepEqual(models.placeholders("in {{language}}", "{{ text }} and {{language}}"), ["language", "text"]);
    assert.ok(models.KPIS.indexOf("runningExecutions") >= 0);
  });

  QUnit.test("dialog payloads", function (assert) {
    var forms = models.emptyForms();
    var c = Object.assign(forms.configuration, { scenarioId: "s", name: "Train", parameters: "epochs=3\nlr=0.1" });
    assert.deepEqual(dialogs.configuration.payload(c).parameters, ["epochs=3", "lr=0.1"]);
    var conn = Object.assign(models.emptyForms().connection, { id: "c", edit: true, clientSecret: "" });
    var patch = dialogs.connection.payload(conn);
    assert.ok(!("clientSecret" in patch) && !("workspaceId" in patch) && !("id" in patch), "secret kept, immutable members not sent");
    var user = Object.assign(models.emptyForms().user, { id: "ada", password: "secret secret", roles: "Developer, Viewer" });
    assert.deepEqual(dialogs.user.payload(user).roles, ["Developer", "Viewer"]);
    var d = Object.assign(models.emptyForms().deployment, { configurationId: "serve", maxReplicas: "3" });
    assert.strictEqual(dialogs.deployment.payload(d).maxReplicas, 3);
  });
});
