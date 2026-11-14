sap.ui.define([
  "sap/ui/core/library"
], function (coreLibrary) {
  "use strict";

  var ValueState = coreLibrary.ValueState;

  var formatter = {
    /** Import / request / action status → semantic value state. */
    statusState: function (sStatus) {
      switch (sStatus) {
        case "success":
        case "enabled":
        case "connected":
          return ValueState.Success;
        case "warning":
        case "repeating":
        case "outdated":
          return ValueState.Warning;
        case "failed":
        case "disabled":
        case "unreachable":
          return ValueState.Error;
        case "running":
        case "initial":
          return ValueState.Information;
        default:
          return ValueState.None;
      }
    },

    /** Status → icon. */
    statusIcon: function (sStatus) {
      switch (sStatus) {
        case "success":
        case "enabled":
          return "sap-icon://status-positive";
        case "warning":
          return "sap-icon://status-critical";
        case "failed":
        case "disabled":
          return "sap-icon://status-negative";
        case "running":
          return "sap-icon://process";
        case "repeating":
          return "sap-icon://repost";
        case "initial":
          return "sap-icon://pending";
        default:
          return "";
      }
    },

    /** Node runtime → icon. */
    nodeTypeIcon: function (sType) {
      switch (sType) {
        case "cloudFoundry":
          return "sap-icon://cloud";
        case "abap":
          return "sap-icon://it-system";
        case "neo":
          return "sap-icon://it-host";
        case "kyma":
          return "sap-icon://overview-chart";
        default:
          return "sap-icon://chain-link";
      }
    },

    /** "cloudFoundry" → "Cloud Foundry", "mtaArchive" → "Mta Archive". */
    enumText: function (sValue) {
      if (!sValue) {
        return "";
      }
      var s = String(sValue).replace(/([a-z0-9])([A-Z])/g, "$1 $2");
      return s.charAt(0).toUpperCase() + s.slice(1);
    },

    /** "DEV" → "QA" */
    routeText: function (sSource, sDestination) {
      return (sSource || "?") + " → " + (sDestination || "?");
    },

    /** Only pending entries (initial / repeating) can be imported. */
    isPending: function (sStatus) {
      return sStatus === "initial" || sStatus === "repeating";
    },

    /** Finished entries can be reset. */
    isFinished: function (sStatus) {
      return sStatus === "success" || sStatus === "warning" || sStatus === "failed";
    }
  };

  return formatter;
});
