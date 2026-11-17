sap.ui.define([
  "sap/ui/core/UIComponent",
  "sap/ui/Device",
  "uim/workzone/model/models"
], function (UIComponent, Device, models) {
  "use strict";

  return UIComponent.extend("uim.workzone.Component", {
    metadata: {
      manifest: "json",
      interfaces: ["sap.ui.core.IAsyncContentCreation"]
    },

    init: function () {
      UIComponent.prototype.init.apply(this, arguments);
      this.setModel(models.createDeviceModel(), "device");
      this.setModel(models.createViewStateModel(), "ui");
      this.setModel(models.createNavigationModel(), "nav");
      // Resource catalogue (fields, columns, actions) — drives tables and forms
      this._pCatalog = models.loadCatalog(this.getManifestObject().resolveUri("api/v1/resources"),
        sap.ui.require.toUrl("uim/workzone/localService/mockdata/resources.json")).then(function (oCatalog) {
        this.setModel(oCatalog, "catalog");
        return oCatalog;
      }.bind(this));
      this.getRouter().initialize();
    },

    /** Resolves with the catalogue JSON model once it is loaded. */
    catalogLoaded: function () {
      return this._pCatalog;
    },

    /** Absolute URL of the OData service root (ends with "/"). */
    getServiceUrl: function () {
      return this.getModel().getServiceUrl();
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
