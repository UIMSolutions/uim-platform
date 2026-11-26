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

    /** Empty forms of the dialogs (the keys of model/dialogs). */
    emptyForms: function () {
      return {
        formation: { id: "", name: "", description: "", globalAccountId: "", edit: false },
        system: { id: "", name: "", description: "", systemType: "both", systemUrl: "", formationId: "", edit: false },
        topic: { id: "", eventType: "", title: "", description: "", category: "", version: "1.0.0", ownerSystemId: "",
          edit: false },
        channel: { id: "", name: "", description: "", channelType: "webhook", endpoint: "", consumerSystemId: "",
          deliveryMode: "atLeastOnce", maxSizeBytes: 1048576, edit: false },
        subscription: { id: "", name: "", description: "", producerSystemId: "", consumerSystemId: "", eventType: "",
          channelId: "", maxRetries: 5, retryBackoffSeconds: 30, edit: false },
        filter: { id: "", subscriptionId: "", filterType: "include", attribute: "data.", operator: "equals", value: "",
          active: true, description: "", edit: false },
        publish: { type: "", source: "", subject: "", id: "", data: "{\n  \n}", preview: false },
        assign: { id: "", name: "", systemId: "" },
        user: { id: "", displayName: "", password: "", scopes: "Read", edit: false }
      };
    },

    /** UI state: selected tab and filters, dialog forms. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "subscriptions",
        messageFilter: "",
        deadLetterFilter: "open",
        password: { current: "", next: "", repeat: "" },
        form: this.emptyForms()
      });
    },

    /** "1, 2\n 3,," → ["1", "2", "3"] */
    lines: function (text) {
      if (Array.isArray(text)) {
        return text;
      }
      return String(text || "").split(/[\n,;]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** Path of an entity with a string key: "/Subscriptions('bp')" */
    entityPath: function (set, key) {
      return "/" + set + "('" + String(key).replace(/'/g, "''") + "')";
    },

    /** Pretty print a JSON payload; anything else as is. */
    prettyJson: function (text) {
      if (!text) {
        return "";
      }
      try {
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch (e) {
        return String(text);
      }
    },

    /** True if the text is empty or valid JSON. */
    isJson: function (text) {
      if (!text || !String(text).trim()) {
        return true;
      }
      try {
        JSON.parse(text);
        return true;
      } catch (e) {
        return false;
      }
    },

    /** Event type pattern matching as on the server ('*' = one segment; trailing '*' = the rest). */
    matchesEventType: function (pattern, type) {
      if (pattern === "*") {
        return true;
      }
      var p = String(pattern || "").split(".");
      var t = String(type || "").split(".");
      for (var i = 0; i < p.length; i++) {
        if (p[i] === "*" && i === p.length - 1) {
          return t.length > i;
        }
        if (i >= t.length || (p[i] !== "*" && p[i] !== t[i])) {
          return false;
        }
      }
      return p.length === t.length;
    }
  };
});
