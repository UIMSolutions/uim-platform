sap.ui.define([
  "sap/ui/model/json/JSONModel",
  "sap/ui/Device"
], function (JSONModel, Device) {
  "use strict";

  return {
    createDeviceModel: function () {
      var model = new JSONModel(Device);
      model.setDefaultBindingMode("OneWay");
      return model;
    },

    /** Empty forms of the dialogs. Lists are edited as one entry per line. */
    emptyForms: function () {
      return {
        client: { name: "", clientId: "", clientType: "confidential", description: "", grantTypes: ["client_credentials"],
          redirectUris: "", allowedScopes: [], accessTokenValidity: 3600, refreshTokenValidity: 86400, contacts: "" },
        scope: { applicationId: "", name: "", description: "" },
        branding: { name: "", pageTitle: "", primaryColor: "#0a6ed1", secondaryColor: "#354a5f", logoUrl: "",
          backgroundUrl: "", footerText: "", customCss: "", isDefault: false, description: "" },
        testToken: { clientId: "", clientSecret: "", scope: "" },
        introspect: { token: "", tokenTypeHint: "" }
      };
    },

    /** UI state: forms, the selected tab and the result of the last action. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "clients",
        form: this.emptyForms(),
        secret: { clientId: "", clientSecret: "", revokedTokens: 0 },
        token: null,
        introspection: null,
        edit: { redirectUris: "", allowedScopes: [], contacts: "", grantTypes: [] }
      });
    },

    /** "a\n b\n\n" → ["a", "b"] */
    lines: function (text) {
      return String(text || "").split(/[\n,]/).map(function (s) { return s.trim(); }).filter(Boolean);
    }
  };
});
