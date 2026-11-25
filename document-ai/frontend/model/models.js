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

    /** Empty forms of the dialogs. Lists (labels, attributes, languages, …) are edited as one entry per line. */
    emptyForms: function () {
      return {
        upload: { fileName: "", documentTypeId: "", schemaId: "", templateId: "", clientId: "", language: "en",
          extractionMethod: "", pageCount: 1, fileSize: 0, mimeType: "", labels: "", extractNow: true },
        schema: { id: "", name: "", description: "", category: "general", documentTypeId: "", clientId: "",
          supportedLanguages: "", edit: false },
        schemaField: { id: "", schemaId: "", fieldScope: "header", sequenceNumber: 10, name: "", label: "", valueType: "string",
          required: false, description: "", defaultValue: "", format: "", edit: false },
        template: { id: "", schemaId: "", documentTypeId: "", clientId: "", name: "", description: "", senderName: "",
          sampleDocumentIds: "", edit: false },
        documentType: { id: "", name: "", description: "", category: "general", defaultSchemaId: "", clientId: "",
          supportedFileTypes: "", edit: false },
        enrichment: { id: "", name: "", description: "", subtype: "supplier", externalId: "", clientId: "", documentTypeId: "",
          attributes: "", edit: false },
        client: { id: "", name: "", description: "", documentQuota: 0, dataFeedbackEnabled: true, edit: false },
        training: { id: "", schemaId: "", documentTypeId: "", clientId: "", name: "", description: "", startNow: false, edit: false },
        action: { id: "", action: "", param: "", text: "", required: false, title: "", label: "", toast: "done", name: "" },
        correct: { id: "", label: "", value: "", valueType: "string", originalValue: "", confidencePercent: 0 },
        user: { id: "", displayName: "", password: "", scopes: "Read", edit: false }
      };
    },

    /** UI state: selected tab and filters, dialog forms. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "documents",
        documentStatus: "",
        password: { current: "", next: "", repeat: "" },
        form: this.emptyForms()
      });
    },

    /** "a\n b,\n\n" → ["a", "b"] (commas separate too, except in key=value lists, see pairs) */
    lines: function (text) {
      return String(text || "").split(/[\n,]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** One entry per line (values may contain commas: "senderName=ACME, Inc."). */
    pairs: function (text) {
      return String(text || "").split(/\n/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** Path of an entity with a string key: "/Documents('doc-1')" */
    entityPath: function (set, key) {
      return "/" + set + "('" + String(key).replace(/'/g, "''") + "')";
    },

    /** File type of a name as the backend detects it ("" if unsupported). */
    fileTypeOf: function (fileName) {
      var ext = String(fileName || "").toLowerCase().split(".").pop();
      return { pdf: "pdf", png: "png", jpg: "jpeg", jpeg: "jpeg", tif: "tiff", tiff: "tiff", xlsx: "xlsx", docx: "docx" }[ext] || "";
    }
  };
});
