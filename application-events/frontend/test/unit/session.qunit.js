/* global QUnit */
sap.ui.define(["uim/appevents/model/session"], function (session) {
  "use strict";

  QUnit.module("session");

  QUnit.test("apply: open mode grants everything", function (assert) {
    var model = session.createSessionModel();
    session.apply(model, { mode: "open", loginRequired: false }, null);
    assert.strictEqual(model.getProperty("/authenticated"), false);
    assert.strictEqual(model.getProperty("/isAdmin"), true);
    assert.strictEqual(model.getProperty("/canPublish"), true);
    assert.strictEqual(model.getProperty("/canOperate"), true);
    assert.strictEqual(model.getProperty("/token"), "");
  });

  QUnit.test("apply: jwt session of a producer's technical user", function (assert) {
    var model = session.createSessionModel();
    session.apply(model, { mode: "jwt", loginRequired: true }, {
      token: "t", expiresAt: 0, user: { id: "s4-tech", displayName: "S/4 producer", tenant: "default", scopes: ["Read", "Publish"] }
    });
    assert.strictEqual(model.getProperty("/authenticated"), true);
    assert.strictEqual(model.getProperty("/displayName"), "S/4 producer");
    assert.strictEqual(model.getProperty("/canPublish"), true);
    assert.strictEqual(model.getProperty("/canOperate"), false);
    assert.strictEqual(model.getProperty("/canManage"), false);
    assert.strictEqual(model.getProperty("/isAdmin"), false);
  });

  QUnit.test("apply: operators may publish", function (assert) {
    var model = session.createSessionModel();
    session.apply(model, { mode: "jwt", loginRequired: true }, { token: "t", user: { id: "ops", scopes: ["Read", "Operate"] } });
    assert.strictEqual(model.getProperty("/canPublish"), true);
    assert.strictEqual(model.getProperty("/canOperate"), true);
  });

  QUnit.test("stored: expired sessions are ignored", function (assert) {
    window.sessionStorage.setItem("uim.appevents.session", JSON.stringify({ token: "x", expiresAt: 1 }));
    assert.strictEqual(session.stored(), null);
    window.sessionStorage.removeItem("uim.appevents.session");
  });
});
