sap.ui.define([], function () {
  "use strict";

  var STATUS_STATES = { succeeded: "Success", failed: "Error", ignored: "None", preview: "Information" };
  var DIRECTION_ICONS = { scaleOut: "sap-icon://trend-up", scaleIn: "sap-icon://trend-down", none: "sap-icon://less" };
  var DIRECTION_STATES = { scaleOut: "Information", scaleIn: "Warning", none: "None" };
  var TRIGGER_ICONS = { dynamic: "sap-icon://line-chart", schedule: "sap-icon://appointment-2", limits: "sap-icon://dimension",
    manual: "sap-icon://user-edit" };
  var METRIC_ICONS = { cpu: "sap-icon://it-host", cpuutil: "sap-icon://it-host", memoryused: "sap-icon://database",
    memoryutil: "sap-icon://database", disk: "sap-icon://it-system", diskutil: "sap-icon://it-system",
    throughput: "sap-icon://journey-arrive", responsetime: "sap-icon://fob-watch" };

  var bundle = null;

  return {
    /** Set by the Component for texts of enumerations outside views (tests may leave it empty). */
    setBundle: function (b) { bundle = b; },

    statusState: function (s) { return STATUS_STATES[s] || "None"; },
    directionIcon: function (d) { return DIRECTION_ICONS[d] || ""; },
    directionState: function (d) { return DIRECTION_STATES[d] || "None"; },
    triggerIcon: function (t) { return TRIGGER_ICONS[t] || ""; },
    metricIcon: function (m) { return METRIC_ICONS[m] || "sap-icon://measure"; },
    bindingState: function (status, autoscaled) {
      if (status === "suspended") {
        return "Warning";
      }
      return autoscaled === true || autoscaled === "true" ? "Success" : "None";
    },
    policyState: function (s) { return s === "active" ? "Success" : "None"; },

    /** Text of an enumeration value from i18n ("enum_<value>"), else the value. */
    enumText: function (value) {
      if (value === undefined || value === null || value === "") {
        return "";
      }
      var key = "enum_" + value;
      var text = this && this.getOwnerComponent ? this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(key)
        : bundle ? bundle.getText(key) : key;
      return text === key ? String(value) : text;
    },

    /** "3 → 5" */
    instanceChange: function (from, to) {
      return (from === undefined || from === null ? "" : from) + " → " + (to === undefined || to === null ? "" : to);
    },

    /** "+2" / "-1" / "0" */
    delta: function (d) {
      var n = Number(d) || 0;
      return n > 0 ? "+" + n : String(n);
    },

    /** "2..10" */
    limits: function (min, max) {
      var lo = Number(min) || 0;
      var hi = Number(max) || 0;
      return lo || hi ? lo + " … " + hi : "–";
    },

    /** "cpu >= 80" with unit */
    threshold: function (operator, threshold, unit) {
      return (operator || "") + " " + (threshold === undefined || threshold === null ? "" : threshold) + (unit ? " " + unit : "");
    },

    /** 120 → "2 min", 90 → "90 s", 3600 → "60 min" */
    seconds: function (s) {
      var n = Number(s) || 0;
      return n >= 120 && n % 60 === 0 ? n / 60 + " min" : n + " s";
    },

    /** Utilization bar colour: near the maximum → Error. */
    utilizationState: function (percent) {
      var p = Number(percent) || 0;
      return p >= 90 ? "Error" : p >= 70 ? "Warning" : "Success";
    },

    /** Edm.Double values may come as strings (IEEE754Compatible). */
    number: function (v) {
      if (v === undefined || v === null || v === "") {
        return "";
      }
      var n = Number(v);
      return isNaN(n) ? String(v) : String(Math.round(n * 100) / 100);
    },

    /** Schedule window: recurring "Mon–Fri 08:00–18:00", specific "2026-12-24T08:00 – …" */
    scheduleWindow: function (kind, daysText, startTime, endTime, startDateTime, endDateTime) {
      if (kind === "specificDate") {
        return (startDateTime || "").replace("T", " ") + " – " + (endDateTime || "").replace("T", " ");
      }
      return (daysText ? daysText + " " : "") + (startTime || "") + "–" + (endTime || "");
    },

    /** Visible only for the given scope flag and a value. */
    and: function (a, b) {
      return !!a && !!b;
    }
  };
});
