sap.ui.define([
  "uim/transport/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.transport.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
