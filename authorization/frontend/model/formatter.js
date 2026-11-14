sap.ui.define([
  "sap/ui/core/library"
], function (coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  return {
    /** active → Success, disabled → Warning. */
    statusState: function (sStatus) {
      switch (sStatus) {
        case "active": return ValueState.Success;
        case "disabled": return ValueState.Warning;
        default: return ValueState.None;
      }
    },

    /** base → Information, custom → None. */
    kindState: function (sKind) {
      return sKind === "base" ? ValueState.Information : ValueState.None;
    },

    /** Decision outcome. */
    allowedState: function (bAllowed) {
      if (bAllowed === true) { return ValueState.Success; }
      if (bAllowed === false) { return ValueState.Error; }
      return ValueState.None;
    },

    allowedText: function (bAllowed) {
      if (bAllowed === true) { return "Permit"; }
      if (bAllowed === false) { return "Deny"; }
      return "";
    },

    allowedIcon: function (bAllowed) {
      return bAllowed ? "sap-icon://accept" : "sap-icon://decline";
    },

    principalIcon: function (sType) {
      return sType === "group" ? "sap-icon://group" : "sap-icon://employee";
    },

    /** "camelCase" → "Camel Case" (enum values). */
    enumText: function (sValue) {
      if (!sValue) { return ""; }
      var s = String(sValue).replace(/_$/, "").replace(/([a-z0-9])([A-Z])/g, "$1 $2");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** ["Read", "Write"] → "Read, Write". */
    joinList: function (aValues) {
      return Array.isArray(aValues) ? aValues.join(", ") : "";
    },

    /** Conditions text or a dash. */
    conditionsText: function (sConditions) {
      return sConditions ? sConditions : "—";
    },

    canEnable: function (sStatus) {
      return sStatus === "disabled";
    },

    canDisable: function (sStatus) {
      return sStatus === "active";
    }
  };
});
