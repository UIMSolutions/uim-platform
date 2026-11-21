sap.ui.define([
  "uim/aicore/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.aicore.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getModel("device").getProperty("/support/touch")
        ? "sapUiSizeCozy" : "sapUiSizeCompact");
    }
  });
});
