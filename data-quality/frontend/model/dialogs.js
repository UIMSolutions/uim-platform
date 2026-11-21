sap.ui.define([
  "uim/dataquality/model/models"
], function (models) {
  "use strict";

  /** Strip empty optional texts so the backend applies its defaults. */
  function compact(object) {
    var result = {};
    Object.keys(object).forEach(function (key) {
      if (object[key] !== "" && object[key] !== null && object[key] !== undefined) {
        result[key] = object[key];
      }
    });
    return result;
  }

  function without(object, names) {
    var result = Object.assign({}, object);
    names.forEach(function (n) { delete result[n]; });
    return result;
  }

  /** Rule forms: lists from text areas, numbers from inputs; on edit everything is sent. */
  function rulePayload(form, listNames) {
    var result = without(form, ["id"]);
    listNames.forEach(function (name) {
      result[name] = models.lines(form[name]);
    });
    result.priority = Number(form.priority) || 0;
    return form.id ? result : Object.assign(compact(result), listNames.reduce(function (o, n) {
      o[n] = result[n];
      return o;
    }, {}));
  }

  /**
   * Dialog key → fragment, target (set = create via POST, patch = PATCH of
   * the entity with that key, action = unbound action), required form
   * fields, payload builder and success toast.
   */
  return {
    dataset: { fragment: "DatasetDialog", set: "Datasets", required: ["id"],
      patch: function (f) { return f.edit ? f.id : ""; },
      payload: function (f) {
        return f.edit ? { name: f.name, category: f.category, description: f.description } : compact(without(f, ["edit"]));
      } },
    importCsv: { fragment: "ImportDialog", action: "ImportCsv", required: ["datasetId", "csv"], toast: "imported",
      payload: function (f) {
        return { datasetId: f.datasetId, csv: f.csv, createDataset: !!f.createDataset, replaceExisting: !!f.replaceExisting };
      },
      toastArgs: function (r) { return [r.created, r.updated, r.skipped]; } },
    record: { fragment: "RecordDialog", set: "Records", required: ["datasetId", "fields"],
      patch: function (f) { return f.key; },
      payload: function (f) {
        var fields = models.fieldLines(f.fields);
        return f.key ? { fields: fields } : compact({ datasetId: f.datasetId, id: f.id, fields: fields });
      } },
    validationRule: { fragment: "ValidationRuleDialog", set: "ValidationRules", required: ["name"],
      patch: function (f) { return f.id; },
      payload: function (f) { return rulePayload(f, ["allowedValues"]); } },
    cleansingRule: { fragment: "CleansingRuleDialog", set: "CleansingRules", required: ["name", "fieldName"],
      patch: function (f) { return f.id; },
      payload: function (f) { return rulePayload(f, []); } },
    cleansingJob: { fragment: "CleansingJobDialog", set: "CleansingJobs", required: ["datasetId"], toast: "jobCreated",
      payload: function (f) {
        return { datasetId: f.datasetId, ruleIds: models.lines(f.ruleIds), dryRun: !!f.dryRun, revalidate: !!f.revalidate };
      } },
    detect: { fragment: "DetectDialog", action: "DetectDuplicates", required: ["datasetId", "matchFields"], toast: "detected",
      payload: function (f) {
        return { datasetId: f.datasetId, matchFields: f.matchFields, strategy: f.strategy, threshold: Number(f.threshold) || 85 };
      },
      toastArgs: function (r) { return [r.groups, r.duplicateRecords]; } },
    resolve: { fragment: "ResolveDialog", action: "ResolveMatchGroup", required: ["key"], toast: "resolved",
      payload: function (f) { return { key: f.key, survivorRecordId: f.survivorRecordId, merge: !!f.merge }; },
      toastArgs: function (r) { return [r.survivorRecordId, r.removedRecords, r.mergedFields]; } },
    address: { fragment: "AddressDialog", set: "Addresses", required: ["inputLine1"], toast: "cleansed",
      payload: compact,
      toastArgs: function (r) { return [r.quality || ""]; } }
  };
});
