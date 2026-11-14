sap.ui.define([
  "uim/agentry/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.agentry.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
