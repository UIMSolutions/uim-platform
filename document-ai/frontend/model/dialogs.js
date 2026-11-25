sap.ui.define([
  "uim/documentai/model/models"
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

  /**
   * A maintained resource: create with a compact payload (POST), change
   * with every editable member (PATCH) — empty texts clear optional values.
   * immutable: members that are sent on create only; uiOnly: form members
   * that are never sent.
   */
  function resource(fragment, set, required, transform, immutable, uiOnly) {
    return {
      fragment: fragment, set: set, required: required,
      patch: function (f) { return f.edit ? f.id : ""; },
      payload: function (f) {
        var p = without(f, ["edit"].concat(uiOnly || []));
        if (transform) {
          p = transform(p);
        }
        if (!f.edit) {
          return compact(p);
        }
        return without(p, ["id"].concat(immutable || []));
      }
    };
  }

  function numbers(names) {
    return function (p) {
      names.forEach(function (n) { p[n] = Number(p[n]) || 0; });
      return p;
    };
  }

  function lists(names, split) {
    return function (p) {
      names.forEach(function (n) { p[n] = (split || models.lines)(p[n]); });
      return p;
    };
  }

  /**
   * Dialog key → fragment, target (set = create via POST, patch = PATCH of
   * the entity with that key, action = unbound action), required form
   * fields, payload builder, success toast and follow-up (after).
   */
  return {
    upload: { fragment: "UploadDialog", set: "Documents", required: ["fileName"], toast: "uploaded",
      payload: function (f) {
        var p = compact(without(f, ["extractNow"]));
        p.pageCount = Number(f.pageCount) || 1;
        p.fileSize = Number(f.fileSize) || 0;
        p.labels = models.pairs(f.labels);
        return p;
      },
      toastArgs: function (r) { return [r.fileName, r.status, r.confidencePercent || 0]; },
      /** extract right away if asked (and not already done inline) */
      after: function (result, form, controller) {
        return form.extractNow && result.status === "pending"
          ? controller.invokeAction("ExtractDocument", { id: result.id }) : Promise.resolve(result);
      } },
    schema: resource("SchemaDialog", "Schemas", ["name"], lists(["supportedLanguages"])),
    schemaField: resource("SchemaFieldDialog", "SchemaFields", ["schemaId", "name"], numbers(["sequenceNumber"]), ["schemaId"]),
    template: resource("TemplateDialog", "Templates", ["schemaId", "name"], lists(["sampleDocumentIds"]), ["schemaId"]),
    documentType: resource("DocumentTypeDialog", "DocumentTypes", ["name"], lists(["supportedFileTypes"])),
    enrichment: resource("EnrichmentDialog", "EnrichmentData", ["name", "attributes"], lists(["attributes"], models.pairs)),
    client: resource("ClientDialog", "Clients", ["name"], numbers(["documentQuota"])),
    training: Object.assign(resource("TrainingDialog", "TrainingJobs", ["schemaId", "name"], null, ["schemaId"], ["startNow"]), {
      after: function (result, form, controller) {
        return form.startNow && !form.edit ? controller.invokeAction("StartTraining", { id: result.id }) : Promise.resolve(result);
      } }),
    action: { fragment: "ActionDialog", required: [],
      action: function (f) { return f.action; },
      check: function (f) { return !f.required || !!String(f.text || "").trim(); },
      payload: function (f) {
        var p = { id: f.id };
        if (f.param && f.text) {
          p[f.param] = f.text;
        }
        return p;
      },
      toast: function (r, f) { return f.toast || "done"; },
      toastArgs: function (r) { return [r.name || r.fileName || r.id, r.status || ""]; } },
    correct: { fragment: "CorrectDialog", action: "CorrectField", required: ["id"], toast: "valueCorrected",
      payload: function (f) { return { id: f.id, value: String(f.value || "").trim() }; },
      toastArgs: function (r) { return [r.label, r.value || "–"]; } },
    user: { fragment: "UserDialog", set: "Users", required: ["id"],
      patch: function (f) { return f.edit ? f.id : ""; },
      payload: function (f) {
        var result = { displayName: f.displayName, scopes: models.lines(f.scopes) };
        if (f.password) {
          result.password = f.password;
        }
        return f.edit ? result : Object.assign(result, { id: f.id });
      } }
  };
});
