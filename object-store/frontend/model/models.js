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

    /** Client-side view state: selected tab, busy flag, tools, browser and the generic create dialog. */
    createViewStateModel: function () {
      return new JSONModel({
        busy: false,
        selectedTab: "overview",
        tools: {
          access: { bucketId: "", principal: "", action: "read", key: "", result: null },
          cors: { bucketId: "", origin: "https://app.example.com", method: "GET", requestHeaders: "", result: null },
          credentials: { accessKeyId: "", secretAccessKey: "", result: null }
        },
        browser: { bucketId: "", bucketName: "", prefix: "", crumbs: [], rows: [], selected: null },
        create: { title: "", set: "", fields: [] },
        credentials: { accessKeyId: "", secretAccessKey: "", bucketName: "", endpoint: "" }
      });
    }
  };
});
