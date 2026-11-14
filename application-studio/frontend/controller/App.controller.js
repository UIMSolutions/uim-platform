sap.ui.define([
  "uim/studio/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.studio.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
