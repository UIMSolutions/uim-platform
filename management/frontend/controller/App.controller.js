sap.ui.define([
  "uim/management/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.management.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
