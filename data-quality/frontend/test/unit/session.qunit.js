/* global QUnit */
sap.ui.define(["uim/dataquality/model/session"], function (session) {
  "use strict";

  QUnit.module("session");

  QUnit.test("apply: open mode grants everything", function (assert) {
    var model = session.createSessionModel();
    session.apply(model, { mode: "open", loginRequired: false }, null);
    assert.strictEqual(model.getProperty("/authenticated"), false);
    assert.strictEqual(model.getProperty("/isAdmin"), true);
    assert.strictEqual(model.getProperty("/token"), "");
  });

  QUnit.test("apply: jwt session", function (assert) {
    var model = session.createSessionModel();
    session.apply(model, { mode: "jwt", loginRequired: true }, {
      token: "t", expiresAt: 0, user: { id: "viewer", displayName: "Viewer", tenant: "default", scopes: ["Read"] }
    });
    assert.strictEqual(model.getProperty("/authenticated"), true);
    assert.strictEqual(model.getProperty("/displayName"), "Viewer");
    assert.strictEqual(model.getProperty("/canManage"), false);
    assert.strictEqual(model.getProperty("/isAdmin"), false);
  });

  QUnit.test("stored: expired sessions are ignored", function (assert) {
    window.sessionStorage.setItem("uim.dataquality.session", JSON.stringify({ token: "x", expiresAt: 1 }));
    assert.strictEqual(session.stored(), null);
    window.sessionStorage.removeItem("uim.dataquality.session");
  });
});
