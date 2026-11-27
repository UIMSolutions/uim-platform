/* global QUnit */
sap.ui.define(["uim/datasphere/model/session"], function (session) {
  "use strict";

  QUnit.module("session");

  QUnit.test("apply: open mode grants everything", function (assert) {
    var model = session.createSessionModel();
    session.apply(model, { mode: "open", loginRequired: false }, null);
    assert.strictEqual(model.getProperty("/authenticated"), false);
    assert.strictEqual(model.getProperty("/isAdmin"), true);
    assert.strictEqual(model.getProperty("/canIntegrate"), true);
    assert.strictEqual(model.getProperty("/canModel"), true);
    assert.strictEqual(model.getProperty("/token"), "");
  });

  QUnit.test("apply: an integrator runs but does not model", function (assert) {
    var model = session.createSessionModel();
    session.apply(model, { mode: "jwt", loginRequired: true }, {
      token: "t", expiresAt: 0, user: { id: "grace", displayName: "Grace", tenant: "default", scopes: ["Read", "Integrate"] }
    });
    assert.strictEqual(model.getProperty("/authenticated"), true);
    assert.strictEqual(model.getProperty("/displayName"), "Grace");
    assert.strictEqual(model.getProperty("/canIntegrate"), true);
    assert.strictEqual(model.getProperty("/canModel"), false);
    assert.strictEqual(model.getProperty("/canManage"), false);
    assert.strictEqual(model.getProperty("/isAdmin"), false);
  });

  QUnit.test("apply: modelers may integrate", function (assert) {
    var model = session.createSessionModel();
    session.apply(model, { mode: "jwt", loginRequired: true }, { token: "t", user: { id: "ada", scopes: ["Read", "Model"] } });
    assert.strictEqual(model.getProperty("/canIntegrate"), true);
    assert.strictEqual(model.getProperty("/canModel"), true);
  });

  QUnit.test("stored: expired sessions are ignored", function (assert) {
    window.sessionStorage.setItem("uim.datasphere.session", JSON.stringify({ token: "x", expiresAt: 1 }));
    assert.strictEqual(session.stored(), null);
    window.sessionStorage.removeItem("uim.datasphere.session");
  });
});
