sap.ui.define([
  "uim/ailaunchpad/controller/BaseController"
], function (BaseController) {
  "use strict";

  /** AI runtimes: workspaces, connections (validation) and resource groups. */
  return BaseController.extend("uim.ailaunchpad.controller.Runtimes", {
    onInit: function () {
      this.attachPage("runtimes", "runtimesTitle", "workspaces");
    }
  });
});
