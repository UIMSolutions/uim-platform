sap.ui.define([
  "uim/datasphere/model/models"
], function (models) {
  "use strict";

  /** Strip empty optional values so the backend applies its defaults. */
  function compact(object) {
    var result = {};
    Object.keys(object).forEach(function (key) {
      var v = object[key];
      if (v !== "" && v !== null && v !== undefined && !(Array.isArray(v) && v.length === 0)) {
        result[key] = v;
      }
    });
    return result;
  }

  function without(object, names) {
    var result = Object.assign({}, object);
    names.forEach(function (n) { delete result[n]; });
    return result;
  }

  /** Convert form members: numbers, multi-line lists (one per line) and short lists (comma separated). */
  function convert(spec) {
    return function (p) {
      (spec.numbers || []).forEach(function (n) {
        if (p[n] !== "" && p[n] !== undefined && p[n] !== null) {
          p[n] = Number(p[n]) || 0;
        }
      });
      (spec.lines || []).forEach(function (n) { p[n] = models.lines(p[n]); });
      (spec.lists || []).forEach(function (n) { p[n] = models.list(p[n]); });
      (spec.times || []).forEach(function (n) { p[n] = models.isoOrEmpty(p[n]); });
      if (spec.then) {
        p = spec.then(p);
      }
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
        p = without(p, ["id"].concat(immutable || []));
        Object.keys(p).forEach(function (k) { // DateTimeOffset: null instead of ""
          if (p[k] === "" && (k === "startAt")) {
            p[k] = null;
          }
        });
        return p;
      }
    };
  }

  /**
   * Dialog key → fragment, target (set = create via POST, patch = PATCH of
   * the entity with that key, action = unbound action), required form
   * fields, payload builder and success toast.
   */
  return {
    space: resource("SpaceDialog", "Spaces", ["id", "name"], convert({ numbers: ["priority", "diskQuotaGiB", "memoryQuotaGiB"] })),
    member: resource("MemberDialog", "Members", ["spaceId", "userName", "role"], null, ["spaceId", "userName"]),
    connection: resource("ConnectionDialog", "Connections", ["spaceId", "name", "connectionType"], convert({
      numbers: ["port"], lines: ["properties"],
      then: function (p) {
        if (!p.password) {
          delete p.password; // "" keeps the stored password
        }
        return p;
      }
    }), ["spaceId"]),
    remoteTable: resource("RemoteTableDialog", "RemoteTables", ["spaceId", "connectionId", "name", "remoteObject"],
      convert({ lines: ["columns"] }), ["spaceId", "connectionId", "name"]),
    view: resource("ViewDialog", "Views", ["spaceId", "name", "sqlExpression"], convert({ lines: ["columns"] }),
      ["spaceId", "name"]),
    dataFlow: resource("DataFlowDialog", "DataFlows", ["spaceId", "name"],
      convert({ lines: ["transforms"], lists: ["sourceObjects"] }), ["spaceId", "name"]),
    task: resource("TaskDialog", "Tasks", ["spaceId", "name", "taskType", "targetObjectId"], convert({
      numbers: ["intervalMinutes", "maxRetries"], times: ["startAt"],
      then: function (p) {
        if (p.frequency !== "interval") {
          delete p.intervalMinutes;
        }
        return p;
      }
    }), ["spaceId", "taskType"]),
    taskChain: resource("TaskChainDialog", "TaskChains", ["spaceId", "name"], convert({
      numbers: ["intervalMinutes"], lists: ["taskIds"], times: ["startAt"],
      then: function (p) {
        if (p.frequency !== "interval") {
          delete p.intervalMinutes;
        }
        return p;
      }
    }), ["spaceId"]),
    accessControl: resource("AccessControlDialog", "AccessControls", ["spaceId", "name", "criteriaColumn", "criteriaValues"],
      convert({ lists: ["criteriaValues", "targetViewIds", "assignedUsers"] }), ["spaceId"]),
    catalog: resource("CatalogDialog", "CatalogAssets", ["spaceId", "name"], convert({ lists: ["tags", "glossaryTerms"] }),
      ["spaceId"]),
    accessCheck: { fragment: "AccessCheckDialog", action: "CheckDataAccess", required: ["viewId", "user", "row"], keepOpen: true,
      check: function (f) { return models.isJsonObject(f.row); },
      payload: function (f) { return { viewId: f.viewId, user: f.user.trim(), row: JSON.stringify(JSON.parse(f.row)) }; } },
    lock: { fragment: "LockDialog", action: "LockSpace", required: ["id"], toast: "spaceLocked",
      payload: function (f) { return compact({ id: f.id, reason: f.reason }); },
      toastArgs: function (r) { return [r.name]; } },
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
