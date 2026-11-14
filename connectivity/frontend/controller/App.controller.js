sap.ui.define([
  "uim/connectivity/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.connectivity.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
