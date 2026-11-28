sap.ui.define([
  "sap/ui/core/format/DateFormat",
  "sap/ui/core/format/NumberFormat"
], function (DateFormat, NumberFormat) {
  "use strict";

  var dateTime = DateFormat.getDateTimeInstance({ style: "medium" });
  var relative = DateFormat.getDateTimeInstance({ relative: true, relativeScale: "auto" });
  var integer = NumberFormat.getIntegerInstance({ groupingEnabled: true });
  var decimal = NumberFormat.getFloatInstance({ maxFractionDigits: 2, groupingEnabled: true });

  var STATES = {
    // connections
    active: "Success", pending: "Information", error: "Error", inactive: "None",
    // resource groups, artifacts
    ready: "Success", disabled: "Warning", available: "Success", archived: "None",
    // executions and deployments
    running: "Information", completed: "Success", failed: "Error", stopped: "Warning", dead: "Error",
    // prompts
    draft: "None",
    // log severities
    info: "Information", warning: "Warning"
  };

  var ICONS = {
    active: "sap-icon://status-positive", running: "sap-icon://synchronize", completed: "sap-icon://status-completed",
    failed: "sap-icon://status-error", dead: "sap-icon://status-error", error: "sap-icon://status-error",
    stopped: "sap-icon://stop", pending: "sap-icon://pending", warning: "sap-icon://message-warning",
    info: "sap-icon://message-information", ready: "sap-icon://status-positive", disabled: "sap-icon://locked"
  };

  return {
    /** Status value → sap.ui.core.ValueState */
    state: function (value) {
      return STATES[value] || "None";
    },

    stateIcon: function (value) {
      return ICONS[value] || "";
    },

    /** Status value → translated text ("enum_running"), the value itself if unknown. */
    enumText: function (value) {
      if (value === undefined || value === null || value === "") {
        return "";
      }
      var bundle = this && this.getOwnerComponent ? this.getOwnerComponent().getModel("i18n").getResourceBundle() : null;
      var key = "enum_" + value;
      if (bundle && bundle.hasText && bundle.hasText(key)) {
        return bundle.getText(key);
      }
      return String(value);
    },

    dateTime: function (value) {
      if (!value) {
        return "";
      }
      var d = new Date(value);
      return isNaN(d.getTime()) ? "" : dateTime.format(d);
    },

    relativeTime: function (value) {
      if (!value) {
        return "";
      }
      var d = new Date(value);
      return isNaN(d.getTime()) ? "" : relative.format(d);
    },

    count: function (value) {
      return value === undefined || value === null ? "" : integer.format(value);
    },

    decimal: function (value) {
      return value === undefined || value === null ? "" : decimal.format(value);
    },

    /** Seconds → "1 h 2 min", "45 s" */
    duration: function (seconds) {
      if (seconds === undefined || seconds === null || seconds === "") {
        return "";
      }
      var s = Math.max(0, Math.round(Number(seconds)));
      if (s < 60) {
        return s + " s";
      }
      var m = Math.floor(s / 60);
      if (m < 60) {
        return m + " min " + (s % 60) + " s";
      }
      return Math.floor(m / 60) + " h " + (m % 60) + " min";
    },

    /** KPI value of a tile: "" when the tile shows none. */
    kpi: function (value) {
      return value === undefined || value === null ? "" : String(value);
    },

    /** NumericContent colour of a KPI: errors and warnings stand out. */
    kpiColor: function (kpi, value) {
      if (!value) {
        return "Neutral";
      }
      return kpi === "warningsLast24h" || kpi === "failedExecutions" || kpi === "lockedUsers" ? "Critical" : "Neutral";
    },

    /** Executions and deployments that can still be stopped. */
    isActive: function (status) {
      return status === "pending" || status === "running";
    },

    /** The tile is an external link. */
    isUrl: function (targetType) {
      return targetType === "url";
    },

    /** "a, b" → ["a", "b"] (MultiComboBox selectedKeys from a form text) */
    splitList: function (text) {
      if (Array.isArray(text)) {
        return text;
      }
      return String(text || "").split(/[\n,;]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** ["a", "b"] → "a, b" */
    join: function (values) {
      return Array.isArray(values) ? values.join(", ") : (values || "");
    },

    /** Pretty print a JSON text (log details); the text itself if it is no JSON. */
    prettyJson: function (text) {
      if (!text) {
        return "";
      }
      try {
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch (e) {
        return String(text);
      }
    }
  };
});
