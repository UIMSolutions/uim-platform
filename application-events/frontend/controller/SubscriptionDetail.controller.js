sap.ui.define([
  "uim/appevents/controller/BaseController"
], function (BaseController) {
  "use strict";

  return BaseController.extend("uim.appevents.controller.SubscriptionDetail", {
    onInit: function () {
      this.getRouter().getRoute("subscription").attachPatternMatched(this.onMatched, this);
    },

    onMatched: function (event) {
      this.subscriptionId = event.getParameter("arguments").id;
      this.bindTo("Subscriptions", this.subscriptionId);
      this.filterTable("filtersTable", { subscriptionId: this.subscriptionId });
      this.filterTable("subscriptionMessagesTable", { subscriptionId: this.subscriptionId });
      this.filterTable("subscriptionDeadLettersTable", { subscriptionId: this.subscriptionId, status: "open" });
    },

    /** New filters belong to this subscription. */
    dialogPrefill: function (key) {
      return key === "filter" ? { subscriptionId: this.subscriptionId } : {};
    }
  });
});
