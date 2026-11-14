sap.ui.define([
  "uim/auditlog/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.auditlog.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getContentDensityClass());
    }
  });
});
