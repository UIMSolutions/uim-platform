sap.ui.define([
  "uim/objectstore/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.objectstore.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
