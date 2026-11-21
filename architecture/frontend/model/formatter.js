sap.ui.define([], function () {
  "use strict";

  var STATES = {
    proposed: "None", approved: "Information", inDevelopment: "Information", active: "Success",
    deprecated: "Warning", retired: "Error"
  };

  var STATUS_ICONS = {
    proposed: "sap-icon://lightbulb", approved: "sap-icon://approvals", inDevelopment: "sap-icon://wrench",
    active: "sap-icon://sys-enter-2", deprecated: "sap-icon://warning", retired: "sap-icon://past"
  };

  var KIND_ICONS = {
    architecture: "sap-icon://overview-chart", solution: "sap-icon://puzzle", data: "sap-icon://database",
    business: "sap-icon://org-chart", technology: "sap-icon://it-host"
  };

  /** Allowed lifecycle transitions (mirror of domain.services.lifecycle). */
  var NEXT = {
    proposed: ["approved", "retired"],
    approved: ["proposed", "inDevelopment", "active", "retired"],
    inDevelopment: ["approved", "active", "retired"],
    active: ["deprecated"],
    deprecated: ["active", "retired"],
    retired: []
  };

  var formatter = {
    statusState: function (status) {
      return STATES[status] || "None";
    },

    statusIcon: function (status) {
      return STATUS_ICONS[status] || "";
    },

    kindIcon: function (kind) {
      return KIND_ICONS[kind] || "sap-icon://product";
    },

    /** Lifecycle states reachable from a state. */
    nextStatuses: function (status) {
      return (NEXT[status] || []).slice();
    },

    /** Deleting is allowed unless the block is (still) in use. */
    deletable: function (status) {
      return status !== "active" && status !== "deprecated";
    },

    /** "inDevelopment" → "In Development", "implementationAndMigration" → "Implementation And Migration" */
    camelText: function (value) {
      if (!value) {
        return "";
      }
      var spaced = String(value).replace(/([a-z0-9])([A-Z])/g, "$1 $2");
      return spaced.charAt(0).toUpperCase() + spaced.slice(1);
    },

    /** ABB coverage → value state */
    coverageState: function (percent) {
      var p = Number(percent);
      if (isNaN(p)) {
        return "None";
      }
      return p >= 90 ? "Success" : p >= 60 ? "Warning" : "Error";
    },

    /** Count → "Error"/"Warning" if > 0, else "Success" */
    riskState: function (count, severity) {
      return Number(count) > 0 ? (severity || "Warning") : "Success";
    },

    /** ["a", "b"] → "a, b" */
    joinList: function (list) {
      return (list || []).join(", ");
    },

    /** "2026-11-21T10:00:00Z" → locale date and time */
    dateTime: function (iso) {
      if (!iso) {
        return "";
      }
      var d = new Date(iso);
      return isNaN(d.getTime()) ? iso : d.toLocaleString();
    },

    /** Relationship as a sentence: "Order Service serving Order to Cash" */
    relationshipText: function (sourceName, type, targetName) {
      return [sourceName, type, targetName].filter(Boolean).join(" → ");
    }
  };

  return formatter;
});
