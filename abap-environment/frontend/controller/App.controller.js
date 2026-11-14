sap.ui.define([
  "uim/abap/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.abap.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
