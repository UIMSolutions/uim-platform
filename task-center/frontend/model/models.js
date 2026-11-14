sap.ui.define([
  "sap/ui/model/json/JSONModel",
  "sap/ui/Device"
], function (JSONModel, Device) {
  "use strict";

  var USER_KEY = "uim.taskcenter.user";

  function storedUser() {
    try {
      return window.localStorage.getItem(USER_KEY) || "anna";
    } catch (e) {
      return "anna";
    }
  }

  return {
    createDeviceModel: function () {
      var model = new JSONModel(Device);
      model.setDefaultBindingMode("OneWay");
      return model;
    },

    /** Empty forms of the create dialogs. */
    emptyForms: function () {
      return {
        task: { title: "", definitionId: "", assignee: "", priority: "", dueDate: null, description: "" },
        provider: { name: "", providerType: "s4hana", status: "inactive", authType: "none", endpointUrl: "",
          authEndpointUrl: "", clientId: "", clientSecret: "", description: "" },
        definition: { name: "", providerId: "", category: "approval", defaultPriority: "medium", dueInDays: 0,
          allowedActions: "", requiresClaim: false, description: "" },
        substitution: { userId: "", substituteId: "", definitionId: "", startDate: null, endDate: null, isAutoForward: true },
        filter: { name: "", criteria: "assignee=$me,status=open", isDefault: false, description: "" },
        forward: { forwardTo: "", comment: "" },
        decision: { action: "", comment: "" }
      };
    },

    /** UI state: acting user, inbox scope, selected filter, dialog forms. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "inbox",
        user: storedUser(),
        scope: "mine", // mine | all
        filter: "", // OData $filter of the selected saved filter
        detail: { can: {} }, // actions the acting user may perform on the open task
        form: this.emptyForms()
      });
    },

    rememberUser: function (user) {
      try {
        window.localStorage.setItem(USER_KEY, user || "");
      } catch (e) { /* storage blocked: keep the session value */ }
    }
  };
});
