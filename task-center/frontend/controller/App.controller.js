sap.ui.define([
  "uim/taskcenter/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.taskcenter.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getModel("device").getProperty("/support/touch")
        ? "sapUiSizeCozy" : "sapUiSizeCompact");
    }
  });
});
