sap.ui.define([], function () {
  "use strict";

  var WORKFLOW_STATES = { planned: "None", inProgress: "Information", suspended: "Warning", completed: "Success",
    failed: "Error", terminated: "None" };
  var WORKFLOW_ICONS = { planned: "sap-icon://appointment-2", inProgress: "sap-icon://process", suspended: "sap-icon://pause",
    completed: "sap-icon://sys-enter-2", failed: "sap-icon://error", terminated: "sap-icon://stop" };
  var TASK_STATES = { pending: "None", inProgress: "Information", completed: "Success", skipped: "Warning", failed: "Error" };
  var TASK_ICONS = { pending: "sap-icon://pending", inProgress: "sap-icon://process", completed: "sap-icon://sys-enter-2",
    skipped: "sap-icon://media-forward", failed: "sap-icon://error" };
  var SCENARIO_STATES = { draft: "Information", active: "Success", deprecated: "Warning", archived: "None" };
  var CONNECTION_STATES = { inactive: "None", active: "Success", error: "Error" };
  var CONNECTION_ICONS = { inactive: "sap-icon://question-mark", active: "sap-icon://connected", error: "sap-icon://disconnected" };
  var OUTCOME_STATES = { info: "None", success: "Success", failure: "Error", skipped: "Warning", timeout: "Error" };
  var PRIORITY_STATES = { low: "None", medium: "Information", high: "Warning", critical: "Error" };
  var TYPE_ICONS = { manual: "sap-icon://employee", approval: "sap-icon://approvals", automated: "sap-icon://it-system",
    notification: "sap-icon://bell" };

  return {
    workflowState: function (s) { return WORKFLOW_STATES[s] || "None"; },
    workflowIcon: function (s) { return WORKFLOW_ICONS[s] || ""; },
    taskState: function (s) { return TASK_STATES[s] || "None"; },
    taskIcon: function (s) { return TASK_ICONS[s] || ""; },
    scenarioState: function (s) { return SCENARIO_STATES[s] || "None"; },
    connectionState: function (s) { return CONNECTION_STATES[s] || "None"; },
    connectionIcon: function (s) { return CONNECTION_ICONS[s] || ""; },
    outcomeState: function (s) { return OUTCOME_STATES[s] || "None"; },
    priorityState: function (s) { return PRIORITY_STATES[s] || "None"; },
    typeIcon: function (t) { return TYPE_ICONS[t] || "sap-icon://task"; },

    /** Progress bar colour: failed → Error, done → Success, else Information. */
    progressState: function (status) {
      return status === "failed" ? "Error" : status === "completed" ? "Success" : status === "suspended" ? "Warning" : "Information";
    },

    /** "inProgress" → "In Progress", "sapS4HanaCloud" → "SAP S/4HANA Cloud" */
    enumText: function (value) {
      if (!value) {
        return "";
      }
      var special = { sapS4Hana: "SAP S/4HANA", sapS4HanaCloud: "SAP S/4HANA Cloud", sapBtp: "SAP BTP", any: "Any",
        sapSuccessFactors: "SAP SuccessFactors", sapIntegratedBusinessPlanning: "SAP Integrated Business Planning",
        sapBuildWorkZone: "SAP Build Work Zone", onPremise: "On-Premise",
        oauth2ClientCredentials: "OAuth2 Client Credentials", oauth2SamlBearerAssertion: "OAuth2 SAML Bearer",
        odata: "OData", restApi: "REST API", http: "HTTP", rfc: "RFC", soap: "SOAP" };
      if (special[value]) {
        return special[value];
      }
      return String(value).replace(/^sap(?=[A-Z])/, "SAP ").replace(/([a-z])([A-Z])/g, "$1 $2").split(/[-_ ]/).map(function (w) {
        return w === "SAP" ? w : w.charAt(0).toUpperCase() + w.slice(1);
      }).join(" ");
    },

    /** "S/4 (s4)"-style label of a reference: name, falling back to the id. */
    nameOrId: function (name, id) {
      return name || id || "";
    },

    /** "SF → S/4" */
    route: function (source, target) {
      if (!source && !target) {
        return "";
      }
      return (source || "–") + " → " + (target || "–");
    },

    /** 3 of 6 */
    ofTotal: function (done, total) {
      return (done || 0) + " / " + (total || 0);
    },

    /** Seconds → "1 h 5 min", "42 s", "" */
    duration: function (seconds) {
      var s = Number(seconds);
      if (!isFinite(s) || s <= 0) {
        return "";
      }
      if (s < 60) {
        return Math.round(s) + " s";
      }
      var m = Math.round(s / 60);
      return m < 60 ? m + " min" : Math.floor(m / 60) + " h" + (m % 60 ? " " + (m % 60) + " min" : "");
    },

    /** Minutes → "1 h 30 min" */
    minutes: function (minutes) {
      var m = Number(minutes);
      if (!isFinite(m) || m <= 0) {
        return "";
      }
      return m < 60 ? m + " min" : Math.floor(m / 60) + " h" + (m % 60 ? " " + (m % 60) + " min" : "");
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
