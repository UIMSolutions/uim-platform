sap.ui.define([
  "uim/workzone/controller/BaseController"
], function (BaseController) {
  "use strict";

  var GROUPS = ["collaboration", "inbox", "integration", "sites", "administration"];

  return BaseController.extend("uim.workzone.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
      this.getRouter().attachRouteMatched(function (oEvent) {
        var oArgs = oEvent.getParameter("arguments") || {};
        var sName = oEvent.getParameter("name");
        this.getModel("ui").setProperty("/selectedNav",
          sName === "resource" ? oArgs.set : sName === "workspace" ? "Workspaces" : "overview");
      }, this);
    },

    navText: function (sKey) {
      return sKey ? this.getText(sKey) : "";
    },

    setTitle: function (sSet) {
      return sSet ? this.getText("set_" + sSet) : "";
    },

    onToggleSide: function () {
      var oUi = this.getModel("ui");
      oUi.setProperty("/sideExpanded", !oUi.getProperty("/sideExpanded"));
    },

    onNavSelect: function (oEvent) {
      var oItem = oEvent.getParameter("item");
      var sKey = oItem.getKey();
      if (GROUPS.indexOf(sKey) >= 0) {
        oItem.setExpanded(!oItem.getExpanded());
        return;
      }
      if (sKey === "overview") {
        this.getRouter().navTo("overview");
      } else {
        this.getRouter().navTo("resource", { set: sKey });
      }
    },

    onRefresh: function () {
      this.getModel().refresh();
    },

    /** POST /SeedContent — predefined roles, themes, page templates and tags. */
    onSeed: function () {
      this.run(this.service().invoke("SeedContent"), null).then(function (oResult) {
        if (oResult) {
          this.showToast("seeded", [oResult.created, oResult.skipped]);
        }
      }.bind(this));
    },

    /** POST /RunHousekeeping — overdue tasks, event status, expiry, provider syncs. */
    onHousekeeping: function () {
      this.run(this.service().invoke("RunHousekeeping"), null).then(function (oResult) {
        if (oResult) {
          this.showToast("housekept", [oResult.changed, oResult.examined]);
        }
      }.bind(this));
    },

    showToast: function (sKey, aArgs) {
      sap.ui.require(["sap/m/MessageToast"], function (MessageToast) {
        MessageToast.show(this.getText(sKey, aArgs));
      }.bind(this));
    }
  });
});
