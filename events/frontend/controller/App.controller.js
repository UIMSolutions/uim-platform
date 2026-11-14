sap.ui.define([
  "uim/eventmesh/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.eventmesh.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getModel("device").getProperty("/support/touch")
        ? "sapUiSizeCozy" : "sapUiSizeCompact");
    }
  });
});
