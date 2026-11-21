sap.ui.define([
  "sap/ui/core/UIComponent",
  "uim/architecture/model/models"
], function (UIComponent, models) {
  "use strict";

  return UIComponent.extend("uim.architecture.Component", {
    metadata: {
      manifest: "json",
      interfaces: ["sap.ui.core.IAsyncContentCreation"]
    },

    init: function () {
      UIComponent.prototype.init.apply(this, arguments);
      this.setModel(models.createDeviceModel(), "device");
      this.setModel(models.createViewModel(), "view");
      this.getRouter().initialize();
    },

    /** Service root of the OData model, e.g. "/odata/v4/architecture/". */
    getServiceUrl: function () {
      return this.getManifestEntry("/sap.app/dataSources/mainService/uri");
    }
  });
});
