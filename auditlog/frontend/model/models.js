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

    /** Client-side view state (selected tab, busy flags, new-policy draft). */
    createViewStateModel: function () {
      return new JSONModel({
        selectedTab: "overview",
        busy: false,
        newPolicy: { name: "", description: "", retentionDays: 90, categories: [], isDefault: false },
        newExport: { format: "json", categories: [] }
      });
    }
  };
});
