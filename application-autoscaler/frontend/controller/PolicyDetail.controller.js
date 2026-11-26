sap.ui.define([
  "uim/autoscaler/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.autoscaler.controller.PolicyDetail", {
    onInit: function () {
      this.getRouter().getRoute("policy").attachPatternMatched(this.onMatched, this);
    },

    onMatched: function (event) {
      this.policyId = event.getParameter("arguments").id;
      this.bindTo("Policies", this.policyId);
      this.filterTable("rulesTable", { policyId: this.policyId });
      this.filterTable("schedulesTable", { policyId: this.policyId });
      this.filterTable("policyBindingsTable", { policyId: this.policyId });
    },

    /** New rules and schedules belong to this policy; schedules start with the policy's limits. */
    dialogPrefill: function (key) {
      var p = this.getView().getBindingContext();
      if (key === "rule") {
        return { policyId: this.policyId };
      }
      if (key === "schedule") {
        return { policyId: this.policyId, instanceMinCount: p ? p.getProperty("instanceMinCount") : 1,
          instanceMaxCount: p ? p.getProperty("instanceMaxCount") : 5 };
      }
      return {};
    },

    onEditPolicy: function () {
      var p = this.getView().getBindingContext().getObject();
      var form = {};
      ["id", "name", "description", "instanceMinCount", "instanceMaxCount", "timezone", "customMetricAllowFrom"].forEach(function (n) {
        form[n] = p[n];
      });
      form.edit = true;
      this.openDialog("policy", form);
    },

    /** Days are collections: edit them as comma separated text. */
    onEditSchedule: function () {
      var context = this.selected("schedulesTable");
      if (!context) {
        return;
      }
      var s = context.getObject();
      var form = {};
      Object.keys(this.getModel("view").getProperty("/form/schedule")).forEach(function (n) {
        if (s[n] !== undefined && s[n] !== null) {
          form[n] = Array.isArray(s[n]) ? s[n].join(", ") : s[n];
        }
      });
      form.edit = true;
      this.openDialog("schedule", form);
    },

    /** Copy (inactive) and open the copy. */
    onCopy: function () {
      this.invokeAction("CopyPolicy", { id: this.policyId }).then(function (r) {
        this.toast("policyCopied", [r.name]);
        this.getRouter().navTo("policy", { id: r.id });
      }.bind(this), this.showError.bind(this));
    }
  });
});
