sap.ui.define([
  "uim/dataquality/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.dataquality.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getModel("device").getProperty("/support/touch")
        ? "sapUiSizeCozy" : "sapUiSizeCompact");
    }
  });
});
