sap.ui.define([
  "uim/translation/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.translation.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
