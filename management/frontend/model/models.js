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

    /** Client-side view state: selected tab, busy flag and the drafts of the create dialogs. */
    createViewStateModel: function () {
      return new JSONModel({
        selectedTab: "overview",
        busy: false,
        draft: {}
      });
    },

    /** Empty drafts for the create dialogs (keyed by entity set). */
    emptyDraft: function (sEntitySet, oDefaults) {
      var mDrafts = {
        GlobalAccounts: {
          displayName: "", description: "", region: "eu10", licenseType: "enterprise",
          contractNumber: "", companyName: "", contactEmail: "", costCenter: "",
          maxSubaccounts: 100, maxDirectories: 20
        },
        Directories: {
          globalAccountId: "", parentDirectoryId: "", displayName: "", description: "",
          manageEntitlements: false, manageAuthorizations: false
        },
        Subaccounts: {
          globalAccountId: "", parentDirectoryId: "", displayName: "", description: "",
          subdomain: "", region: "eu10", usage: "development", betaEnabled: false, usedForProduction: false
        },
        Entitlements: {
          globalAccountId: "", subaccountId: "", servicePlanId: "", quotaAssigned: 1, unlimited: false, autoAssign: false
        },
        Environments: {
          globalAccountId: "", subaccountId: "", name: "", description: "", environmentType: "cloudFoundry",
          planName: "standard", landscapeLabel: "cf-eu10", memoryQuotaMb: 1024, routeQuota: 10, serviceQuota: 10
        },
        Subscriptions: {
          globalAccountId: "", subaccountId: "", appName: "", planName: "default"
        },
        ServicePlans: {
          serviceName: "", serviceDisplayName: "", planName: "", planDisplayName: "", description: "",
          category: "service", pricingModel: "free", isFree: true, isBeta: false, maxQuota: 0, unit: "instances"
        },
        Labels: {
          resourceType: "subaccount", resourceId: "", key: "", valuesText: ""
        }
      };
      return Object.assign({}, mDrafts[sEntitySet] || {}, oDefaults || {});
    }
  };
});
