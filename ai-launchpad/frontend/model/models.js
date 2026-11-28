sap.ui.define([
  "sap/ui/model/json/JSONModel",
  "sap/ui/Device"
], function (JSONModel, Device) {
  "use strict";

  /** The statistics a tile may show as KPI (the numeric members of the Statistics singleton). */
  var KPIS = ["workspaces", "connections", "activeConnections", "resourceGroups", "scenarios", "configurations",
    "executions", "runningExecutions", "failedExecutions", "deployments", "runningDeployments", "models", "datasets",
    "promptCollections", "prompts", "activePrompts", "promptRuns", "users", "lockedUsers", "roles", "tiles",
    "logEntriesLast24h", "warningsLast24h"];

  return {
    KPIS: KPIS,

    createDeviceModel: function () {
      var model = new JSONModel(Device);
      model.setDefaultBindingMode("OneWay");
      return model;
    },

    /**
     * Empty forms of the dialogs (the keys of model/dialogs). List valued
     * members are edited as text: one entry per line (labels, parameters)
     * or comma separated (executables, roles, scopes).
     */
    emptyForms: function () {
      return {
        workspace: { id: "", name: "", description: "", status: "active", edit: false },
        connection: { id: "", workspaceId: "", name: "", description: "", connectionType: "aiCore", url: "https://",
          authUrl: "", clientId: "", clientSecret: "", defaultResourceGroup: "default", edit: false },
        resourceGroup: { id: "", connectionId: "", description: "", labels: "", status: "ready", edit: false },
        scenario: { id: "", connectionId: "", name: "", description: "", executables: "training, serving", labels: "",
          edit: false },
        configuration: { id: "", scenarioId: "", name: "", executableId: "training", parameters: "", inputArtifacts: "",
          edit: false },
        execution: { id: "", configurationId: "", resourceGroupId: "", edit: false },
        deployment: { id: "", configurationId: "", resourceGroupId: "", minReplicas: 1, maxReplicas: 1, ttlMinutes: 0,
          edit: false },
        model: { id: "", scenarioId: "", executionId: "", name: "", version: "1", description: "", url: "", sizeMiB: 0,
          status: "available", labels: "", edit: false },
        dataset: { id: "", scenarioId: "", name: "", description: "", url: "", sizeMiB: 0, status: "available", labels: "",
          edit: false },
        collection: { id: "", workspaceId: "", name: "", description: "", edit: false },
        prompt: { id: "", collectionId: "", name: "", description: "", modelName: "gpt-4o-mini", modelVersion: "latest",
          systemMessage: "", userMessage: "", temperature: 0.7, maxTokens: 256, topP: 1, status: "draft", edit: false },
        user: { id: "", displayName: "", email: "", password: "", roles: "Viewer", locked: false, edit: false },
        role: { id: "", name: "", description: "", scopes: "Read", edit: false },
        tile: { id: "", title: "", subtitle: "", info: "", icon: "sap-icon://product", groupName: "General", sortOrder: 100,
          targetType: "app", target: "", kpi: "", kpiUnit: "", requiredScope: "Read", visible: true, edit: false }
      };
    },

    /** UI state: current page and tab, dialog forms, playground, launchpad. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        page: "launchpad",
        pageTitle: "",
        tab: "",
        executionFilter: "",
        logSeverity: "",
        logCategory: "",
        password: { current: "", next: "", repeat: "" },
        playground: { promptId: "", prompt: null, inputs: [], result: null, busy: false },
        kpis: [{ key: "", text: "—" }].concat(KPIS.map(function (k) { return { key: k, text: k }; })),
        form: this.emptyForms()
      });
    },

    /** "a\n b\n\n" → ["a", "b"] (one entry per line). */
    lines: function (text) {
      if (Array.isArray(text)) {
        return text;
      }
      return String(text || "").split(/\r?\n/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** "a, b; c" → ["a", "b", "c"] (short lists). */
    list: function (text) {
      if (Array.isArray(text)) {
        return text;
      }
      return String(text || "").split(/[\n,;]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** Path of an entity with a string key: "/Prompts('p')" */
    entityPath: function (set, key) {
      return "/" + set + "('" + String(key).replace(/'/g, "''") + "')";
    },

    /** "lifecycle/executions" → {route: "lifecycle", tab: "executions"} */
    parseTarget: function (target) {
      var parts = String(target || "").split("/");
      return { route: parts[0] || "launchpad", tab: parts.slice(1).join("/") };
    },

    /** Launchpad tiles (ordered rows) → [{name, tiles: [...]}] in order of appearance. */
    groupTiles: function (tiles, query) {
      var q = String(query || "").trim().toLowerCase();
      var groups = [];
      var byName = {};
      (tiles || []).forEach(function (t) {
        if (q && [t.title, t.subtitle, t.groupName, t.info].join(" ").toLowerCase().indexOf(q) < 0) {
          return;
        }
        if (!byName[t.groupName]) {
          byName[t.groupName] = { name: t.groupName, tiles: [] };
          groups.push(byName[t.groupName]);
        }
        byName[t.groupName].tiles.push(t);
      });
      return groups;
    },

    /** The {{placeholders}} of the prompt messages (as the server derives them). */
    placeholders: function (system, user) {
      var result = [];
      [system, user].forEach(function (text) {
        var re = /\{\{\s*([A-Za-z0-9_]+)\s*\}\}/g;
        var m;
        while ((m = re.exec(String(text || ""))) !== null) {
          if (result.indexOf(m[1]) < 0) {
            result.push(m[1]);
          }
        }
      });
      return result;
    }
  };
});
