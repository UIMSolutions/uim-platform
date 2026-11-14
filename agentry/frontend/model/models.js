sap.ui.define([
  "sap/ui/model/json/JSONModel",
  "sap/ui/model/BindingMode",
  "sap/ui/Device"
], function (JSONModel, BindingMode, Device) {
  "use strict";

  return {
    createDeviceModel: function () {
      var oModel = new JSONModel(Device);
      oModel.setDefaultBindingMode(BindingMode.OneWay);
      return oModel;
    },

    /** Client-side view state (selected tab, busy flag, create-dialog draft). */
    createViewStateModel: function () {
      return new JSONModel({
        selectedTab: "overview",
        busy: false,
        draft: {}
      });
    }
  };
});
