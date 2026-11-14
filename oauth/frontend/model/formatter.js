sap.ui.define([], function () {
  "use strict";

  var STATES = {
    active: "Success", inactive: "None", blocked: "Error", revoked: "Error", expired: "Warning", used: "Information"
  };

  var GRANTS = {
    authorization_code: "Authorization Code", client_credentials: "Client Credentials", refresh_token: "Refresh Token"
  };

  return {
    /** Lifecycle status → sap.ui.core.ValueState */
    statusState: function (status) {
      return STATES[status] || "None";
    },

    /** Status → icon for ObjectStatus */
    statusIcon: function (status) {
      switch (STATES[status]) {
        case "Success": return "sap-icon://sys-enter-2";
        case "Error": return "sap-icon://error";
        case "Warning": return "sap-icon://alert";
        case "Information": return "sap-icon://history";
        default: return "";
      }
    },

    /** camelCase / snake_case value → "Camel Case" */
    enumText: function (value) {
      if (!value) {
        return "";
      }
      if (GRANTS[value]) {
        return GRANTS[value];
      }
      var spaced = String(value).replace(/_/g, " ").replace(/([a-z0-9])([A-Z])/g, "$1 $2");
      return spaced.charAt(0).toUpperCase() + spaced.slice(1);
    },

    /** ["a", "b"] → "a, b" (grant types translated) */
    list: function (values) {
      if (!Array.isArray(values) || values.length === 0) {
        return "–";
      }
      return values.map(function (v) { return GRANTS[v] || v; }).join(", ");
    },

    /** Client type → icon */
    clientTypeIcon: function (type) {
      return type === "public" ? "sap-icon://iphone" : "sap-icon://locked";
    },

    /** A valid #RGB / #RRGGBB color or a neutral fallback for sap.ui.core.Icon */
    swatch: function (color) {
      return /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(color || "") ? color : "Neutral";
    },

    /** Seconds → "15 min", "1 h", "30 d" */
    duration: function (seconds) {
      var s = Number(seconds);
      if (!isFinite(s) || s <= 0) {
        return "–";
      }
      if (s % 86400 === 0) {
        return s / 86400 + " d";
      }
      if (s % 3600 === 0) {
        return s / 3600 + " h";
      }
      if (s % 60 === 0) {
        return s / 60 + " min";
      }
      return s + " s";
    },

    /** Long tokens are shortened for display: "eyJhbGciOi…X0.sig" */
    shortToken: function (token) {
      if (!token) {
        return "";
      }
      return token.length > 40 ? token.slice(0, 24) + "…" + token.slice(-8) : token;
    }
  };
});
