sap.ui.define([], function () {
  "use strict";

  var GOOD = ["running", "ready", "ok", "active", "enabled", "connected"];
  var BUSY = ["provisioning", "updating", "building", "deploying", "creating", "pending",
    "installing", "uninstalling", "pairing", "stopping", "notReady", "terminating"];
  var BAD = ["error", "failed"];

  var formatter = {
    /** ValueState of any Kyma status value. */
    statusState: function (sStatus) {
      if (GOOD.indexOf(sStatus) >= 0) { return "Success"; }
      if (BUSY.indexOf(sStatus) >= 0) { return "Information"; }
      if (BAD.indexOf(sStatus) >= 0) { return "Error"; }
      if (sStatus === "paused" || sStatus === "stopped" || sStatus === "disabled" || sStatus === "disconnected") {
        return "Warning";
      }
      return "None";
    },

    /** Icon for transitional states (busy indicator in tables). */
    statusIcon: function (sStatus) {
      return BUSY.indexOf(sStatus) >= 0 ? "sap-icon://synchronize" : "";
    },

    /** "notReady" → "Not Ready", "apiAndEvents" → "Api And Events", "sapConvergedCloud" → "Sap Converged Cloud". */
    enumText: function (sValue) {
      if (!sValue) { return ""; }
      var s = String(sValue).replace(/([a-z0-9])([A-Z])/g, "$1 $2").replace(/[-_]/g, " ");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** ["a","b"] → "a, b". */
    joinList: function (aValues) {
      return Array.isArray(aValues) ? aValues.join(", ") : "";
    },

    /** [{key, value}] → "key=value, …". */
    keyValues: function (aPairs) {
      if (!Array.isArray(aPairs)) { return ""; }
      return aPairs.map(function (p) { return p.key + "=" + p.value; }).join(", ");
    },

    /** API rule entries → "GET,POST /orders (jwt)". */
    accessRules: function (aRules) {
      if (!Array.isArray(aRules)) { return ""; }
      return aRules.map(function (r) {
        return (r.methods || []).join(",") + " " + r.path + " (" + r.accessStrategy + ")";
      }).join("; ");
    },

    /** "https://" + host */
    hostUrl: function (sHost) {
      return sHost ? "https://" + sHost : "";
    },

    /** Count of a collection. */
    count: function (aValues) {
      return Array.isArray(aValues) ? aValues.length : 0;
    }
  };

  return formatter;
});
