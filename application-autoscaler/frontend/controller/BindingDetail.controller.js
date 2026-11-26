sap.ui.define([
  "uim/autoscaler/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.autoscaler.controller.BindingDetail", {
    onInit: function () {
      this.getRouter().getRoute("binding").attachPatternMatched(this.onMatched, this);
    },

    onMatched: function (event) {
      this.bindingId = event.getParameter("arguments").id;
      this.bindTo("Bindings", this.bindingId);
      this.filterTable("bindingEventsTable", { bindingId: this.bindingId });
      this.filterTable("bindingSamplesTable", { bindingId: this.bindingId });
    }
  });
});
