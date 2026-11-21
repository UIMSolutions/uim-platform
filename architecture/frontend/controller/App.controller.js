sap.ui.define([
  "uim/architecture/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.architecture.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getModel("device").getProperty("/support/touch")
        ? "sapUiSizeCozy" : "sapUiSizeCompact");
    }
  });
});
