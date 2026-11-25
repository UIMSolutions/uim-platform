sap.ui.define([
  "uim/integrationautomation/model/models"
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

  function numbers(names) {
    return function (p) {
      names.forEach(function (n) { p[n] = Number(p[n]) || 0; });
      return p;
    };
  }

  /**
   * Dialog key → fragment, target (set = create via POST, patch = PATCH of
   * the entity with that key, action = unbound action), required form
   * fields, payload builder, success toast and follow-up (after).
   */
  return {
    system: resource("SystemDialog", "Systems", ["name", "host"], numbers(["port"])),
    destination: resource("DestinationDialog", "Destinations", ["name"], function (p) {
      p.systemId = p.systemId || null;
      return p;
    }),
    scenario: resource("ScenarioDialog", "Scenarios", ["name"], function (p) {
      p.prerequisites = models.lines(p.prerequisites);
      return p;
    }),
    scenarioTask: resource("ScenarioTaskDialog", "ScenarioTasks", ["scenarioId", "name"], function (p) {
      p.sequenceNumber = Number(p.sequenceNumber) || 10;
      p.estimatedMinutes = Number(p.estimatedMinutes) || 0;
      p.dependsOn = models.lines(p.dependsOn);
      p.destinationId = p.destinationId || null;
      return p;
    }, ["scenarioId"]),
    workflow: { fragment: "WorkflowDialog", set: "Workflows", required: ["scenarioId"], toast: "workflowCreated",
      payload: function (f) {
        return compact({ scenarioId: f.scenarioId, name: f.name, description: f.description, sourceSystemId: f.sourceSystemId,
          targetSystemId: f.targetSystemId });
      },
      toastArgs: function (r) { return [r.name, r.totalTasks]; },
      /** start right away if asked */
      after: function (result, form, controller) {
        return form.start ? controller.invokeAction("StartWorkflow", { id: result.id }) : Promise.resolve(result);
      } },
    taskAction: { fragment: "ActionDialog", required: [],
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
      toastArgs: function (r) { return [r.name || r.id, r.status || ""]; } },
    assign: { fragment: "AssignDialog", action: "AssignTask", required: ["id"], toast: "taskAssigned",
      payload: function (f) { return { id: f.id, assignedTo: f.assignedTo || "", priority: f.priority || "" }; },
      toastArgs: function (r) { return [r.name, r.assignedTo || "–"]; } },
    purge: { fragment: "PurgeDialog", action: "PurgeExecutionLogs", required: ["olderThanDays"], toast: "purged",
      payload: function (f) { return { olderThanDays: Number(f.olderThanDays) || 0 }; },
      toastArgs: function (r) { return [r.removed, r.olderThanDays]; } },
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
