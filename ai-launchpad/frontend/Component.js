sap.ui.define([
  "sap/ui/core/UIComponent",
  "sap/ui/core/Fragment",
  "sap/ui/model/odata/v4/ODataModel",
  "sap/ui/model/json/JSONModel",
  "uim/ailaunchpad/model/models",
  "uim/ailaunchpad/model/session"
], function (UIComponent, Fragment, ODataModel, JSONModel, models, session) {
  "use strict";

  return UIComponent.extend("uim.ailaunchpad.Component", {
    metadata: {
      manifest: "json",
      interfaces: ["sap.ui.core.IAsyncContentCreation"]
    },

    /**
     * Login first: the OData model is created only after the session is
     * known, so that $metadata and every request carry the bearer token of
     * the built-in login (authMode "jwt"). Behind the approuter (XSUAA) or
     * in open mode there is no login dialog. Then the router starts.
     */
    init: function () {
      UIComponent.prototype.init.apply(this, arguments);
      this.setModel(models.createDeviceModel(), "device");
      this.setModel(models.createViewModel(), "view");
      this.setModel(session.createSessionModel(), "session");

      session.loadConfig().then(function (config) {
        this._authConfig = config;
        var stored = session.stored();
        if (!config.loginRequired || stored) {
          return stored;
        }
        return this.showLogin();
      }.bind(this)).then(function (current) {
        session.apply(this.getModel("session"), this._authConfig, current);
        this.setModel(this.createDataModel(current ? current.token : ""));
        this.getRouter().initialize();
        if (current) {
          session.scheduleExpiry(current, this.onSessionExpired.bind(this));
        }
      }.bind(this));
    },

    createDataModel: function (token) {
      var source = this.getManifestEntry("/sap.app/dataSources/mainService");
      return new ODataModel({
        serviceUrl: source.uri,
        operationMode: "Server",
        autoExpandSelect: true,
        earlyRequests: true,
        groupId: "$auto",
        httpHeaders: token ? { Authorization: "Bearer " + token } : {}
      });
    },

    /** Modal login dialog; resolves with the new session. */
    showLogin: function () {
      var form = new JSONModel({ username: "", password: "", tenant: "", error: "", busy: false, showTenant: false });
      return new Promise(function (resolve) {
        var handler = {
          onEscape: function (promise) {
            promise.reject(); // the login cannot be skipped
          },
          onToggleTenant: function () {
            form.setProperty("/showTenant", !form.getProperty("/showTenant"));
          },
          onLogin: function () {
            var data = form.getData();
            if (!data.username || !data.password) {
              form.setProperty("/error", this.getModel("i18n").getResourceBundle().getText("loginMissing"));
              return;
            }
            form.setProperty("/busy", true);
            session.login(data.username.trim(), data.password, data.tenant.trim()).then(function (s) {
              this._loginDialog.close();
              resolve(s);
            }.bind(this), function (error) {
              form.setProperty("/password", "");
              form.setProperty("/error", error.message);
            }).finally(function () {
              form.setProperty("/busy", false);
            });
          }.bind(this)
        };
        Fragment.load({ name: "uim.ailaunchpad.fragment.LoginDialog", controller: handler }).then(function (dialog) {
          this._loginDialog = dialog;
          dialog.setModel(form, "login");
          dialog.setModel(this.getModel("i18n"), "i18n");
          dialog.open();
        }.bind(this));
      }.bind(this));
    },

    /** The token ran out: log in again. */
    onSessionExpired: function () {
      session.logout("").then(function () {
        window.location.reload();
      });
    },

    /** Drop the token and start over (login dialog). */
    logout: function () {
      session.logout(this.getModel("session").getProperty("/token")).then(function () {
        window.location.hash = "";
        window.location.reload();
      });
    }
  });
});
