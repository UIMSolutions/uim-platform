sap.ui.define([], function () {
  "use strict";

  var SUCCESS = ["completed", "translated", "reviewed", "excellent", "good", "active"];
  var ERROR = ["failed", "untranslated", "poor"];
  var WARNING = ["inProgress", "partial", "processing", "adequate"];
  var INFORMATION = ["draft", "pending"];

  var formatter = {
    /** ValueState of a project, text, job or quality value. */
    statusState: function (sStatus) {
      if (SUCCESS.indexOf(sStatus) >= 0) { return "Success"; }
      if (ERROR.indexOf(sStatus) >= 0) { return "Error"; }
      if (WARNING.indexOf(sStatus) >= 0) { return "Warning"; }
      if (INFORMATION.indexOf(sStatus) >= 0) { return "Information"; }
      return "None";
    },

    /** Icon of a status value. */
    statusIcon: function (sStatus) {
      switch (sStatus) {
        case "completed": case "translated": case "reviewed": return "sap-icon://status-positive";
        case "failed": case "untranslated": return "sap-icon://status-negative";
        case "inProgress": case "partial": return "sap-icon://status-in-process";
        case "processing": return "sap-icon://synchronize";
        case "pending": return "sap-icon://pending";
        case "archived": return "sap-icon://inbox";
        case "cancelled": return "sap-icon://cancel";
        default: return "";
      }
    },

    /** ValueState of a quality score (0–100). */
    qualityState: function (iScore) {
      if (!iScore) { return "None"; }
      if (iScore >= 75) { return "Success"; }
      if (iScore >= 60) { return "Warning"; }
      return "Error";
    },

    /** ValueState of a completion percentage. */
    percentState: function (iPercent) {
      if (iPercent >= 100) { return "Success"; }
      if (iPercent > 0) { return "Warning"; }
      return "None";
    },

    /** "inProgress" → "In Progress", "companyMltr" → "Company Mltr". */
    enumText: function (sValue) {
      if (!sValue) { return ""; }
      var s = String(sValue).replace(/([a-z0-9])([A-Z])/g, "$1 $2").replace(/[-_]/g, " ");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** ["a","b"] → "a, b". */
    joinList: function (aValues) {
      return Array.isArray(aValues) ? aValues.join(", ") : "";
    },

    /** "en", ["de","fr"] → "en → de, fr". */
    languagePair: function (sSource, aTargets) {
      if (!sSource) { return ""; }
      var sTargets = Array.isArray(aTargets) ? aTargets.join(", ") : (aTargets || "*");
      return sSource + " → " + sTargets;
    },

    /** [{language, text, reviewed}] → "de: Speichern ✓ · fr: Enregistrer". */
    translations: function (aTranslations) {
      if (!Array.isArray(aTranslations)) { return ""; }
      return aTranslations.map(function (t) {
        return t.language + ": " + t.text + (t.reviewed ? " ✓" : "");
      }).join(" · ");
    },

    /** True for draft projects (Activate button). */
    isDraft: function (sStatus) {
      return sStatus === "draft";
    },

    /** True unless the project is archived (Archive button). */
    isOpen: function (sStatus) {
      return !!sStatus && sStatus !== "archived";
    },

    /** Percent for a ProgressIndicator. */
    percent: function (iValue) {
      return iValue ? Number(iValue) : 0;
    }
  };

  return formatter;
});
