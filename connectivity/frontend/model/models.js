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

    /** Client-side view state: selected tab, busy flag and the generic create dialog. */
    createViewStateModel: function () {
      return new JSONModel({
        busy: false,
        selectedTab: "overview",
        create: { title: "", set: "", fields: [] }
      });
    }
  };
});
