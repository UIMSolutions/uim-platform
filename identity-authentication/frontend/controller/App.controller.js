sap.ui.define([
  "uim/ias/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.ias.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
