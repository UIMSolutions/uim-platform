/* global QUnit */
sap.ui.define(["uim/oauth/model/models"], function (models) {
  "use strict";

  QUnit.module("models");

  QUnit.test("lines splits text areas into lists", function (assert) {
    assert.deepEqual(models.lines(" https://a/cb \n\nhttps://b/cb,x"), ["https://a/cb", "https://b/cb", "x"]);
    assert.deepEqual(models.lines(""), []);
    assert.deepEqual(models.lines(undefined), []);
  });

  QUnit.test("emptyForms are fresh copies", function (assert) {
    var a = models.emptyForms();
    a.client.grantTypes.push("refresh_token");
    assert.deepEqual(models.emptyForms().client.grantTypes, ["client_credentials"]);
    assert.strictEqual(models.createViewModel().getProperty("/tab"), "clients");
  });
});
