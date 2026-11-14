sap.ui.define([
  "sap/ui/core/library"
], function (coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  var GOOD = ["active", "subscribed", "ready", "enabled"];
  var BUSY = ["creating", "updating", "subscribing", "unsubscribing", "moveInProgress", "migrating", "pending", "deleting"];
  var BAD = ["error", "failed", "moveFailed", "terminated", "revoked", "deleted"];
  var WARN = ["suspended", "inactive", "expired", "deprecated", "unsubscribed"];

  return {
    /** Lifecycle status → ObjectStatus state. */
    statusState: function (sStatus) {
      if (GOOD.indexOf(sStatus) >= 0) { return ValueState.Success; }
      if (BAD.indexOf(sStatus) >= 0) { return ValueState.Error; }
      if (WARN.indexOf(sStatus) >= 0) { return ValueState.Warning; }
      if (BUSY.indexOf(sStatus) >= 0) { return ValueState.Information; }
      return ValueState.None;
    },

    /** Event severity → ObjectStatus state. */
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

    /** "cloudFoundry" → "Cloud Foundry", "subaccountLifecycle" → "Subaccount Lifecycle". */
    enumText: function (sValue) {
      if (!sValue) { return ""; }
      var s = String(sValue).replace(/_$/, "").replace(/([a-z0-9])([A-Z])/g, "$1 $2");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** ["a", "b"] → "a, b". */
    joinList: function (aValues) {
      return Array.isArray(aValues) ? aValues.join(", ") : "";
    },

    /** Quota "used / assigned" or "unlimited". */
    quota: function (iUsed, iAssigned, bUnlimited) {
      if (bUnlimited) { return "∞"; }
      return (iUsed || 0) + " / " + (iAssigned || 0);
    },

    /** Percentage of a quota used (0..100) for ProgressIndicator. */
    quotaPercent: function (iUsed, iAssigned, bUnlimited) {
      if (bUnlimited || !iAssigned) { return 0; }
      return Math.min(100, Math.round(((iUsed || 0) * 100) / iAssigned));
    },

    /** Usage "current / max" of a global account limit. */
    usage: function (iCurrent, iMax) {
      return (iCurrent || 0) + " / " + (iMax || 0);
    },

    /** True if the action is allowed in the given status. */
    canSuspend: function (sStatus) { return sStatus === "active"; },
    canReactivate: function (sStatus) { return sStatus === "suspended"; }
  };
});
