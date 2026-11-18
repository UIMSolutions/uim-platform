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

    /** Client-side view state: selected tab, busy flag, the generic create/edit dialog and the preview dialog. */
    createViewStateModel: function () {
      return new JSONModel({
        busy: false,
        selectedTab: "overview",
        jobLogScope: "last",
        edit: { title: "", set: "", mode: "create", path: "", fields: [] },
        preview: {
          id: "",
          name: "",
          entityType: "user",
          input: "userName=Ada.Lovelace\nemail=Ada.Lovelace@ACME.com\ndepartment=Engineering\nactive=true",
          result: null
        }
      });
    }
  };
});
