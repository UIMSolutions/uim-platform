sap.ui.define([
  "uim/integrationautomation/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.integrationautomation.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getModel("device").getProperty("/support/touch")
        ? "sapUiSizeCozy" : "sapUiSizeCompact");
    }
  });
});
