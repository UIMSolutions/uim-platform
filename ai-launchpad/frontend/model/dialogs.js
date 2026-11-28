sap.ui.define([
  "uim/ailaunchpad/model/models"
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
        return without(p, ["id"].concat(immutable || []));
      }
    };
  }

  /**
   * Dialog key → fragment, target (set = create via POST, patch = PATCH of
   * the entity with that key), required form fields and payload builder.
   */
  return {
    workspace: resource("WorkspaceDialog", "Workspaces", ["id", "name"]),
    connection: resource("ConnectionDialog", "Connections", ["workspaceId", "name", "url"], convert({
      then: function (p) {
        if (!p.clientSecret) {
          delete p.clientSecret; // "" keeps the stored secret
        }
        return p;
      }
    }), ["workspaceId"]),
    resourceGroup: resource("ResourceGroupDialog", "ResourceGroups", ["id", "connectionId"], convert({ lines: ["labels"] }),
      ["connectionId"]),
    scenario: resource("ScenarioDialog", "Scenarios", ["id", "connectionId", "name"],
      convert({ lists: ["executables"], lines: ["labels"] }), ["connectionId"]),
    configuration: resource("ConfigurationDialog", "Configurations", ["scenarioId", "name", "executableId"],
      convert({ lines: ["parameters", "inputArtifacts"] }), ["scenarioId"]),
    execution: resource("ExecutionDialog", "Executions", ["configurationId"]),
    deployment: resource("DeploymentDialog", "Deployments", ["configurationId"],
      convert({ numbers: ["minReplicas", "maxReplicas", "ttlMinutes"] }), ["configurationId", "resourceGroupId"]),
    model: resource("ModelDialog", "Models", ["scenarioId", "name"], convert({ numbers: ["sizeMiB"], lines: ["labels"] }),
      ["scenarioId", "executionId"]),
    dataset: resource("DatasetDialog", "Datasets", ["scenarioId", "name", "url"],
      convert({ numbers: ["sizeMiB"], lines: ["labels"] }), ["scenarioId"]),
    collection: resource("CollectionDialog", "PromptCollections", ["workspaceId", "name"], null, ["workspaceId"]),
    prompt: resource("PromptDialog", "Prompts", ["collectionId", "name", "userMessage"],
      convert({ numbers: ["temperature", "maxTokens", "topP"] }), ["collectionId"]),
    role: resource("RoleDialog", "Roles", ["id", "name", "scopes"], convert({ lists: ["scopes"] })),
    tile: resource("TileDialog", "Tiles", ["id", "title", "target"], convert({ numbers: ["sortOrder"] })),
    user: { fragment: "UserDialog", set: "Users", required: ["id"],
      patch: function (f) { return f.edit ? f.id : ""; },
      payload: function (f) {
        var result = { displayName: f.displayName, email: f.email, roles: models.list(f.roles), locked: !!f.locked };
        if (f.password) {
          result.password = f.password;
        }
        return f.edit ? result : compact(Object.assign(result, { id: f.id, password: f.password }));
      } }
  };
});
