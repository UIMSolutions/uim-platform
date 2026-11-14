sap.ui.define([
  "uim/authorization/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.authorization.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
