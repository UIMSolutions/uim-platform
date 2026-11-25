sap.ui.define([], function () {
  "use strict";

  var DOCUMENT_STATES = { pending: "Information", done: "Warning", failed: "Error", confirmed: "Success", rejected: "None" };
  var DOCUMENT_ICONS = { pending: "sap-icon://pending", done: "sap-icon://inspection", failed: "sap-icon://error",
    confirmed: "sap-icon://accept", rejected: "sap-icon://decline" };
  var SCHEMA_STATES = { draft: "Information", active: "Success", deprecated: "Warning" };
  var TEMPLATE_STATES = { draft: "Information", active: "Success", inactive: "None" };
  var TRAINING_STATES = { pending: "None", running: "Information", completed: "Success", failed: "Error", cancelled: "Warning" };
  var CONFIDENCE_STATES = { high: "Success", medium: "Warning", low: "Error" };
  var MATCH_STATES = { notChecked: "None", matched: "Success", ambiguous: "Warning", unmatched: "Error" };
  var FILE_ICONS = { pdf: "sap-icon://pdf-attachment", png: "sap-icon://attachment-photo", jpeg: "sap-icon://attachment-photo",
    tiff: "sap-icon://attachment-photo", xlsx: "sap-icon://excel-attachment", docx: "sap-icon://doc-attachment" };

  return {
    documentState: function (s) { return DOCUMENT_STATES[s] || "None"; },
    documentIcon: function (s) { return DOCUMENT_ICONS[s] || ""; },
    schemaState: function (s) { return SCHEMA_STATES[s] || "None"; },
    templateState: function (s) { return TEMPLATE_STATES[s] || "None"; },
    trainingState: function (s) { return TRAINING_STATES[s] || "None"; },
    confidenceState: function (level) { return CONFIDENCE_STATES[level] || "None"; },
    matchState: function (s) { return MATCH_STATES[s] || "None"; },
    fileIcon: function (t) { return FILE_ICONS[t] || "sap-icon://document"; },

    /** Value state of an extracted value: missing / low → Error, medium → Warning, corrected → Success */
    valueState: function (level, missing, corrected) {
      if (corrected) {
        return "Success";
      }
      if (missing || level === "low") {
        return "Error";
      }
      return level === "medium" ? "Warning" : "None";
    },

    /** Progress bar colour of a percentage against the review threshold (70 %). */
    percentState: function (percent) {
      var p = Number(percent) || 0;
      return p >= 90 ? "Success" : p >= 70 ? "Warning" : "Error";
    },

    /** "purchaseOrder" → "Purchase Order", "mlModel" → "ML Model" */
    enumText: function (value) {
      if (!value) {
        return "";
      }
      var special = { done: "Extracted", mlModel: "ML Model", generativeAi: "Generative AI", templateBased: "Template Based", lineItem: "Line Item",
        notChecked: "Not Checked", string: "Text", billOfLading: "Bill of Lading", letterOfCredit: "Letter of Credit" };
      if (special[value]) {
        return special[value];
      }
      return String(value).replace(/([a-z])([A-Z])/g, "$1 $2").split(/[-_ ]/).map(function (w) {
        return w.charAt(0).toUpperCase() + w.slice(1);
      }).join(" ");
    },

    /** 182344 → "178 KB" */
    fileSize: function (bytes) {
      var b = Number(bytes);
      if (!isFinite(b) || b <= 0) {
        return "";
      }
      if (b < 1024) {
        return b + " B";
      }
      if (b < 1024 * 1024) {
        return Math.round(b / 1024) + " KB";
      }
      return (b / 1024 / 1024).toFixed(1) + " MB";
    },

    /** 0.8734 → "87 %" */
    percent: function (share) {
      var s = Number(share);
      return isFinite(s) ? Math.round(s * 100) + " %" : "";
    },

    /** Row 0 = header ("") else "#2" */
    row: function (index) {
      return index > 0 ? "#" + index : "";
    },

    /** "S/4 (s4)"-style label of a reference: name, falling back to the id. */
    nameOrId: function (name, id) {
      return name || id || "";
    },

    /** 3 of 6 */
    ofTotal: function (done, total) {
      return (done || 0) + " / " + (total || 0);
    },

    /** Collection → "a, b, c" */
    list: function (values) {
      return (values || []).join(", ");
    },

    /** Truthy → check mark */
    yesNo: function (value) {
      return value ? "✓" : "";
    }
  };
});
