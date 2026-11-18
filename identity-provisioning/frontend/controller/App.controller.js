sap.ui.define([
  "uim/identityprovisioning/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.identityprovisioning.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
