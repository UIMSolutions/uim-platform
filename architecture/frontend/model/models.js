sap.ui.define([
  "sap/ui/model/json/JSONModel",
  "sap/ui/Device"
], function (JSONModel, Device) {
  "use strict";

  /** Attributes edited in the building block dialog (lists as one entry per line). */
  var BLOCK_FIELDS = ["name", "description", "owner", "versionLabel", "elementType", "viewpoint", "capability",
    "realizesId", "vendor", "endpoint", "dataClassification", "dataOwner", "sourceSystem", "factSheetType",
    "factSheetId", "validUntil"];
  var BLOCK_LISTS = ["tags", "interfaces"];

  var models = {
    BLOCK_FIELDS: BLOCK_FIELDS,
    BLOCK_LISTS: BLOCK_LISTS,

    /** TOGAF kinds in display order. */
    KINDS: ["architecture", "solution", "data", "business", "technology"],

    /** Lifecycle states in display order. */
    STATUSES: ["proposed", "approved", "inDevelopment", "active", "deprecated", "retired"],

    /** ArchiMate 3.2 relationship types. */
    RELATIONSHIP_TYPES: ["serving", "realization", "assignment", "access", "composition", "aggregation", "flow",
      "triggering", "influence", "specialization", "association"],

    createDeviceModel: function () {
      var model = new JSONModel(Device);
      model.setDefaultBindingMode("OneWay");
      return model;
    },

    emptyBlockForm: function (kind) {
      var form = { mode: "create", id: "", kind: kind || "architecture" };
      BLOCK_FIELDS.forEach(function (f) { form[f] = ""; });
      BLOCK_LISTS.forEach(function (f) { form[f] = ""; });
      form.versionLabel = "1.0.0";
      return form;
    },

    emptyRelationshipForm: function (sourceId) {
      return { sourceId: sourceId || "", type: "serving", targetId: "", description: "" };
    },

    /** UI state: tab, filters, dialog forms, impact analysis result. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "blocks",
        kindFilter: "all",
        statusFilter: "",
        blockForm: this.emptyBlockForm(),
        relationshipForm: this.emptyRelationshipForm(),
        impact: [],
        impactLoaded: false,
        kinds: this.KINDS.map(function (k) { return { key: k }; }),
        statuses: this.STATUSES.map(function (s) { return { key: s }; }),
        relationshipTypes: this.RELATIONSHIP_TYPES.map(function (t) { return { key: t }; }),
        classifications: [{ key: "" }, { key: "public" }, { key: "internal" }, { key: "confidential" }, { key: "restricted" }],
        factSheetTypes: ["", "Application", "ITComponent", "Interface", "DataObject", "BusinessCapability",
          "BusinessContext", "Organization", "Platform", "Initiative", "Objective", "Provider", "TechCategory"]
          .map(function (t) { return { key: t }; })
      });
    },

    /** "a\n b,\n\n" → ["a", "b"] */
    lines: function (text) {
      return String(text || "").split(/[\n,]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** Row → dialog form (lists as lines). */
    blockToForm: function (row) {
      var form = this.emptyBlockForm(row.kind);
      form.mode = "edit";
      form.id = row.id;
      BLOCK_FIELDS.forEach(function (f) { form[f] = row[f] === null || row[f] === undefined ? "" : row[f]; });
      BLOCK_LISTS.forEach(function (f) { form[f] = (row[f] || []).join("\n"); });
      return form;
    },

    /**
     * Dialog form → OData payload. On create every non-empty value is sent;
     * on edit only the values that differ from the original row.
     */
    formToPayload: function (form, original) {
      var payload = {};
      var creating = form.mode === "create";
      if (creating) {
        payload.kind = form.kind;
        if (form.id) {
          payload.id = form.id.trim();
        }
      }
      BLOCK_FIELDS.forEach(function (f) {
        var value = typeof form[f] === "string" ? form[f].trim() : form[f];
        var before = original && original[f] !== null && original[f] !== undefined ? original[f] : "";
        if (creating ? value !== "" : value !== before) {
          payload[f] = f === "validUntil" && value === "" ? null : value;
        }
      });
      BLOCK_LISTS.forEach(function (f) {
        var list = models.lines(form[f]);
        var before = (original && original[f]) || [];
        if (creating ? list.length > 0 : list.join("\n") !== before.join("\n")) {
          payload[f] = list;
        }
      });
      return payload;
    },

    /** Path of an entity with a string key: "/BuildingBlocks('abb-crm')" */
    entityPath: function (set, key) {
      return "/" + set + "('" + String(key).replace(/'/g, "''") + "')";
    }
  };

  return models;
});
