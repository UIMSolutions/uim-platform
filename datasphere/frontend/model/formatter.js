sap.ui.define([], function () {
  "use strict";

  var STATES = {
    // spaces, connections, schedules
    active: "Success", locked: "Error", paused: "Warning", untested: "None", valid: "Success", invalid: "Error",
    // replication, deployment
    notReplicated: "None", replicated: "Success", failed: "Error", notDeployed: "None", deployed: "Success",
    changesToDeploy: "Warning",
    // runs
    notRun: "None", running: "Information", completed: "Success", cancelled: "Warning",
    // governance
    unknown: "None", poor: "Error", adequate: "Warning", good: "Success", excellent: "Success",
    "public": "Success", internal: "Information", confidential: "Warning", restricted: "Error"
  };
  var ICONS = {
    completed: "sap-icon://status-positive", failed: "sap-icon://status-negative", running: "sap-icon://process",
    cancelled: "sap-icon://status-inactive", notRun: "sap-icon://status-inactive",
    valid: "sap-icon://connected", invalid: "sap-icon://disconnected", untested: "sap-icon://question-mark",
    deployed: "sap-icon://accept", notDeployed: "sap-icon://upload-to-cloud", changesToDeploy: "sap-icon://edit",
    replicated: "sap-icon://download", notReplicated: "sap-icon://cloud", active: "sap-icon://synchronize"
  };
  var TYPE_ICONS = {
    replication: "sap-icon://download", dataFlow: "sap-icon://process", viewPersistence: "sap-icon://database",
    taskChain: "sap-icon://chain-link", table: "sap-icon://table-view", view: "sap-icon://grid",
    remoteTable: "sap-icon://cloud", analyticModel: "sap-icon://business-objects-experience", connection: "sap-icon://connected",
    other: "sap-icon://document"
  };
  var CONNECTION_ICONS = {
    hana: "sap-icon://database", s4hana: "sap-icon://sap-logo-shape", bw: "sap-icon://business-objects-experience",
    hdl: "sap-icon://folder", odata: "sap-icon://world", sql: "sap-icon://database", abap: "sap-icon://syntax",
    kafka: "sap-icon://feed", file: "sap-icon://document", other: "sap-icon://connected"
  };

  var bundle = null;

  return {
    /** Set by tests for texts of enumerations outside views. */
    setBundle: function (b) { bundle = b; },

    state: function (s) { return STATES[s] || "None"; },
    icon: function (s) { return ICONS[s] || ""; },
    typeIcon: function (t) { return TYPE_ICONS[t] || "sap-icon://document"; },
    connectionIcon: function (t) { return CONNECTION_ICONS[t] || "sap-icon://connected"; },

    /** Text of an enumeration value from i18n ("enum_<value>"), else the value. */
    enumText: function (value) {
      if (value === undefined || value === null || value === "") {
        return "";
      }
      var key = "enum_" + value;
      var text = this && this.getOwnerComponent ? this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(key)
        : bundle ? bundle.getText(key) : key;
      return text === key ? String(value) : text;
    },

    /** Disk usage state: > 90 % error, > 75 % warning. */
    usageState: function (percent) {
      var p = Number(percent) || 0;
      return p > 90 ? "Error" : p > 75 ? "Warning" : "Success";
    },

    /** 0..100 for a ProgressIndicator (over quota shows full). */
    percent: function (percent) {
      return Math.max(0, Math.min(100, Number(percent) || 0));
    },

    /** "12.5 %" */
    percentText: function (percent) {
      return (Math.round((Number(percent) || 0) * 10) / 10) + " %";
    },

    /** 1234567 → "1,234,567" */
    count: function (n) {
      return (Number(n) || 0).toLocaleString("en-US");
    },

    /** 950 → "950 ms", 64200 → "1 min 4 s", 4200 → "4.2 s" */
    duration: function (ms) {
      var v = Number(ms) || 0;
      if (v < 1000) {
        return v + " ms";
      }
      if (v < 60000) {
        return Math.round(v / 100) / 10 + " s";
      }
      return Math.floor(v / 60000) + " min " + Math.round((v % 60000) / 1000) + " s";
    },

    /** 0.25 → "256 MiB", 12.5 → "12.5 GiB" */
    gib: function (g) {
      var v = Number(g) || 0;
      return v < 1 ? Math.round(v * 1024) + " MiB" : Math.round(v * 100) / 100 + " GiB";
    },

    /** MiB with unit; GiB from 1024 MiB. */
    mib: function (m) {
      var v = Number(m) || 0;
      return v >= 1024 ? Math.round(v / 10.24) / 100 + " GiB" : Math.round(v * 100) / 100 + " MiB";
    },

    /** "93 MiB / 25 GiB" */
    mibUsage: function (used, quota) {
      var f = this && this.formatter ? this.formatter : this;
      return f.mib(used) + " / " + f.mib(quota);
    },

    /** "92 MiB / 20 GiB" (+ " (0.4 %)" when the percentage is given) */
    gibUsage: function (used, quota, percent) {
      var f = this && this.formatter ? this.formatter : this;
      return f.gib(used) + " / " + f.gib(quota) + (percent !== undefined ? " (" + f.percentText(percent) + ")" : "");
    },

    /** Array → "a, b" (collection valued properties). */
    joined: function (values) {
      return Array.isArray(values) ? values.join(", ") : String(values || "");
    },

    /** Array → one per line (TextArea prefill). */
    lines: function (values) {
      return Array.isArray(values) ? values.join("\n") : String(values || "");
    },

    /** i18n text of a key (controller or test bundle). */
    text: function (key, args) {
      var b = this && this.getOwnerComponent ? this.getOwnerComponent().getModel("i18n").getResourceBundle() : bundle;
      return b ? b.getText(key, args) : key;
    },

    /** "12,345 rows" for persisted views, "virtual" otherwise. */
    persistence: function (persisted, rows) {
      var f = this && this.formatter ? this.formatter : this;
      return persisted ? f.text.call(this, "persistedRows", [f.count(rows)]) : f.text.call(this, "virtual");
    },

    /** "Schedule · attempt 2 · chain step" */
    runInfo: function (trigger, attempts, chainRunId) {
      var f = this && this.formatter ? this.formatter : this;
      var parts = [f.enumText.call(this, trigger)];
      if (Number(attempts) > 1) {
        parts.push(f.text.call(this, "attemptN", [attempts]));
      }
      if (chainRunId) {
        parts.push(f.text.call(this, "chainStep"));
      }
      return parts.join(" · ");
    },

    /** Visible only if both flags are set. */
    and: function (a, b) {
      return !!a && !!b;
    }
  };
});
