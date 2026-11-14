sap.ui.define([], function () {
  "use strict";

  var GOOD = ["running", "active", "connected", "succeeded", "deployed"];
  var BUSY = ["starting", "stopping", "hibernating", "resuming", "deleting", "connecting", "building", "deploying"];
  var BAD = ["error", "failed"];
  var WARN = ["stopped", "hibernated", "inactive", "deprecated", "archived", "cancelled", "disconnected"];

  var formatter = {
    /** ValueState of any Application Studio status value. */
    statusState: function (sStatus) {
      if (GOOD.indexOf(sStatus) >= 0) { return "Success"; }
      if (BUSY.indexOf(sStatus) >= 0) { return "Information"; }
      if (BAD.indexOf(sStatus) >= 0) { return "Error"; }
      if (WARN.indexOf(sStatus) >= 0) { return "Warning"; }
      return "None";
    },

    /** Icon for states the reconciler is still driving (busy indicator in tables). */
    statusIcon: function (sStatus) {
      return BUSY.indexOf(sStatus) >= 0 ? "sap-icon://synchronize" : "";
    },

    /** "sapFioriElements" → "Sap Fiori Elements", "html5Repository" → "Html5 Repository". */
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

    /** Build history → "mta-1 build succeeded; mta-2 deploy deployed" (last 3 runs). */
    history: function (aRuns) {
      if (!Array.isArray(aRuns)) { return ""; }
      return aRuns.slice(-3).map(function (r) {
        return r.runId + " " + r.phase + " " + r.status;
      }).join("; ");
    },

    /** Hibernation delay: 0 → "never", 1 → "1 day", n → "n days". */
    days: function (iDays) {
      var n = parseInt(iDays, 10) || 0;
      return n === 0 ? "never" : n + (n === 1 ? " day" : " days");
    }
  };

  return formatter;
});
