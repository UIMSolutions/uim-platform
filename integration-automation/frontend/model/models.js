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

    /** Empty forms of the dialogs. Lists are edited as one entry per line. */
    emptyForms: function () {
      return {
        system: { id: "", name: "", description: "", systemType: "sapS4HanaCloud", host: "", port: 443, protocol: "https",
          client: "", sid: "", environment: "production", region: "", edit: false },
        destination: { id: "", name: "", description: "", systemId: "", destinationType: "http", url: "",
          authentication: "noAuthentication", proxyType: "internet", locationId: "", user: "", tokenServiceUrl: "",
          audience: "", scope: "", enabled: true, edit: false },
        scenario: { id: "", name: "", description: "", category: "custom", version: "1.0", sourceSystemType: "any",
          targetSystemType: "any", prerequisites: "", edit: false },
        scenarioTask: { id: "", scenarioId: "", sequenceNumber: 10, name: "", description: "", taskType: "manual",
          priority: "medium", assignedRole: "", instructions: "", destinationId: "", automationEndpoint: "",
          automationPayload: "", requiresSourceSystem: false, requiresTargetSystem: false, afterPrevious: true,
          dependsOn: "", estimatedMinutes: 15, edit: false },
        workflow: { scenarioId: "", name: "", description: "", sourceSystemId: "", targetSystemId: "", start: true },
        taskAction: { id: "", action: "", param: "", text: "", required: false, title: "", label: "", toast: "done" },
        assign: { id: "", name: "", assignedTo: "", priority: "" },
        purge: { olderThanDays: 90 },
        user: { id: "", displayName: "", password: "", scopes: "Read", edit: false }
      };
    },

    /** UI state: selected tab and filters, dialog forms. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "workflows",
        workflowStatus: "",
        taskFilter: "open",
        outcome: "",
        password: { current: "", next: "", repeat: "" },
        form: this.emptyForms()
      });
    },

    /** "a\n b,\n\n" → ["a", "b"] */
    lines: function (text) {
      return String(text || "").split(/[\n,]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** Path of an entity with a string key: "/Workflows('wf-1')" */
    entityPath: function (set, key) {
      return "/" + set + "('" + String(key).replace(/'/g, "''") + "')";
    }
  };
});
