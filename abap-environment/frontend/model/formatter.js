sap.ui.define([], function () {
  "use strict";

  var GOOD = ["active", "cloned", "published", "imported", "completed", "released"];
  var BUSY = ["provisioning", "updating", "deleting", "cloning", "pulling", "importing", "running", "scheduled"];
  var BAD = ["error", "failed"];
  var WARN = ["suspended", "locked", "inactive", "deprecated", "canceled", "unpublished", "notCloned", "modifiable"];

  var formatter = {
    /** ValueState of any ABAP environment status value. */
    statusState: function (sStatus) {
      if (GOOD.indexOf(sStatus) >= 0) { return "Success"; }
      if (BUSY.indexOf(sStatus) >= 0) { return "Information"; }
      if (BAD.indexOf(sStatus) >= 0) { return "Error"; }
      if (WARN.indexOf(sStatus) >= 0) { return "Warning"; }
      return "None";
    },

    /** Icon for states the reconciler is still driving (busy indicator in tables). */
    statusIcon: function (sStatus) {
      return BUSY.indexOf(sStatus) >= 0 && sStatus !== "scheduled" ? "sap-icon://synchronize" : "";
    },

    /** "notCloned" → "Not Cloned", "odataV4Ui" → "Odata V4 Ui", "transportOfCopies" → "Transport Of Copies". */
    enumText: function (sValue) {
      if (!sValue) { return ""; }
      var s = String(sValue).replace(/([a-z0-9])([A-Z])/g, "$1 $2").replace(/[-_]/g, " ");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** ["a","b"] → "a, b". */
    joinList: function (aValues) {
      return Array.isArray(aValues) ? aValues.join(", ") : "";
    },

    /** [{key, value}] → "key=value, …". */
    keyValues: function (aPairs) {
      if (!Array.isArray(aPairs)) { return ""; }
      return aPairs.map(function (p) { return p.key + "=" + p.value; }).join(", ");
    },

    /** Transport tasks → "H01K900001-01 (released, 2 objects); …". */
    tasks: function (aTasks) {
      if (!Array.isArray(aTasks)) { return ""; }
      return aTasks.map(function (t) {
        var n = (t.objects || []).length;
        return t.taskId + " (" + t.status + ", " + n + (n === 1 ? " object)" : " objects)");
      }).join("; ");
    }
  };

  return formatter;
});
