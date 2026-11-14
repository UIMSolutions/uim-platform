sap.ui.define([
  "sap/ui/core/library"
], function (coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  var SUCCESS = ["active", "published", "completed", "deployed"];
  var WARNING = ["draft", "pending", "inProgress", "deploying", "enrolled", "testing", "deprecated", "inactive", "suspended"];
  var ERROR = ["failed", "error", "withdrawn", "removed", "rolledBack"];

  /** Edm.Int64 arrives as number or (IEEE754Compatible) string — possibly grouped. */
  function toNumber(v) {
    if (typeof v === "number") {
      return v;
    }
    return Number(String(v || "0").replace(/[^0-9.\-]/g, "")) || 0;
  }

  var PLATFORMS = { ios: "iOS", android: "Android", windows: "Windows", web: "Web", cross: "Cross-Platform" };

  var formatter = {
    /** Any lifecycle status → semantic value state. */
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

    /** camelCase enum member → "Camel Case" (s4hana → S4hana). */
    enumText: function (sValue) {
      if (!sValue) {
        return "";
      }
      var s = String(sValue).replace(/([a-z])([A-Z])/g, "$1 $2");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** Platform → display name. */
    platformText: function (sPlatform) {
      return PLATFORMS[sPlatform] || formatter.enumText(sPlatform);
    },

    /** Platform → SAP icon. */
    platformIcon: function (sPlatform) {
      switch (sPlatform) {
        case "ios":
        case "android":
          return "sap-icon://iphone";
        case "windows":
          return "sap-icon://laptop";
        case "web":
          return "sap-icon://world";
        default:
          return "sap-icon://multiple-pie-chart";
      }
    },

    /** Byte count (Edm.Int64, may arrive as string) → "1.5 MiB". */
    bytes: function (vBytes) {
      var n = toNumber(vBytes);
      var aUnits = ["B", "KiB", "MiB", "GiB", "TiB"];
      var i = 0;
      while (n >= 1024 && i < aUnits.length - 1) {
        n /= 1024;
        i++;
      }
      return (i === 0 ? n : n.toFixed(1)) + " " + aUnits[i];
    },

    /** Sum of two Edm.Int64 values. */
    sum: function (a, b) {
      return toNumber(a) + toNumber(b);
    },

    /** Sum of two byte counts → "1.5 MiB". */
    bytesSum: function (a, b) {
      return formatter.bytes(formatter.sum(a, b));
    },

    /** "succeeded / total" progress of a deployment in percent. */
    deploymentPercent: function (iSucceeded, iFailed, iTotal) {
      var total = Number(iTotal) || 0;
      if (!total) {
        return 0;
      }
      return Math.round(((Number(iSucceeded) || 0) + (Number(iFailed) || 0)) * 100 / total);
    },

    /** Deployment target: device id or group name depending on scope. */
    deploymentTarget: function (sScope, sDevice, sGroup) {
      if (sScope === "device") {
        return sDevice || "";
      }
      if (sScope === "group") {
        return sGroup || "";
      }
      return "—";
    },

    /** Validation flag → icon. */
    validIcon: function (bValid) {
      return bValid ? "sap-icon://accept" : "sap-icon://alert";
    }
  };

  return formatter;
});
