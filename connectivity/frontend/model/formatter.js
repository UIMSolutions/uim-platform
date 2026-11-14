sap.ui.define([], function () {
  "use strict";

  var GOOD = ["reachable", "connected", "open", "valid", "allow", "info"];
  var BAD = ["unreachable", "misconfigured", "error", "expired", "revoked", "deny", "critical"];
  var WARN = ["disconnected", "maintenance", "expiring", "closed", "warning"];
  var NEUTRAL = ["unchecked"];

  var formatter = {
    /** ValueState of any connectivity status, policy or severity value. */
    statusState: function (sStatus) {
      if (GOOD.indexOf(sStatus) >= 0) { return "Success"; }
      if (BAD.indexOf(sStatus) >= 0) { return "Error"; }
      if (WARN.indexOf(sStatus) >= 0) { return "Warning"; }
      if (NEUTRAL.indexOf(sStatus) >= 0) { return "Information"; }
      return "None";
    },

    /** Icon of a status value. */
    statusIcon: function (sStatus) {
      switch (sStatus) {
        case "reachable": case "connected": case "open": case "valid": return "sap-icon://status-positive";
        case "unreachable": case "error": case "expired": case "revoked": case "critical": return "sap-icon://status-negative";
        case "misconfigured": case "expiring": case "warning": return "sap-icon://status-critical";
        case "maintenance": return "sap-icon://wrench";
        default: return "";
      }
    },

    /** "onPremise" → "On Premise", "oauth2ClientCredentials" → "Oauth2 Client Credentials". */
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

    /** "erp.virtual", 443 → "erp.virtual:443". */
    hostPort: function (sHost, iPort) {
      if (!sHost) { return ""; }
      return iPort ? sHost + ":" + iPort : sHost;
    },

    /** Access rule resource: "https://erp.virtual:443/sap/opu (+ sub-paths)". */
    resource: function (sProtocol, sHost, iPort, sPath, bSub) {
      if (!sHost) { return ""; }
      var bPaths = sProtocol === "http" || sProtocol === "https";
      return sProtocol + "://" + sHost + ":" + iPort + (bPaths ? (sPath || "/") + (bSub ? " (+ sub-paths)" : "") : "");
    },

    /** Latency in ms; empty for unchecked destinations. */
    latency: function (iMs) {
      return iMs ? iMs + " ms" : "";
    }
  };

  return formatter;
});
