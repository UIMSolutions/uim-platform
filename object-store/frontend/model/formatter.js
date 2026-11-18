sap.ui.define([], function () {
  "use strict";

  var SUCCESS = ["active", "enabled", "allow", "valid"];
  var ERROR = ["deleted", "revoked", "deny", "suspended"];
  var WARNING = ["archived", "expired", "disabled"];

  var UNITS = ["B", "KiB", "MiB", "GiB", "TiB", "PiB"];

  var formatter = {
    /** ValueState of a bucket / object / rule / binding status. */
    statusState: function (sStatus) {
      if (SUCCESS.indexOf(sStatus) >= 0) { return "Success"; }
      if (ERROR.indexOf(sStatus) >= 0) { return "Error"; }
      if (WARNING.indexOf(sStatus) >= 0) { return "Warning"; }
      return "None";
    },

    /** Icon of a status value. */
    statusIcon: function (sStatus) {
      switch (sStatus) {
        case "active": case "enabled": return "sap-icon://status-positive";
        case "suspended": case "revoked": case "deleted": return "sap-icon://status-negative";
        case "archived": return "sap-icon://inbox";
        case "expired": return "sap-icon://past";
        case "disabled": return "sap-icon://status-inactive";
        default: return "";
      }
    },

    /** "infrequentAccess" → "Infrequent Access", "sseKms" → "SSE KMS". */
    enumText: function (sValue) {
      if (!sValue) { return ""; }
      var s = String(sValue);
      var mFixed = { sseS3: "SSE-S3", sseKms: "SSE-KMS", sseC: "SSE-C", aws: "AWS", gcp: "Google Cloud",
        azure: "Azure", alibaba: "Alibaba Cloud", readOnly: "Read Only", readWrite: "Read / Write" };
      if (mFixed[s]) { return mFixed[s]; }
      s = s.replace(/([a-z])([A-Z])/g, "$1 $2");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** 1536 → "1.5 KiB" (Int64 values arrive as strings). */
    bytes: function (vBytes) {
      var n = Number(vBytes || 0);
      if (!isFinite(n) || n < 1024) { return (isFinite(n) ? n : 0) + " B"; }
      var i = 0;
      while (n >= 1024 && i < UNITS.length - 1) {
        n /= 1024;
        i++;
      }
      return n.toFixed(1) + " " + UNITS[i];
    },

    /** Quota text: 0 = unlimited. */
    quota: function (vBytes) {
      return Number(vBytes || 0) === 0 ? "∞" : formatter.bytes(vBytes);
    },

    /** Usage in percent of the quota (0 if unlimited). */
    usagePercent: function (vUsed, vQuota) {
      var q = Number(vQuota || 0);
      return q > 0 ? Math.min(100, Math.round(Number(vUsed || 0) * 100 / q)) : 0;
    },

    /** ValueState of a quota usage percentage. */
    usageState: function (vUsed, vQuota) {
      var p = formatter.usagePercent(vUsed, vQuota);
      if (p >= 90) { return "Error"; }
      if (p >= 75) { return "Warning"; }
      return "Success";
    },

    /** ["a", "b"] → "a, b"; key/value records → "k=v". */
    joinList: function (aValues) {
      if (!Array.isArray(aValues)) { return aValues || ""; }
      return aValues.map(function (v) {
        return v && typeof v === "object" ? (v.key !== undefined ? v.key + "=" + v.value : JSON.stringify(v)) : v;
      }).join(", ");
    },

    /** ISO timestamp → locale text ("" for null). */
    dateTime: function (sIso) {
      if (!sIso) { return ""; }
      var d = new Date(sIso);
      return isNaN(d.getTime()) ? sIso : d.toLocaleString();
    },

    /** Icon of an object key by its content type. */
    fileIcon: function (sContentType, bFolder) {
      if (bFolder) { return "sap-icon://folder-blank"; }
      var s = sContentType || "";
      if (s.indexOf("image/") === 0) { return "sap-icon://attachment-photo"; }
      if (s.indexOf("video/") === 0) { return "sap-icon://attachment-video"; }
      if (s.indexOf("audio/") === 0) { return "sap-icon://attachment-audio"; }
      if (s === "application/pdf") { return "sap-icon://pdf-attachment"; }
      if (s.indexOf("zip") >= 0 || s.indexOf("gzip") >= 0) { return "sap-icon://attachment-zip-file"; }
      if (s.indexOf("text/") === 0 || s.indexOf("json") >= 0 || s.indexOf("xml") >= 0) { return "sap-icon://attachment-text-file"; }
      return "sap-icon://document";
    },

    /** The last segment of a key or folder ("a/b/c.txt" → "c.txt", "a/b/" → "b/"). */
    leafName: function (sKey) {
      if (!sKey) { return ""; }
      var s = sKey.charAt(sKey.length - 1) === "/" ? sKey.slice(0, -1) : sKey;
      var i = s.lastIndexOf("/");
      return (i < 0 ? s : s.slice(i + 1)) + (s.length < sKey.length ? "/" : "");
    },

    /** Yes / No. */
    yesNo: function (b) {
      return b ? "✓" : "";
    }
  };

  return formatter;
});
