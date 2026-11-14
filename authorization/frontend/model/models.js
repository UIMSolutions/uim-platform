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

    /** Client-side view state: selected tab, drafts of the create dialogs and the check form. */
    createViewStateModel: function () {
      return new JSONModel({
        selectedTab: "applications",
        busy: false,
        draft: {},
        check: {
          principalId: "alice",
          groups: "",
          application: "incident-management",
          resource: "Incident",
          action: "Read",
          attributes: "country=US",
          record: true
        },
        checkResult: null
      });
    },

    /** Empty drafts for the create dialogs (keyed by entity set). */
    emptyDraft: function (sEntitySet, oDefaults) {
      var mDrafts = {
        Applications: { name: "", organizationId: "global", description: "" },
        ApplicationApis: { applicationId: "", name: "", endpoint: "", operationsText: "Read" },
        Policies: { applicationId: "", name: "", description: "", resource: "*", action: "Read", conditions: "" },
        Assignments: { policyId: "", principalType: "user", principalId: "", validFrom: null, validTo: null }
      };
      return Object.assign({}, mDrafts[sEntitySet] || {}, oDefaults || {});
    }
  };
});
