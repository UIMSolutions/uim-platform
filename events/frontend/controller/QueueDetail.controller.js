sap.ui.define([
  "uim/eventmesh/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox"
], function (BaseController, Filter, FilterOperator, MessageBox) {
  "use strict";

  return BaseController.extend("uim.eventmesh.controller.QueueDetail", {
    onInit: function () {
      this.getRouter().getRoute("queue").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      this._id = event.getParameter("arguments").id;
      this.getView().bindElement({ path: "/Queues('" + encodeURIComponent(this._id) + "')" });
      var byQueue = new Filter("queueId", FilterOperator.EQ, this._id);
      ["detailSubscriptions", "detailMessages"].forEach(function (id) {
        var binding = this.byId(id).getBinding("items");
        binding.filter(byQueue);
        if (binding.isSuspended()) {
          binding.resume();
        }
      }, this);
    },

    onRefresh: function () {
      this.refreshAll();
    },

    onToggle: function (event) {
      var context = this.getView().getBindingContext();
      context.setProperty(event.getSource().data("property"), event.getParameter("state"))
        .then(this.refreshAll.bind(this), this.showError.bind(this));
    },

    onConsume: function () {
      this.invokeAction("ConsumeMessages", { queueId: this._id, maxMessages: 10 }).then(function (result) {
        var messages = (result && result.value) || [];
        if (messages.length === 0) {
          this.toast("queueEmpty");
          return;
        }
        MessageBox.information(messages.map(function (m) {
          return m.topic + "\n" + m.payload;
        }).join("\n\n"), { title: this.text("consumed", [messages.length]) });
      }.bind(this), this.showError.bind(this));
    },

    onPurge: function () {
      var name = this.getView().getBindingContext().getProperty("name");
      MessageBox.confirm(this.text("confirmPurge", [name]), {
        onClose: function (action) {
          if (action === MessageBox.Action.OK) {
            this.invokeAction("PurgeQueue", { queueId: this._id }).then(function (result) {
              this.toast("purged", [result.removed, name]);
            }.bind(this), this.showError.bind(this));
          }
        }.bind(this)
      });
    }
  });
});
