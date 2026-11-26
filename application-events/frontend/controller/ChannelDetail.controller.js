sap.ui.define([
  "uim/appevents/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (BaseController, Filter, FilterOperator) {
  "use strict";

  return BaseController.extend("uim.appevents.controller.ChannelDetail", {
    onInit: function () {
      this.getRouter().getRoute("channel").attachPatternMatched(this.onMatched, this);
    },

    onMatched: function (event) {
      this.channelId = event.getParameter("arguments").id;
      this.bindTo("Channels", this.channelId);
      this.filterTable("channelSubscriptionsTable", { channelId: this.channelId });
      this.applyFilters("channelMessagesTable", [new Filter("channelId", FilterOperator.EQ, this.channelId)]);
    },

    /** Queue channels: acknowledge the message of the pressed row (the consumer confirms receipt). */
    onAcknowledge: function (event) {
      var context = event.getSource().getBindingContext();
      this.invokeAction("AcknowledgeMessage", { id: context.getProperty("id") }).then(function (r) {
        this.toast("acknowledged", [r.eventType]);
      }.bind(this), this.showError.bind(this));
    }
  });
});
