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

    /** Empty forms of the dialogs. Lists (days) are edited as one entry per line or comma separated. */
    emptyForms: function () {
      return {
        binding: { id: "", name: "", appGuid: "", serviceInstanceId: "", description: "", policyId: "", currentInstances: 1, edit: false },
        policy: { id: "", name: "", description: "", instanceMinCount: 1, instanceMaxCount: 5, timezone: "UTC",
          customMetricAllowFrom: "sameApp", edit: false },
        rule: { id: "", policyId: "", metricType: "cpu", customMetricName: "", operator: ">=", threshold: 80,
          breachDurationSeconds: 120, coolDownSeconds: 300, adjustment: "+1", enabled: true, edit: false },
        schedule: { id: "", policyId: "", name: "", kind: "recurring", startTime: "08:00", endTime: "18:00",
          daysOfWeek: "1, 2, 3, 4, 5", daysOfMonth: "", startDate: "", endDate: "", startDateTime: "", endDateTime: "",
          instanceMinCount: 1, instanceMaxCount: 5, initialMinInstanceCount: 0, enabled: true, edit: false },
        scale: { id: "", name: "", current: 1, instances: 1, max: 1000, reason: "" },
        metric: { bindingId: "", name: "", metricName: "cpu", value: 0, unit: "" },
        simulate: { bindingId: "", name: "", metricName: "cpu", value: 90, durationSeconds: 180, stepSeconds: 30 },
        attach: { id: "", name: "", policyId: "" },
        user: { id: "", displayName: "", password: "", scopes: "Read", edit: false }
      };
    },

    /** UI state: selected tab and filters, dialog forms, the last evaluation result. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "bindings",
        bindingFilter: "",
        eventFilter: "",
        password: { current: "", next: "", repeat: "" },
        result: null,
        form: this.emptyForms()
      });
    },

    /** "1, 2\n 3,," → ["1", "2", "3"] */
    lines: function (text) {
      if (Array.isArray(text)) {
        return text;
      }
      return String(text || "").split(/[\n,;]/).map(function (s) { return s.trim(); }).filter(Boolean);
    },

    /** Path of an entity with a string key: "/Bindings('shop')" */
    entityPath: function (set, key) {
      return "/" + set + "('" + String(key).replace(/'/g, "''") + "')";
    },

    /** Standard metric types (custom → customMetricName). */
    metricTypes: ["cpu", "cpuutil", "memoryused", "memoryutil", "disk", "diskutil", "throughput", "responsetime", "custom"],

    /** True for metrics measured in percent. */
    isPercentMetric: function (type) {
      return ["cpu", "cpuutil", "memoryutil", "diskutil"].indexOf(type) >= 0;
    }
  };
});
