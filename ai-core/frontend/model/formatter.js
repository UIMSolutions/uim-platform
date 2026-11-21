sap.ui.define([], function () {
  "use strict";

  var STATES = {
    PENDING: "Warning", RUNNING: "Information", COMPLETED: "Success", DEAD: "Error", STOPPING: "Warning",
    STOPPED: "None", UNKNOWN: "None", PROVISIONING: "Warning", PROVISIONED: "Success", ERROR: "Error",
    ACTIVE: "Success", INACTIVE: "None"
  };

  var ICONS = {
    PENDING: "sap-icon://pending", RUNNING: "sap-icon://process", COMPLETED: "sap-icon://sys-enter-2",
    DEAD: "sap-icon://error", STOPPING: "sap-icon://stop", STOPPED: "sap-icon://stop", PROVISIONING: "sap-icon://pending",
    PROVISIONED: "sap-icon://sys-enter-2", ERROR: "sap-icon://error", ACTIVE: "sap-icon://appointment-2",
    INACTIVE: "sap-icon://pause"
  };

  var KINDS = {
    model: "sap-icon://machine", dataset: "sap-icon://database", resultset: "sap-icon://table-view",
    other: "sap-icon://document"
  };

  var formatter = {
    /** Lifecycle status → sap.ui.core.ValueState */
    statusState: function (status) {
      return STATES[status] || "None";
    },

    /** Lifecycle status → icon */
    statusIcon: function (status) {
      return ICONS[status] || "";
    },

    /** "RUNNING" → "Running", "CASCADE-UPDATE" → "Cascade Update" */
    enumText: function (value) {
      if (!value) {
        return "";
      }
      return String(value).toLowerCase().split(/[-_ ]/).map(function (w) {
        return w.charAt(0).toUpperCase() + w.slice(1);
      }).join(" ");
    },

    /** Artifact kind → icon */
    kindIcon: function (kind) {
      return KINDS[kind] || KINDS.other;
    },

    /** Executable type → icon */
    typeIcon: function (type) {
      return type === "serving" ? "sap-icon://cloud" : "sap-icon://process";
    },

    /** Seconds → "45 s", "3 min 20 s", "2 h 5 min", "1 d 4 h" */
    duration: function (seconds) {
      var s = Number(seconds);
      if (!isFinite(s) || s <= 0) {
        return "–";
      }
      var d = Math.floor(s / 86400), h = Math.floor((s % 86400) / 3600), m = Math.floor((s % 3600) / 60), r = s % 60;
      if (d > 0) {
        return d + " d" + (h ? " " + h + " h" : "");
      }
      if (h > 0) {
        return h + " h" + (m ? " " + m + " min" : "");
      }
      if (m > 0) {
        return m + " min" + (r ? " " + r + " s" : "");
      }
      return r + " s";
    },

    /** Time to live (seconds, 0 = unlimited) */
    ttl: function (seconds) {
      return Number(seconds) > 0 ? formatter.duration(seconds) : "∞";
    },

    /** ["a=1", "b=2"] → "a=1, b=2"; empty → "–" */
    list: function (values) {
      return Array.isArray(values) && values.length ? values.join(", ") : "–";
    },

    /** Metric values: 4 significant decimals */
    metric: function (value) {
      var v = Number(value);
      return isFinite(v) ? String(Math.round(v * 10000) / 10000) : "";
    },

    /** True for states in which a run can be stopped */
    canStop: function (status) {
      return status === "PENDING" || status === "RUNNING";
    },

    /** True for states in which a run can be deleted */
    canDelete: function (status) {
      return !!status && status !== "PENDING" && status !== "RUNNING" && status !== "STOPPING";
    },

    /** Deployments can be restarted when stopped / dead */
    canRestart: function (status) {
      return status === "STOPPED" || status === "DEAD" || status === "UNKNOWN";
    }
  };

  return formatter;
});
