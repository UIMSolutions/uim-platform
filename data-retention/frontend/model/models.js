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

    /** Empty forms of the dialogs. Lists are edited as one entry per line. */
    emptyForms: function () {
      return {
        applicationGroup: { id: "", name: "", description: "", scope: "global", applicationIds: "", active: true, edit: false },
        legalEntity: { id: "", name: "", description: "", country: "", region: "", active: true, edit: false },
        dataSubjectRole: { id: "", name: "", description: "", active: true, edit: false },
        businessPurpose: { id: "", name: "", description: "", applicationGroupId: "", dataSubjectRoleId: "", legalEntityId: "",
          edit: false },
        legalGround: { id: "", businessPurposeId: "", name: "", description: "", type: "contract", legalReference: "",
          active: true, edit: false },
        residenceRule: { id: "", businessPurposeId: "", legalGroundId: "", duration: 1, periodUnit: "years", active: true,
          edit: false },
        retentionRule: { id: "", businessPurposeId: "", legalGroundId: "", duration: 10, periodUnit: "years",
          actionOnExpiry: "delete", active: true, edit: false },
        dataSubject: { id: "", externalId: "", displayName: "", businessPurposeId: "", legalGroundId: "", applicationGroupId: "",
          dataSubjectRoleId: "", legalEntityId: "", referenceDate: "", edit: false },
        deletionRequest: { dataSubjectId: "", action: "delete", reason: "" },
        archivingJob: { applicationGroupId: "", operation: "archiveAndDestruct", dryRun: true, referenceBefore: "", scheduledAt: "" },
        legalHold: { id: "", legalHold: true, reason: "" },
        check: { applicationGroupId: "", simulate: true },
        simulate: { businessPurposeId: "", legalGroundId: "", referenceDate: "", result: null },
        user: { id: "", displayName: "", password: "", scopes: "Read", edit: false }
      };
    },

    /** UI state: selected tab and filters, dialog forms. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "subjects",
        group: "",
        lifecycle: "",
        password: { current: "", next: "", repeat: "" },
        form: this.emptyForms()
      });
    },

    /** "a\n b,\n\n" → ["a", "b"] */
    lines: function (text) {
      return String(text || "").split(/[\n,]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** Path of an entity with a string key: "/DataSubjects('ds-1')" */
    entityPath: function (set, key) {
      return "/" + set + "('" + String(key).replace(/'/g, "''") + "')";
    },

    /** DatePicker value (yyyy-MM-dd) → Edm.DateTimeOffset at midnight UTC ("" stays ""). */
    dateTime: function (date) {
      return date ? date + "T00:00:00Z" : "";
    }
  };
});
