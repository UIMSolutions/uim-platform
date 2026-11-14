sap.ui.define([
  "sap/ui/model/json/JSONModel",
  "sap/ui/Device"
], function (JSONModel, Device) {
  "use strict";

  return {
    createDeviceModel: function () {
      var oModel = new JSONModel(Device);
      oModel.setDefaultBindingMode("OneWay");
      return oModel;
    },

    /** Client-side view state: selected tab, busy flag, translator workbench and the generic create dialog. */
    createViewStateModel: function () {
      return new JSONModel({
        busy: false,
        selectedTab: "overview",
        translator: {
          sourceLanguage: "en",
          targetLanguage: "de",
          provider: "machineMt",
          domainName: "",
          textType: "uiText",
          input: "Save\nCancel\nInvoice not found",
          results: [],
          summary: ""
        },
        create: { title: "", set: "", fields: [] }
      });
    }
  };
});
