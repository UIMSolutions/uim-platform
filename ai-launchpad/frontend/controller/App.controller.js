sap.ui.define([
  "uim/ailaunchpad/controller/BaseController"
], function (BaseController) {
  "use strict";

  /** The shell: ShellBar (home, back, user menu) around the pages of the router. */
  return BaseController.extend("uim.ailaunchpad.controller.App", {
    onInit: function () {
      this.getView().addStyleClass(this.getOwnerComponent().getModel("device").getProperty("/support/touch")
        ? "sapUiSizeCozy" : "sapUiSizeCompact");
    },

    onAvatarPressed: function (event) {
      this.onUserMenu(event);
    }
  });
});
