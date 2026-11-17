sap.ui.define([
  "sap/ui/core/format/DateFormat",
  "sap/ui/core/library"
], function (DateFormat, coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;
  var oDateTime = DateFormat.getDateTimeInstance({ style: "medium" });
  var rIso = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/;

  var POSITIVE = ["active", "published", "connected", "completed", "read", "open", "scheduled", "ongoing"];
  var CRITICAL = ["draft", "review", "inProgress", "maintenance", "suspended", "inactive", "unread", "actionRequired"];
  var NEGATIVE = ["error", "overdue", "cancelled", "deprecated", "disconnected", "dismissed"];

  var formatter = {
    /** "inProgress" → "In Progress", "sap_horizon_dark" → "Sap Horizon Dark". */
    enumText: function (sValue) {
      if (!sValue || typeof sValue !== "string") {
        return sValue || "";
      }
      return sValue.replace(/_/g, " ").replace(/([a-z0-9])([A-Z])/g, "$1 $2").replace(/^./, function (c) {
        return c.toUpperCase();
      });
    },

    /** Value state of a status value (ObjectStatus). */
    statusState: function (sStatus) {
      if (POSITIVE.indexOf(sStatus) >= 0) {
        return ValueState.Success;
      }
      if (CRITICAL.indexOf(sStatus) >= 0) {
        return ValueState.Warning;
      }
      if (NEGATIVE.indexOf(sStatus) >= 0) {
        return ValueState.Error;
      }
      return ValueState.None;
    },

    /** Display text of any payload value: lists, members, key/values, booleans, timestamps. */
    cellText: function (vValue) {
      if (vValue === null || vValue === undefined) {
        return "";
      }
      if (Array.isArray(vValue)) {
        return vValue.map(function (v) {
          if (v && typeof v === "object") {
            if (v.key !== undefined) {
              return v.key + "=" + (v.value || "");
            }
            if (v.userId !== undefined) {
              return (v.displayName || v.userId) + (v.role ? " (" + v.role + ")" : "");
            }
            return v.name || v.title || v.text || v.sectionId || JSON.stringify(v);
          }
          return String(v);
        }).join(", ");
      }
      if (typeof vValue === "boolean") {
        return vValue ? "✓" : "–";
      }
      if (typeof vValue === "string" && rIso.test(vValue)) {
        return oDateTime.format(new Date(vValue));
      }
      return String(vValue);
    },

    /** Number of entries of a collection value. */
    count: function (aValue) {
      return Array.isArray(aValue) ? aValue.length : 0;
    },

    /** True for status-like payload fields that get an ObjectStatus cell. */
    isStatusField: function (sField) {
      return sField === "status";
    }
  };

  return formatter;
});
