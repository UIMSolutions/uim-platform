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

    /** Empty forms of the create dialogs. Lists are edited as one entry per line. */
    emptyForms: function () {
      return {
        group: { id: "", labels: "" },
        scenario: { resourceGroupId: "", id: "", name: "", description: "", labels: "" },
        executable: { resourceGroupId: "", scenarioId: "", id: "", name: "", description: "", type: "workflow",
          versionId: "1.0.0", parameters: "", inputArtifacts: "", outputArtifacts: "", labels: "" },
        configuration: { resourceGroupId: "", name: "", scenarioId: "", executableId: "", parameterBindings: "",
          inputArtifactBindings: "" },
        execution: { resourceGroupId: "", configurationId: "", tags: "" },
        deployment: { resourceGroupId: "", configurationId: "", ttlSeconds: 0 },
        artifact: { resourceGroupId: "", scenarioId: "", name: "", kind: "dataset", url: "", description: "", labels: "" },
        schedule: { resourceGroupId: "", configurationId: "", name: "", cron: "0 2 * * *", status: "ACTIVE" },
        dockerSecret: { id: "", server: "", username: "", password: "" },
        storeSecret: { resourceGroupId: "", id: "", type: "S3", bucket: "", endpoint: "", region: "", pathPrefix: "",
          accessKeyId: "", secretAccessKey: "" }
      };
    },

    /** UI state: selected group and tab, dialog forms, the last action result. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "executions",
        group: "",
        form: this.emptyForms(),
        nextConfiguration: ""
      });
    },

    /** "a\n b,\n\n" → ["a", "b"] */
    lines: function (text) {
      return String(text || "").split(/[\n,]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** "<group>~<id>" → { group, id } */
    splitKey: function (key) {
      var pos = String(key || "").indexOf("~");
      return pos < 0 ? { group: "", id: String(key || "") } : { group: key.slice(0, pos), id: key.slice(pos + 1) };
    },

    /** Path of an entity with a string key: "/Executions('default~abc')" */
    entityPath: function (set, key) {
      return "/" + set + "('" + String(key).replace(/'/g, "''") + "')";
    }
  };
});
