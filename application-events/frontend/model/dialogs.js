sap.ui.define([
  "uim/appevents/model/models"
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
    formation: resource("FormationDialog", "Formations", ["name"]),
    system: resource("SystemDialog", "Systems", ["name", "systemType"]),
    topic: resource("TopicDialog", "EventTypes", ["eventType"], null, ["eventType"]),
    channel: resource("ChannelDialog", "Channels", ["name", "channelType", "consumerSystemId"], function (p) {
      p = numbers(["maxSizeBytes"])(p);
      if (p.channelType === "queue") {
        p.endpoint = "";
      }
      return p;
    }, ["channelType", "consumerSystemId"]),
    subscription: resource("SubscriptionDialog", "Subscriptions",
      ["name", "producerSystemId", "consumerSystemId", "eventType", "channelId"],
      numbers(["maxRetries", "retryBackoffSeconds"]), ["producerSystemId", "consumerSystemId"]),
    filter: resource("FilterDialog", "Filters", ["subscriptionId", "attribute"], function (p) {
      if (p.operator === "exists") {
        p.value = "";
      }
      return p;
    }, ["subscriptionId"]),
    publish: { fragment: "PublishDialog", required: ["type", "source"], keepOpen: true,
      check: function (f) { return models.isJson(f.data); },
      action: function (f) { return f.preview ? "PreviewRouting" : "PublishEvent"; },
      payload: function (f) {
        var data = String(f.data || "").trim();
        return compact({ type: f.type.trim(), source: f.source, subject: f.subject, id: f.id,
          data: data && data !== "{\n  \n}" && data !== "{}" ? data : "" });
      } },
    assign: { fragment: "AssignDialog", action: "AssignSystem", required: ["id", "systemId"], toast: "systemAssigned",
      payload: function (f) { return { id: f.id, systemId: f.systemId }; },
      toastArgs: function (r) { return [r.name, r.formationName]; } },
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
