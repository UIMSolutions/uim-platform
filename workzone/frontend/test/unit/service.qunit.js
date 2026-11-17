sap.ui.define([
  "uim/workzone/model/service"
], function (Service) {
  "use strict";

  QUnit.module("service");

  QUnit.test("keyPath escapes quotes", function (assert) {
    assert.strictEqual(Service.keyPath("Workspaces", "a'b"), "Workspaces('a''b')");
  });
});
