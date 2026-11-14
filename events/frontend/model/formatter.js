sap.ui.define([], function () {
  "use strict";

  var STATES = {
    active: "Success", creating: "Information", updating: "Information", deleting: "Warning", failed: "Error",
    inactive: "None", suspended: "Warning", paused: "Warning", pendingDelete: "Warning", deprecated: "Warning",
    queued: "Information", deadLettered: "Error"
  };

  /** Bytes → "512 B", "1.5 KB", "10 MB" (Int64 may arrive as string) */
  function bytes(value) {
    var n = Number(value);
    if (value === null || value === undefined || !isFinite(n)) {
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

    /** Bytes → "512 B", "1.5 KB", "10 MB" (Int64 may arrive as string) */
    bytes: bytes,

    /** Optional limit: 0 / empty → "–" (the service quota applies) */
    optionalBytes: function (value) {
      return Number(value) > 0 ? bytes(value) : "–";
    },

    /** Message count / depth limit → ValueState (Warning ≥ 80 %, Error when full) */
    fillState: function (count, limit) {
      var max = Number(limit);
      if (!max) {
        return "None";
      }
      var ratio = Number(count) / max;
      return ratio >= 1 ? "Error" : ratio >= 0.8 ? "Warning" : "Success";
    },

    /** "Depth 1000 · Size 1 MB" */
    limits: function (depthLabel, depth, sizeLabel, size) {
      return depthLabel + " " + depth + " · " + sizeLabel + " " + bytes(size);
    },

    /** Queue or channel id of a binding */
    bindingTarget: function (queueId, channelId) {
      return queueId || channelId || "";
    },

    /** Count → "n" or "–" */
    count: function (n) {
      return n === null || n === undefined ? "–" : String(n);
    }
  };
});
