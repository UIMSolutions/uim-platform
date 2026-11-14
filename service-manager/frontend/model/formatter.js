sap.ui.define([], function () {
  "use strict";

  var STATES = {
    // instances / bindings
    created: "Success", creating: "Information", updating: "Information", deleting: "Warning",
    failed: "Error", orphaned: "Error",
    // operations
    succeeded: "Success", inProgress: "Information", pending: "Information",
    // brokers / platforms / offerings
    active: "Success", inactive: "None", suspended: "Warning", registrationFailed: "Error",
    available: "Success", deprecated: "Warning", removed: "Error"
  };

  return {
    /** Lifecycle status → sap.ui.core.ValueState */
    statusState: function (status) {
      return STATES[status] || "None";
    },

    /** Status → icon for ObjectStatus */
    statusIcon: function (status) {
      switch (STATES[status]) {
        case "Success": return "sap-icon://sys-enter-2";
        case "Error": return "sap-icon://error";
        case "Warning": return "sap-icon://alert";
        case "Information": return "sap-icon://synchronize";
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

    /** Pretty print a JSON text (falls back to the raw text). */
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

    /** Count → "n" or "–" */
    count: function (n) {
      return n === null || n === undefined ? "–" : String(n);
    }
  };
});
