sap.ui.define([
  "uim/datasphere/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.datasphere.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getModel("device").getProperty("/support/touch")
        ? "sapUiSizeCozy" : "sapUiSizeCompact");
    }
  });
});
