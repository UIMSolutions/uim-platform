sap.ui.define([], function () {
  "use strict";

  var SUCCESS = ["active", "completed", "success"];
  var ERROR = ["error", "failed"];
  var WARNING = ["running", "configuring", "pending"];
  var INFORMATION = ["scheduled", "simulated", "create", "update"];

  var formatter = {
    /** ValueState of a system, job, entity or log status. */
    statusState: function (sStatus) {
      if (SUCCESS.indexOf(sStatus) >= 0) { return "Success"; }
      if (ERROR.indexOf(sStatus) >= 0) { return "Error"; }
      if (WARNING.indexOf(sStatus) >= 0) { return "Warning"; }
      if (INFORMATION.indexOf(sStatus) >= 0) { return "Information"; }
      return "None";
    },

    /** Icon of a status value. */
    statusIcon: function (sStatus) {
      switch (sStatus) {
        case "active": case "completed": case "success": return "sap-icon://status-positive";
        case "error": case "failed": return "sap-icon://status-negative";
        case "configuring": return "sap-icon://wrench";
        case "running": return "sap-icon://synchronize";
        case "scheduled": return "sap-icon://appointment-2";
        case "inactive": return "sap-icon://status-inactive";
        case "cancelled": return "sap-icon://cancel";
        case "skipped": return "sap-icon://media-forward";
        case "simulated": return "sap-icon://lab";
        default: return "";
      }
    },

    /** Icon of an operation. */
    operationIcon: function (sOperation) {
      switch (sOperation) {
        case "create": return "sap-icon://add";
        case "update": return "sap-icon://edit";
        case "delete": return "sap-icon://delete";
        default: return "sap-icon://media-forward";
      }
    },

    /** "oauth2ClientCredentials" → "OAuth2 Client Credentials", "successFactors" → "Success Factors". */
    enumText: function (sValue) {
      if (!sValue) { return ""; }
      var s = String(sValue).replace(/([a-z0-9])([A-Z])/g, "$1 $2").replace(/[-_]/g, " ");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** 0 → "On demand", 60 → "Every 60 min". */
    interval: function (iMinutes) {
      var n = Number(iMinutes) || 0;
      return n > 0 ? "Every " + n + " min" : "On demand";
    },

    /** [{sourcePath, targetPath, function, mandatory}] → "email→emails[0].value*, …". */
    mappings: function (aMappings) {
      if (!Array.isArray(aMappings) || !aMappings.length) { return "pass-through"; }
      return aMappings.map(function (m) {
        var sSource = m.sourcePath || "'" + (m.defaultValue || "") + "'";
        return sSource + " → " + m.targetPath + (m.mandatory ? "*" : "");
      }).join(", ");
    },

    /** [{attribute, operator, value}] → "department notEquals HR". */
    conditions: function (aConditions) {
      if (!Array.isArray(aConditions) || !aConditions.length) { return ""; }
      return aConditions.map(function (c) {
        return [c.attribute, c.operator, c.value].filter(Boolean).join(" ");
      }).join(" and ");
    },

    /** [{key, value}] → "k=v, k2=v2". */
    keyValues: function (aItems) {
      if (!Array.isArray(aItems)) { return ""; }
      return aItems.map(function (a) { return a.key + "=" + a.value; }).join(", ");
    },

    /** "k=v" lines → [{key, value}] (blank lines ignored). */
    parseKeyValues: function (sText) {
      return String(sText || "").split(/\r?\n|,(?=[^=,]+=)/).map(function (s) { return s.trim(); })
        .filter(Boolean).map(function (s) {
          var i = s.indexOf("=");
          return i < 0 ? { key: s, value: "" } : { key: s.slice(0, i).trim(), value: s.slice(i + 1).trim() };
        });
    },

    /** [{key, value}] → "k=v" lines. */
    keyValueLines: function (aItems) {
      return Array.isArray(aItems) ? aItems.map(function (a) { return a.key + "=" + a.value; }).join("\n") : "";
    },

    /** "yes" / "no". */
    yesNo: function (bValue) {
      return bValue ? "✓" : "—";
    },

    /** True if the system can be activated. */
    canActivate: function (sStatus) {
      return !!sStatus && sStatus !== "active";
    },

    /** True if a job can be run. */
    isRunnable: function (sStatus) {
      return !!sStatus && sStatus !== "running" && sStatus !== "cancelled";
    },

    isCancelled: function (sStatus) {
      return sStatus === "cancelled";
    },

    isNotCancelled: function (sStatus) {
      return !!sStatus && sStatus !== "cancelled";
    },

    /** Number for ObjectNumber (null → 0). */
    count: function (iValue) {
      return iValue ? Number(iValue) : 0;
    }
  };

  return formatter;
});
