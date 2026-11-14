sap.ui.define([
  "sap/ui/core/UIComponent",
  "uim/taskcenter/model/models"
], function (UIComponent, models) {
  "use strict";

  return UIComponent.extend("uim.taskcenter.Component", {
    metadata: {
      manifest: "json",
      interfaces: ["sap.ui.core.IAsyncContentCreation"]
    },

    init: function () {
      UIComponent.prototype.init.apply(this, arguments);
      this.setModel(models.createDeviceModel(), "device");
      var view = models.createViewModel();
      this.setModel(view, "view");
      // Local development (open mode): the backend takes the user from X-User-Id.
      // Behind the approuter the XSUAA token identifies the user instead.
      this.applyUser(view.getProperty("/user"));
      this.getRouter().initialize();
    },

    /** Act as another user (local development only). */
    applyUser: function (user) {
      var model = this.getModel();
      if (model && model.changeHttpHeaders) {
        model.changeHttpHeaders({ "X-User-Id": user || null });
      }
      models.rememberUser(user);
    }
  });
});
