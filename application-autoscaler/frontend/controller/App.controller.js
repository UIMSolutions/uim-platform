sap.ui.define([
  "uim/autoscaler/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.autoscaler.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getModel("device").getProperty("/support/touch")
        ? "sapUiSizeCozy" : "sapUiSizeCompact");
    }
  });
});
