sap.ui.define([], function () {
  "use strict";

  var MESSAGE_STATES = { pending: "Information", retrying: "Warning", queued: "Information", delivered: "Success",
    deadLettered: "Error", dropped: "Error" };
  var MESSAGE_ICONS = { pending: "sap-icon://pending", retrying: "sap-icon://refresh", queued: "sap-icon://inbox",
    delivered: "sap-icon://accept", deadLettered: "sap-icon://message-error", dropped: "sap-icon://decline" };
  var HEALTH_STATES = { ok: "Success", warning: "Warning", error: "Error" };
  var HEALTH_ICONS = { ok: "sap-icon://status-positive", warning: "sap-icon://status-critical", error: "sap-icon://status-negative" };
  var STATUS_STATES = { active: "Success", paused: "Warning", inactive: "None", draining: "Warning", deprecated: "Warning",
    retired: "Error", open: "Error", requeued: "Success", discarded: "None" };
  var CHANNEL_ICONS = { webhook: "sap-icon://world", queue: "sap-icon://inbox" };
  var SYSTEM_ICONS = { producer: "sap-icon://outbox", consumer: "sap-icon://inbox", both: "sap-icon://synchronize" };

  var bundle = null;

  return {
    /** Set by tests for texts of enumerations outside views. */
    setBundle: function (b) { bundle = b; },

    messageState: function (s) { return MESSAGE_STATES[s] || "None"; },
    messageIcon: function (s) { return MESSAGE_ICONS[s] || ""; },
    healthState: function (h) { return HEALTH_STATES[h] || "None"; },
    healthIcon: function (h) { return HEALTH_ICONS[h] || ""; },
    statusState: function (s) { return STATUS_STATES[s] || "None"; },
    channelIcon: function (t) { return CHANNEL_ICONS[t] || "sap-icon://chain-link"; },
    systemIcon: function (t) { return SYSTEM_ICONS[t] || "sap-icon://it-system"; },

    /** Text of an enumeration value from i18n ("enum_<value>"), else the value. */
    enumText: function (value) {
      if (value === undefined || value === null || value === "") {
        return "";
      }
      var key = "enum_" + value;
      var text = this && this.getOwnerComponent ? this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(key)
        : bundle ? bundle.getText(key) : key;
      return text === key ? String(value) : text;
    },

    /** "2 / 6" attempts */
    attempts: function (attempts, max) {
      return (Number(attempts) || 0) + " / " + (Number(max) || 0);
    },

    /** "producer → consumer" */
    route: function (producer, consumer) {
      return (producer || "?") + " → " + (consumer || "?");
    },

    /** 1048576 → "1 MiB", 2048 → "2 KiB", 300 → "300 B" */
    bytes: function (n) {
      var v = Number(n) || 0;
      if (v >= 1048576 && v % 1048576 === 0) {
        return v / 1048576 + " MiB";
      }
      if (v >= 1024) {
        return Math.round(v / 102.4) / 10 + " KiB";
      }
      return v + " B";
    },

    /** The last segments of a long event type: "…BusinessPartner.Created.v1" */
    shortType: function (type) {
      var parts = String(type || "").split(".");
      return parts.length > 3 ? "…" + parts.slice(-3).join(".") : String(type || "");
    },

    /** Pretty printed JSON payload. */
    json: function (text) {
      if (!text) {
        return "";
      }
      try {
        return JSON.stringify(JSON.parse(text), null, 2);
      } catch (e) {
        return String(text);
      }
    },

    /** Value state of a JSON payload text ("" is valid: no data). */
    payloadState: function (text) {
      if (!text || !String(text).trim()) {
        return "None";
      }
      try {
        JSON.parse(text);
        return "None";
      } catch (e) {
        return "Error";
      }
    },

    /** Visible only if both flags are set. */
    and: function (a, b) {
      return !!a && !!b;
    }
  };
});
