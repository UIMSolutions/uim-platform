sap.ui.define([
  "sap/ui/core/library"
], function (coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  var SUCCESS = ["active", "low"];
  var WARNING = ["pendingVerification", "inactive", "expired", "medium"];
  var ERROR = ["locked", "revoked", "high", "critical"];

  var formatter = {
    /** User / session / token state or risk level → semantic value state. */
    statusState: function (sStatus) {
      if (SUCCESS.indexOf(sStatus) >= 0) {
        return ValueState.Success;
      }
      if (WARNING.indexOf(sStatus) >= 0) {
        return ValueState.Warning;
      }
      if (ERROR.indexOf(sStatus) >= 0) {
        return ValueState.Error;
      }
      return ValueState.None;
    },

    /** camelCase enum member → "Camel Case" (pendingVerification → Pending Verification). */
    enumText: function (sValue) {
      if (!sValue) {
        return "";
      }
      var s = String(sValue).replace(/([a-z])([A-Z])/g, "$1 $2").replace(/_/g, " ");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** Second factor: "none" → "", others upper case (TOTP, SMS, EMAIL). */
    mfaText: function (sMfa) {
      return !sMfa || sMfa === "none" ? "" : String(sMfa).toUpperCase();
    },

    mfaIcon: function (sMfa) {
      return !sMfa || sMfa === "none" ? "" : "sap-icon://shield";
    },

    /** "a:in:b; c:eq:d" → one rule per line. */
    rulesText: function (sRules) {
      return (sRules || "").split(";").map(function (s) { return s.trim(); }).filter(Boolean).join("\n");
    },

    /** Count of a space / comma separated list. */
    listCount: function (sList) {
      return (sList || "").split(/[\s,]+/).filter(Boolean).length;
    },

    /** Failed login attempts: highlight > 0. */
    failedState: function (iFailed) {
      return iFailed > 0 ? ValueState.Warning : ValueState.None;
    },

    /** Coverage percentage → state (≥ 80 good, ≥ 50 critical, else error). */
    coverageColor: function (iPercent) {
      if (iPercent >= 80) {
        return "Good";
      }
      return iPercent >= 50 ? "Critical" : "Error";
    }
  };

  return formatter;
});
