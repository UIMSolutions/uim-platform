sap.ui.define([
  "sap/ui/model/json/JSONModel",
  "sap/ui/Device"
], function (JSONModel, Device) {
  "use strict";

  return {
    createDeviceModel: function () {
      var model = new JSONModel(Device);
      model.setDefaultBindingMode("OneWay");
      return model;
    },

    /** UI state: forms of the create dialogs and the selected tab. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "instances",
        newInstance: { name: "", planId: "", platformId: "", parameters: "", shared: false },
        newBinding: { name: "", instanceId: "" },
        newBroker: { name: "", brokerUrl: "", description: "", credentials: "" },
        newPlatform: { name: "", type: "cloudFoundry", region: "", description: "" },
        newLabel: { key: "", value: "" }
      });
    }
  };
});
