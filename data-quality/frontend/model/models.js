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
        dataset: { id: "", name: "", category: "", description: "", edit: false },
        record: { datasetId: "", id: "", fields: "", key: "" },
        importCsv: { datasetId: "", csv: "", createDataset: true, replaceExisting: true },
        validationRule: { name: "", fieldName: "", datasetPattern: "", ruleType: "required", severity: "error",
          status: "active", pattern: "", minValue: "", maxValue: "", allowedValues: "", caseSensitive: true,
          crossFieldName: "", operator: "eq", expression: "", referenceDataset: "", referenceField: "",
          category: "", priority: 100, description: "" },
        cleansingRule: { name: "", fieldName: "", datasetPattern: "", action: "trim", status: "active",
          findPattern: "", replaceWith: "", defaultValue: "", lookupDataset: "", lookupKeyField: "",
          lookupValueField: "", sourceField: "", category: "", priority: 100, description: "" },
        cleansingJob: { datasetId: "", ruleIds: "", dryRun: false, revalidate: true },
        detect: { datasetId: "", matchFields: "name", strategy: "fuzzy", threshold: 85 },
        resolve: { key: "", survivorRecordId: "", merge: true, candidates: [] },
        user: { id: "", displayName: "", password: "", scopes: "Read", edit: false },
        address: { inputLine1: "", inputLine2: "", inputCity: "", inputRegion: "", inputPostalCode: "",
          inputCountry: "", sourceRecordId: "" }
      };
    },

    /** UI state: selected tab and dataset filter, dialog forms. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "datasets",
        dataset: "",
        severity: "",
        password: { current: "", next: "", repeat: "" },
        form: this.emptyForms()
      });
    },

    /** "a\n b,\n\n" → ["a", "b"] */
    lines: function (text) {
      return String(text || "").split(/[\n,]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** "name=value" lines (values may contain commas). */
    fieldLines: function (text) {
      return String(text || "").split("\n").map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** "<dataset>~<id>" → { dataset, id } */
    splitKey: function (key) {
      var pos = String(key || "").indexOf("~");
      return pos < 0 ? { dataset: "", id: String(key || "") } : { dataset: key.slice(0, pos), id: key.slice(pos + 1) };
    },

    /** "c-1001=100" → { recordId, score } */
    candidate: function (text) {
      var pos = String(text || "").lastIndexOf("=");
      return pos < 0 ? { recordId: String(text || ""), score: 0 }
        : { recordId: text.slice(0, pos), score: Number(text.slice(pos + 1)) };
    },

    /** Path of an entity with a string key: "/Records('customers~c1')" */
    entityPath: function (set, key) {
      return "/" + set + "('" + String(key).replace(/'/g, "''") + "')";
    }
  };
});
