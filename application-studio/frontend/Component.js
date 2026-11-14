sap.ui.define([
  "sap/ui/core/UIComponent",
  "sap/ui/Device",
  "uim/studio/model/models"
], function (UIComponent, Device, models) {
  "use strict";

  return UIComponent.extend("uim.studio.Component", {
    metadata: {
      manifest: "json",
      interfaces: ["sap.ui.core.IAsyncContentCreation"]
    },

    init: function () {
      UIComponent.prototype.init.apply(this, arguments);
      this.setModel(models.createDeviceModel(), "device");
      this.setModel(models.createViewStateModel(), "ui");
      this.getRouter().initialize();
    },

    /** "sapUiSizeCompact" on desktop, "sapUiSizeCozy" on touch devices. */
    getContentDensityClass: function () {
      if (this._sDensity === undefined) {
        this._sDensity = Device.support.touch ? "sapUiSizeCozy" : "sapUiSizeCompact";
      }
      return this._sDensity;
    }
  });
});
