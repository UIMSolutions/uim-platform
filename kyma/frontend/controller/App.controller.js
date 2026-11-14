sap.ui.define([
  "uim/kyma/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.kyma.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
