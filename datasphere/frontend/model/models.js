sap.ui.define([
  "sap/ui/model/json/JSONModel",
  "sap/ui/Device"
], function (JSONModel, Device) {
  "use strict";

  return {
    createDeviceModel: function () {
      var model = new JSONModel(Device);
      model.setDefaultBindingMode("OneWay");
      return model;
    },

    /**
     * Empty forms of the dialogs (the keys of model/dialogs). List valued
     * members (columns, tags …) are edited as text, one entry per line.
     */
    emptyForms: function () {
      return {
        space: { id: "", name: "", description: "", priority: 5, diskQuotaGiB: 10, memoryQuotaGiB: 2,
          auditLogEnabled: false, edit: false },
        member: { id: "", spaceId: "", userName: "", displayName: "", role: "viewer", edit: false },
        connection: { id: "", spaceId: "", name: "", description: "", connectionType: "hana", host: "", port: 443,
          database: "", user: "", password: "", properties: "", edit: false },
        remoteTable: { id: "", spaceId: "", connectionId: "", name: "", businessName: "", description: "",
          remoteSchema: "", remoteObject: "", replicationMode: "remote", columns: "", edit: false },
        view: { id: "", spaceId: "", name: "", businessName: "", description: "", semantic: "relationalDataset",
          sqlExpression: "SELECT *\nFROM ", columns: "", exposed: false, edit: false },
        dataFlow: { id: "", spaceId: "", name: "", businessName: "", description: "", sourceObjects: "", transforms: "",
          targetTable: "", loadMode: "append", edit: false },
        task: { id: "", spaceId: "", name: "", description: "", taskType: "replication", targetObjectId: "",
          frequency: "manual", intervalMinutes: 60, startAt: "", maxRetries: 1, edit: false },
        taskChain: { id: "", spaceId: "", name: "", description: "", taskIds: "", failurePolicy: "stop",
          frequency: "manual", intervalMinutes: 60, startAt: "", edit: false },
        accessControl: { id: "", spaceId: "", name: "", description: "", criteriaColumn: "", criteriaOperator: "equals",
          criteriaValues: "", targetViewIds: "", assignedUsers: "", enabled: true, edit: false },
        catalog: { id: "", spaceId: "", name: "", businessName: "", description: "", assetType: "view", sourceObjectId: "",
          owner: "", qualityStatus: "unknown", sensitivity: "internal", tags: "", glossaryTerms: "", edit: false },
        accessCheck: { viewId: "", viewName: "", user: "", row: "{\n  \"COUNTRY\": \"DE\"\n}", result: null },
        lock: { id: "", name: "", reason: "" },
        user: { id: "", displayName: "", password: "", scopes: "Read", edit: false }
      };
    },

    /** UI state: selected tab, space filter, run filter, dialog forms. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "spaces",
        space: "",
        runFilter: "",
        password: { current: "", next: "", repeat: "" },
        form: this.emptyForms()
      });
    },

    /** "a\n b\n\n" → ["a", "b"] (one entry per line; commas stay: "DECIMAL(15,2)"). */
    lines: function (text) {
      if (Array.isArray(text)) {
        return text;
      }
      return String(text || "").split(/\r?\n/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** "a, b; c" → ["a", "b", "c"] (short lists: values, users, tags). */
    list: function (text) {
      if (Array.isArray(text)) {
        return text;
      }
      return String(text || "").split(/[\n,;]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** Path of an entity with a string key: "/Views('v')" */
    entityPath: function (set, key) {
      return "/" + set + "('" + String(key).replace(/'/g, "''") + "')";
    },

    /** The objects after FROM / JOIN of a SELECT (as the server derives them; quotes removed). */
    sqlSources: function (sql) {
      var text = String(sql || "").replace(/--[^\n]*/g, " ").replace(/\/\*[\s\S]*?\*\//g, " ").replace(/'(?:''|[^'])*'/g, "''");
      var re = /\b(?:FROM|JOIN)\s+("([^"]+)"|[A-Za-z0-9_.$]+)/gi;
      var result = [];
      var m;
      while ((m = re.exec(text)) !== null) {
        var name = m[2] || m[1].toUpperCase();
        if (name !== "(" && name !== "DUMMY" && result.indexOf(name) < 0) {
          result.push(name);
        }
      }
      return result;
    },

    /** True if the text is empty or a JSON object. */
    isJsonObject: function (text) {
      if (!text || !String(text).trim()) {
        return false;
      }
      try {
        var v = JSON.parse(text);
        return v !== null && typeof v === "object" && !Array.isArray(v);
      } catch (e) {
        return false;
      }
    },

    /** ISO date-time for the API from a DateTimePicker value ("" stays ""). */
    isoOrEmpty: function (value) {
      if (!value) {
        return "";
      }
      var d = value instanceof Date ? value : new Date(value);
      return isNaN(d.getTime()) ? "" : d.toISOString().replace(/\.\d{3}Z$/, "Z");
    }
  };
});
