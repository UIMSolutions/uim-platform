sap.ui.define([], function () {
  "use strict";

  var RATING_STATES = { excellent: "Success", good: "Success", fair: "Warning", poor: "Error", critical: "Error" };
  var SEVERITY_STATES = { info: "Information", warning: "Warning", error: "Error", critical: "Error" };
  var SEVERITY_ICONS = { info: "sap-icon://message-information", warning: "sap-icon://message-warning",
    error: "sap-icon://message-error", critical: "sap-icon://alert" };
  var STATUS_STATES = { active: "Success", draft: "Information", inactive: "None", pending: "Warning",
    running: "Information", completed: "Success", failed: "Error", cancelled: "None",
    verified: "Success", corrected: "Success", partial: "Warning", invalid: "Error", unverifiable: "None" };
  var STATUS_ICONS = { pending: "sap-icon://pending", running: "sap-icon://process", completed: "sap-icon://sys-enter-2",
    failed: "sap-icon://error", cancelled: "sap-icon://cancel", active: "sap-icon://sys-enter-2",
    draft: "sap-icon://edit", inactive: "sap-icon://pause", verified: "sap-icon://shield",
    corrected: "sap-icon://wrench", partial: "sap-icon://warning", invalid: "sap-icon://error",
    unverifiable: "sap-icon://question-mark" };
  var DIMENSION_ICONS = { completeness: "sap-icon://complete", validity: "sap-icon://accept",
    uniqueness: "sap-icon://overlay", consistency: "sap-icon://chain-link", accuracy: "sap-icon://target-group" };

  var formatter = {
    /** Quality score (0 … 100) → value state: ≥ 80 Success, ≥ 60 Warning, else Error, none = None */
    scoreState: function (score) {
      if (score === null || score === undefined || score === "") {
        return "None";
      }
      var s = Number(score);
      return s >= 80 ? "Success" : s >= 60 ? "Warning" : "Error";
    },

    /** 81.849999 → "81.8" ("–" for no score) */
    score: function (score) {
      if (score === null || score === undefined || score === "" || !isFinite(Number(score))) {
        return "–";
      }
      return (Math.round(Number(score) * 10) / 10).toFixed(1);
    },

    /** ProgressIndicator percentValue (0 for no score) */
    percentValue: function (score) {
      var s = Number(score);
      return isFinite(s) ? Math.max(0, Math.min(100, s)) : 0;
    },

    /** ProgressIndicator displayValue "81.8 %" */
    percentText: function (score) {
      var text = formatter.score(score);
      return text === "–" ? text : text + " %";
    },

    ratingState: function (rating) {
      return RATING_STATES[rating] || "None";
    },

    severityState: function (severity) {
      return SEVERITY_STATES[severity] || "None";
    },

    severityIcon: function (severity) {
      return SEVERITY_ICONS[severity] || "";
    },

    statusState: function (status) {
      return STATUS_STATES[status] || "None";
    },

    statusIcon: function (status) {
      return STATUS_ICONS[status] || "";
    },

    dimensionIcon: function (dimension) {
      return DIMENSION_ICONS[dimension] || "";
    },

    /** "crossField" → "Cross Field", "referenceData" → "Reference Data", "EXACT" → "Exact" */
    enumText: function (value) {
      if (!value) {
        return "";
      }
      return String(value).replace(/([a-z])([A-Z])/g, "$1 $2").toLowerCase().split(/[-_ ]/).map(function (w) {
        return w.charAt(0).toUpperCase() + w.slice(1);
      }).join(" ");
    },

    /** Collection → "a, b, c" */
    list: function (values) {
      return (values || []).join(", ");
    },

    /** Candidates ["c1=100", "c2=93.5"] → "c1, c2 (93.5)" */
    candidates: function (values) {
      return (values || []).map(function (v, i) {
        var pos = v.lastIndexOf("=");
        return i === 0 || pos < 0 ? v.slice(0, pos < 0 ? v.length : pos) : v.slice(0, pos) + " (" + v.slice(pos + 1) + ")";
      }).join(", ");
    },

    /** Milliseconds → "350 ms" / "2.4 s" */
    millis: function (ms) {
      var n = Number(ms);
      if (!isFinite(n) || n <= 0) {
        return "–";
      }
      return n < 1000 ? n + " ms" : (Math.round(n / 100) / 10) + " s";
    },

    /** Truthy → "Yes" / "No" text key */
    yesNo: function (value) {
      return value ? "✓" : "";
    }
  };

  return formatter;
});
