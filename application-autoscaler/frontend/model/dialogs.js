sap.ui.define([
  "uim/autoscaler/model/models"
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

  function numbers(names) {
    return function (p) {
      names.forEach(function (n) {
        if (p[n] !== "" && p[n] !== undefined && p[n] !== null) {
          p[n] = Number(p[n]) || 0;
        }
      });
      return p;
    };
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

  /**
   * Dialog key → fragment, target (set = create via POST, patch = PATCH of
   * the entity with that key, action = unbound action), required form
   * fields, payload builder and success toast.
   */
  return {
    binding: resource("BindingDialog", "Bindings", ["name", "appGuid"], numbers(["currentInstances"]),
      ["appGuid", "currentInstances"]),
    policy: resource("PolicyDialog", "Policies", ["name"], numbers(["instanceMinCount", "instanceMaxCount"])),
    rule: resource("RuleDialog", "Rules", ["policyId", "metricType", "adjustment"], function (p) {
      p = numbers(["threshold", "breachDurationSeconds", "coolDownSeconds"])(p);
      if (p.metricType !== "custom") {
        p.customMetricName = "";
      }
      return p;
    }, ["policyId"]),
    schedule: resource("ScheduleDialog", "Schedules", ["policyId", "kind"], function (p) {
      p = numbers(["instanceMinCount", "instanceMaxCount", "initialMinInstanceCount"])(p);
      var recurring = p.kind === "recurring";
      p.daysOfWeek = recurring ? models.lines(p.daysOfWeek) : [];
      p.daysOfMonth = recurring ? models.lines(p.daysOfMonth) : [];
      ["startTime", "endTime", "startDate", "endDate"].forEach(function (n) { if (!recurring) { p[n] = ""; } });
      ["startDateTime", "endDateTime"].forEach(function (n) { if (recurring) { p[n] = ""; } });
      return p;
    }, ["policyId", "kind"]),
    scale: { fragment: "ScaleDialog", action: "ScaleBinding", required: ["id", "instances"], keepOpen: true,
      payload: function (f) { return compact({ id: f.id, instances: Number(f.instances) || 0, reason: f.reason }); } },
    metric: { fragment: "MetricDialog", set: "MetricSamples", required: ["bindingId", "metricName", "value"], toast: "metricSent",
      payload: function (f) {
        return compact({ bindingId: f.bindingId, metricName: f.metricName, value: Number(f.value) || 0, unit: f.unit });
      },
      toastArgs: function (r) { return [r.metricName, r.value, r.unit || ""]; } },
    simulate: { fragment: "SimulateDialog", action: "SimulateLoad", required: ["bindingId", "metricName", "value"],
      toast: "simulated",
      payload: function (f) {
        return { bindingId: f.bindingId, metricName: f.metricName, value: Number(f.value) || 0,
          durationSeconds: Number(f.durationSeconds) || 0, stepSeconds: Number(f.stepSeconds) || 30 };
      },
      toastArgs: function (r) { return [r.samples, r.metricName, r.value]; } },
    attach: { fragment: "AttachDialog", action: "AttachPolicy", required: ["id", "policyId"], toast: "policyAttached",
      payload: function (f) { return { id: f.id, policyId: f.policyId }; },
      toastArgs: function (r) { return [r.policyName, r.name]; } },
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
