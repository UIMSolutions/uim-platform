sap.ui.define([
  "uim/datasphere/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.datasphere.controller.SpaceDetail", {
    onInit: function () {
      this.getRouter().getRoute("space").attachPatternMatched(this.onMatched, this);
    },

    onMatched: function (event) {
      this.spaceId = event.getParameter("arguments").id;
      this.bindTo("Spaces", this.spaceId);
      ["membersTable", "spaceTablesTable", "spaceViewsTable", "spaceRunsTable"].forEach(function (id) {
        this.filterTable(id, { spaceId: this.spaceId });
      }.bind(this));
    },

    /** New members belong to this space. */
    dialogPrefill: function (key) {
      return key === "member" ? { spaceId: this.spaceId } : {};
    }
  });
});
