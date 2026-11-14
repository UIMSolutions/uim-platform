sap.ui.define([
  "sap/ui/core/library"
], function (coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  var formatter = {
    /** Severity → semantic value state. */
    severityState: function (sSeverity) {
      switch (sSeverity) {
        case "critical":
        case "error":
          return ValueState.Error;
        case "warning":
          return ValueState.Warning;
        case "info":
          return ValueState.Information;
        default:
          return ValueState.None;
      }
    },

    /** Outcome (success / failure / denied / error) → value state. */
    outcomeState: function (sOutcome) {
      switch (sOutcome) {
        case "success":
          return ValueState.Success;
        case "failure":
        case "error":
          return ValueState.Error;
        case "denied":
          return ValueState.Warning;
        default:
          return ValueState.None;
      }
    },

    /** Generic status (active / completed / enabled …) → value state. */
    statusState: function (sStatus) {
      switch (sStatus) {
        case "active":
        case "enabled":
        case "completed":
          return ValueState.Success;
        case "pending":
        case "inProgress":
        case "inactive":
          return ValueState.Warning;
        case "failed":
        case "expired":
        case "disabled":
          return ValueState.Error;
        default:
          return ValueState.None;
      }
    },

    /** Risk level (low / medium / high) → value state. */
    riskState: function (sRisk) {
      switch ((sRisk || "").toLowerCase()) {
        case "high":
          return ValueState.Error;
        case "medium":
          return ValueState.Warning;
        case "low":
          return ValueState.Success;
        default:
          return ValueState.None;
      }
    },

    /** camelCase enum member → "Camel Case". */
    enumText: function (sValue) {
      if (!sValue) {
        return "";
      }
      var s = String(sValue).replace(/([a-z])([A-Z])/g, "$1 $2");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** Collection(Edm.String) → "a, b". */
    joinList: function (aValues) {
      return Array.isArray(aValues) ? aValues.join(", ") : (aValues || "");
    },

    /** Collection(AuditAttribute) → "name: old → new; …". */
    attributes: function (aAttributes) {
      if (!Array.isArray(aAttributes)) {
        return "";
      }
      return aAttributes.map(function (a) {
        return a.name + ": " + (a.oldValue || "∅") + " → " + (a.newValue || "∅");
      }).join("; ");
    },

    /** user name, falling back to the id. */
    userText: function (sName, sId) {
      return sName || sId || "";
    },

    /** "/api/v1/exports/<id>/download" is relative to the backend root, keep it relative to the app. */
    downloadHref: function (sUrl) {
      return sUrl ? sUrl.replace(/^\//, "") : "";
    }
  };

  return formatter;
});
