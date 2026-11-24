sap.ui.define([], function () {
  "use strict";

  var LIFECYCLE_STATES = { active: "Success", blocked: "Warning", archived: "Information", markedForDeletion: "Error", deleted: "None" };
  var LIFECYCLE_ICONS = { active: "sap-icon://employee", blocked: "sap-icon://locked", archived: "sap-icon://attachment-zip-file",
    markedForDeletion: "sap-icon://delete", deleted: "sap-icon://decline" };
  var PHASE_STATES = { noRule: "None", withinResidence: "Success", withinRetention: "Warning", endOfRetention: "Error" };
  var PHASE_ICONS = { noRule: "sap-icon://question-mark", withinResidence: "sap-icon://appointment-2",
    withinRetention: "sap-icon://lateness", endOfRetention: "sap-icon://alarm" };
  var STATUS_STATES = { pending: "Warning", completed: "Success", rejected: "Error", failed: "Error", cancelled: "None",
    scheduled: "Information", running: "Information", active: "Success", inactive: "None", deprecated: "Warning" };
  var STATUS_ICONS = { pending: "sap-icon://pending", completed: "sap-icon://sys-enter-2", rejected: "sap-icon://decline",
    failed: "sap-icon://error", cancelled: "sap-icon://cancel", scheduled: "sap-icon://appointment-2",
    running: "sap-icon://process", active: "sap-icon://sys-enter-2", inactive: "sap-icon://pause",
    deprecated: "sap-icon://warning" };

  var formatter = {
    lifecycleState: function (status) {
      return LIFECYCLE_STATES[status] || "None";
    },

    lifecycleIcon: function (status) {
      return LIFECYCLE_ICONS[status] || "";
    },

    phaseState: function (phase) {
      return PHASE_STATES[phase] || "None";
    },

    phaseIcon: function (phase) {
      return PHASE_ICONS[phase] || "";
    },

    statusState: function (status) {
      return STATUS_STATES[status] || "None";
    },

    statusIcon: function (status) {
      return STATUS_ICONS[status] || "";
    },

    /** "markedForDeletion" → "Marked For Deletion", "archiveAndDestruct" → "Archive And Destruct" */
    enumText: function (value) {
      if (!value) {
        return "";
      }
      return String(value).replace(/([a-z])([A-Z])/g, "$1 $2").toLowerCase().split(/[-_ ]/).map(function (w) {
        return w.charAt(0).toUpperCase() + w.slice(1);
      }).join(" ");
    },

    /** Days to the end of retention: 120 → "in 120 days", -3 → "3 days ago", 0 → "today", none → "" */
    days: function (days) {
      if (days === null || days === undefined || days === "" || !isFinite(Number(days))) {
        return "";
      }
      var n = Math.round(Number(days));
      if (n === 0) {
        return "today";
      }
      return n > 0 ? "in " + n + (n === 1 ? " day" : " days") : -n + (n === -1 ? " day ago" : " days ago");
    },

    /** Value state of the days until the end of retention: past Error, ≤ 90 days Warning. */
    daysState: function (days) {
      if (days === null || days === undefined || days === "") {
        return "None";
      }
      var n = Number(days);
      return n <= 0 ? "Error" : n <= 90 ? "Warning" : "None";
    },

    /** Collection → "a, b, c" */
    list: function (values) {
      return (values || []).join(", ");
    },

    /** Truthy → check mark */
    yesNo: function (value) {
      return value ? "✓" : "";
    },

    /** The text of a period: 10, "years" → "10 years"; 1, "months" → "1 month" */
    period: function (duration, unit) {
      if (duration === null || duration === undefined || !unit) {
        return "";
      }
      var n = Number(duration);
      return n + " " + (n === 1 ? String(unit).replace(/s$/, "") : unit);
    }
  };

  return formatter;
});
