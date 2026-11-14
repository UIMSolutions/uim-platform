sap.ui.define([], function () {
  "use strict";

  var STATUS_STATES = {
    open: "Information", reserved: "Information", forwarded: "Warning", inProgress: "Warning",
    completed: "Success", cancelled: "None", failed: "Error",
    active: "Success", inactive: "None", syncing: "Information", error: "Error",
    pending: "Information", expired: "None", available: "Success", uploaded: "Information", processing: "Information",
    deleted: "None"
  };
  var PRIORITY_STATES = { low: "None", medium: "Information", high: "Warning", veryHigh: "Error" };
  var OUTCOME_STATES = { approved: "Success", rejected: "Error", completed: "Success", cancelled: "None" };

  /** Bytes → "512 B", "1.5 KB", "10 MB" (Int64 may arrive as string) */
  function bytes(value) {
    var n = Number(value);
    if (value === null || value === undefined || value === "" || !isFinite(n)) {
      return "–";
    }
    if (n < 1024) {
      return n + " B";
    }
    if (n < 1024 * 1024) {
      return (Math.round(n / 102.4) / 10) + " KB";
    }
    return (Math.round(n / 104857.6) / 10) + " MB";
  }

  return {
    /** Task / provider / rule / attachment status → sap.ui.core.ValueState */
    statusState: function (status) {
      return STATUS_STATES[status] || "None";
    },

    priorityState: function (priority) {
      return PRIORITY_STATES[priority] || "None";
    },

    outcomeState: function (outcome) {
      return OUTCOME_STATES[outcome] || "None";
    },

    /** Status → icon for ObjectStatus */
    statusIcon: function (status) {
      switch (STATUS_STATES[status]) {
        case "Success": return "sap-icon://sys-enter-2";
        case "Error": return "sap-icon://error";
        case "Warning": return "sap-icon://pending";
        case "Information": return "sap-icon://inbox";
        default: return "";
      }
    },

    /** camelCase enum value → "Camel Case" */
    enumText: function (value) {
      if (!value) {
        return "";
      }
      var spaced = String(value).replace(/([a-z0-9])([A-Z])/g, "$1 $2");
      return spaced.charAt(0).toUpperCase() + spaced.slice(1);
    },

    /** true if the action is in availableActions (drives the detail buttons) */
    canDo: function (available, action) {
      return Array.isArray(available) && available.indexOf(action) >= 0;
    },

    /** Allowed actions (collection) → "approve, reject"; empty = all ("*") */
    actionList: function (actions) {
      return Array.isArray(actions) && actions.length ? actions.join(", ") : "*";
    },

    /** availableActions → {claim: true, …} for the detail buttons */
    actionFlags: function (available) {
      var flags = {};
      ["claim", "release", "forward", "approve", "reject", "complete", "cancel", "escalate", "resubmit"].forEach(function (a) {
        flags[a] = Array.isArray(available) && available.indexOf(a) >= 0;
      });
      return flags;
    },

    /** Due date → value state: overdue Error, today/tomorrow Warning */
    dueState: function (dueDate, isOverdue) {
      if (isOverdue) {
        return "Error";
      }
      if (!dueDate) {
        return "None";
      }
      var days = (new Date(dueDate + "T00:00:00Z") - new Date(new Date().toISOString().slice(0, 10) + "T00:00:00Z")) / 86400000;
      return days >= 0 && days <= 1 ? "Warning" : "None"; // past and not overdue = finished
    },

    /** "anna (for dora)" when a substitution forwarded the task */
    assigneeText: function (assignee, substitutedFor) {
      if (!assignee) {
        return "–";
      }
      return substitutedFor ? assignee + " (↪ " + substitutedFor + ")" : assignee;
    },

    bytes: bytes,

    /** Pretty print JSON text (custom attributes); invalid JSON as is */
    prettyJson: function (text) {
      if (!text) {
        return "";
      }
      try {
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch (e) {
        return text;
      }
    },

    /** OData $filter for the inbox: scope (mine/all) AND saved filter */
    inboxFilter: function (scope, user, savedFilter) {
      var terms = [];
      if (scope === "mine" && user) {
        terms.push("assignee eq '" + String(user).replace(/'/g, "''") + "'");
      }
      if (savedFilter) {
        terms.push("(" + savedFilter + ")");
      }
      return terms.join(" and ");
    }
  };
});
