sap.ui.define([
  "uim/dataretention/model/models"
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
   * immutable: members that are sent on create only.
   */
  function resource(fragment, set, required, transform, immutable) {
    return {
      fragment: fragment, set: set, required: required,
      patch: function (f) { return f.edit ? f.id : ""; },
      payload: function (f) {
        var p = without(f, ["edit"]);
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

  function rule(p) {
    p.duration = Number(p.duration) || 0;
    return p;
  }

  /**
   * Dialog key → fragment, target (set = create via POST, patch = PATCH of
   * the entity with that key, action = unbound action), required form
   * fields, payload builder and success toast.
   */
  return {
    applicationGroup: resource("ApplicationGroupDialog", "ApplicationGroups", ["name"], function (p) {
      p.applicationIds = models.lines(p.applicationIds);
      return p;
    }),
    legalEntity: resource("LegalEntityDialog", "LegalEntities", ["name"], function (p) {
      p.country = String(p.country || "").toUpperCase();
      return p;
    }),
    dataSubjectRole: resource("DataSubjectRoleDialog", "DataSubjectRoles", ["name"]),
    businessPurpose: resource("BusinessPurposeDialog", "BusinessPurposes", ["name", "applicationGroupId", "dataSubjectRoleId"],
      function (p) {
        p.legalEntityId = p.legalEntityId || null;
        return p;
      }),
    legalGround: resource("LegalGroundDialog", "LegalGrounds", ["businessPurposeId", "name"], null, ["businessPurposeId"]),
    residenceRule: resource("ResidenceRuleDialog", "ResidenceRules", ["legalGroundId", "duration"], rule,
      ["businessPurposeId", "legalGroundId"]),
    retentionRule: resource("RetentionRuleDialog", "RetentionRules", ["legalGroundId", "duration"], rule,
      ["businessPurposeId", "legalGroundId"]),
    dataSubject: resource("DataSubjectDialog", "DataSubjects", ["externalId", "businessPurposeId"], function (p) {
      ["referenceDate", "legalGroundId", "legalEntityId", "dataSubjectRoleId", "applicationGroupId"].forEach(function (n) {
        p[n] = p[n] || null;
      });
      return p;
    }),
    deletionRequest: { fragment: "DeletionRequestDialog", set: "DeletionRequests", required: ["dataSubjectId"],
      toast: "requestCreated", payload: compact },
    archivingJob: { fragment: "ArchivingJobDialog", set: "ArchivingJobs", required: ["applicationGroupId"], toast: "jobScheduled",
      payload: function (f) {
        return compact({ applicationGroupId: f.applicationGroupId, operation: f.operation, dryRun: !!f.dryRun,
          referenceBefore: f.referenceBefore, scheduledAt: models.dateTime(f.scheduledAt) });
      } },
    legalHold: { fragment: "LegalHoldDialog", action: "SetLegalHold", required: ["id"],
      toast: function (r) { return r.legalHold ? "legalHoldSet" : "legalHoldReleased"; },
      payload: function (f) { return { id: f.id, legalHold: !!f.legalHold, reason: f.legalHold ? f.reason : "" }; },
      toastArgs: function (r) { return [r.externalId]; } },
    check: { fragment: "CheckDialog", action: "CheckEndOfPurpose", required: [],
      toast: function (r) { return r.simulated ? "checkSimulated" : "checked"; },
      payload: function (f) { return { applicationGroupId: f.applicationGroupId, simulate: !!f.simulate }; },
      toastArgs: function (r) { return [r.checked, r.blocked, r.markedForDeletion, r.legalHolds]; } },
    simulate: { fragment: "SimulateDialog", action: "SimulateRetention", required: ["businessPurposeId", "referenceDate"],
      keepOpen: true,
      payload: function (f) {
        return { businessPurposeId: f.businessPurposeId, referenceDate: f.referenceDate, legalGroundId: f.legalGroundId };
      } },
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
