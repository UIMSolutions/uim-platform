sap.ui.define([
  "uim/servicemanager/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.servicemanager.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getModel("device").getProperty("/support/touch")
        ? "sapUiSizeCozy" : "sapUiSizeCompact");
    }
  });
});
