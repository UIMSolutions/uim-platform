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

    /** Empty forms of the create dialogs. */
    emptyForms: function () {
      return {
        service: { name: "", namespace: "", plan: "standard", region: "", description: "" },
        queue: { serviceId: "", name: "", description: "", accessType: "nonExclusive", maxDepth: 0, messageTtlSeconds: 0,
          maxRedeliveryCount: 3, deadLetterQueueId: "" },
        subscription: { queueId: "", topicPattern: "", description: "" },
        webhook: { queueId: "", name: "", url: "", authenticationType: "none", credentials: "", deliveryMode: "atLeastOnce" },
        client: { serviceId: "", name: "", protocol: "httprest", permittedNamespace: "", description: "" },
        channel: { serviceId: "", name: "", topicName: "", channelType: "topic", description: "" },
        binding: { clientId: "", target: "queue", queueId: "", channelId: "", permission: "publishSubscribe" },
        publish: { serviceId: "", clientId: "", topic: "", payload: "{\n  \"id\": \"1\"\n}", contentType: "application/json" }
      };
    },

    /** UI state: forms of the create dialogs and the selected tab. */
    createViewModel: function () {
      return new JSONModel({
        busy: false,
        tab: "queues",
        form: this.emptyForms()
      });
    }
  };
});
