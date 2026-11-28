/* global QUnit */
sap.ui.define([
  "uim/ailaunchpad/model/session"
], function (session) {
  "use strict";

  QUnit.module("session");

  QUnit.test("scopes drive the UI flags", function (assert) {
    var model = session.createSessionModel();
    session.apply(model, { mode: "jwt", loginRequired: true }, {
      token: "t", expiresAt: 1, user: { id: "bob", displayName: "Bob Builder", roles: ["Viewer"], scopes: ["Read"] }
    });
    assert.strictEqual(model.getProperty("/initials"), "BB");
    assert.ok(!model.getProperty("/isAdmin") && !model.getProperty("/canOperate") && !model.getProperty("/canManage"));
    session.apply(model, { mode: "jwt", loginRequired: true }, {
      token: "t", expiresAt: 1, user: { id: "ada", scopes: ["Read", "Operate", "Develop"] }
    });
    assert.ok(model.getProperty("/canDevelop") && model.getProperty("/canOperate") && !model.getProperty("/canManage"));
  });

  QUnit.test("open mode grants everything", function (assert) {
    var model = session.createSessionModel();
    session.apply(model, { mode: "open", loginRequired: false }, null);
    assert.ok(model.getProperty("/isAdmin") && model.getProperty("/canManage") && !model.getProperty("/authenticated"));
    assert.strictEqual(session.initials("admin"), "AD");
    assert.strictEqual(session.initials(""), "?");
  });
});
