sap.ui.define([
  "uim/eventmesh/controller/BaseController",
  "uim/eventmesh/model/models",
  "sap/ui/core/Fragment",
  "sap/m/MessageBox"
], function (BaseController, models, Fragment, MessageBox) {
  "use strict";

  /** dialog key → fragment, target table, required form fields, payload builder */
  var DIALOGS = {
    service: {
      fragment: "CreateServiceDialog", table: "servicesTable", required: ["name", "namespace"],
      payload: function (f) { return f; }
    },
    queue: {
      fragment: "CreateQueueDialog", table: "queuesTable", required: ["serviceId", "name"],
      payload: function (f) {
        var p = Object.assign({}, f, {
          maxDepth: Number(f.maxDepth) || 0,
          messageTtlSeconds: String(Number(f.messageTtlSeconds) || 0), // Edm.Int64
          maxRedeliveryCount: Number(f.maxRedeliveryCount) || 0
        });
        if (!p.deadLetterQueueId) {
          delete p.deadLetterQueueId;
        }
        return p;
      }
    },
    subscription: {
      fragment: "CreateSubscriptionDialog", table: "subscriptionsTable", required: ["queueId", "topicPattern"],
      payload: function (f) { return f; }
    },
    webhook: {
      fragment: "CreateWebhookDialog", table: "webhooksTable", required: ["queueId", "name", "url"],
      payload: function (f) {
        var p = Object.assign({}, f);
        if (!p.credentials) {
          delete p.credentials;
        }
        return p;
      }
    },
    client: {
      fragment: "CreateClientDialog", table: "clientsTable", required: ["serviceId", "name"],
      payload: function (f) {
        var p = Object.assign({}, f);
        if (!p.permittedNamespace) {
          delete p.permittedNamespace;
        }
        return p;
      }
    },
    channel: {
      fragment: "CreateChannelDialog", table: "channelsTable", required: ["serviceId", "name", "topicName"],
      payload: function (f) { return f; }
    },
    binding: {
      fragment: "CreateBindingDialog", table: "bindingsTable", required: ["clientId"],
      payload: function (f) {
        var p = { clientId: f.clientId, permission: f.permission };
        if (f.target === "queue") {
          p.queueId = f.queueId;
        } else {
          p.channelId = f.channelId;
        }
        return p;
      }
    },
    publish: { fragment: "PublishEventDialog", required: ["topic", "payload"] }
  };

  return BaseController.extend("uim.eventmesh.controller.Main", {
    onInit: function () {
      this._dialogs = {};
      this.getRouter().getRoute("main").attachPatternMatched(function (event) {
        var tab = (event.getParameter("arguments") || {}).tab;
        if (tab) {
          this.getModel("view").setProperty("/tab", tab);
        }
      }, this);
    },

    onTabSelect: function (event) {
      this.getRouter().navTo("main", { tab: event.getParameter("key") }, true);
    },

    onRefresh: function () {
      this.refreshAll();
    },

    /** $search on the table named in the SearchField's customData. */
    onSearch: function (event) {
      var table = this.byId(event.getSource().data("table"));
      var query = event.getParameter("query");
      table.getBinding("items").changeParameters({ $search: query ? query : undefined });
    },

    onQueuePress: function (event) {
      this.getRouter().navTo("queue", { id: event.getSource().getBindingContext().getProperty("id") });
    },

    _selected: function (tableId) {
      var item = this.byId(tableId).getSelectedItem();
      if (!item) {
        this.toast("selectFirst");
        return null;
      }
      return item.getBindingContext();
    },

    // ── generic delete (QueueMessages: delete = acknowledge) ─────────────
    onDelete: function (event) {
      var context = this._selected(event.getSource().data("table"));
      if (!context) {
        return;
      }
      var name = context.getProperty("name") || context.getProperty("topicPattern") || context.getProperty("topic")
        || context.getProperty("id");
      MessageBox.confirm(this.text("confirmDelete", [name]), {
        onClose: function (action) {
          if (action !== MessageBox.Action.OK) {
            return;
          }
          context.delete().then(function () {
            this.toast("deleted", [name]);
            this.refreshAll();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    // ── dialogs ───────────────────────────────────────────────────────────
    _openDialog: function (key) {
      this._current = key;
      this.getModel("view").setProperty("/form/" + key, models.emptyForms()[key]);
      if (!this._dialogs[key]) {
        this._dialogs[key] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.eventmesh.fragment." + DIALOGS[key].fragment,
          controller: this
        }).then(function (dialog) {
          this.getView().addDependent(dialog);
          return dialog;
        }.bind(this));
      }
      this._dialogs[key].then(function (dialog) {
        this._openDialogControl = dialog;
        dialog.open();
      }.bind(this));
    },

    onOpenDialog: function (event) {
      this._openDialog(event.getSource().data("dialog"));
    },

    onOpenPublish: function () {
      this._openDialog("publish");
    },

    onCloseDialog: function () {
      if (this._openDialogControl) {
        this._openDialogControl.close();
      }
    },

    _form: function () {
      var key = this._current;
      var form = Object.assign({}, this.getModel("view").getProperty("/form/" + key));
      var missing = DIALOGS[key].required.some(function (name) {
        return !form[name];
      });
      if (missing) {
        this.toast("requiredMissing");
        return null;
      }
      return form;
    },

    /** POST a new entity through the list binding of the dialog's table. */
    onSave: function () {
      var form = this._form();
      if (!form) {
        return;
      }
      var def = DIALOGS[this._current];
      var payload = def.payload(form);
      var context = this.byId(def.table).getBinding("items").create(payload, true);
      this.setBusy(true);
      context.created().then(function () {
        this.onCloseDialog();
        this.toast("created", [payload.name || payload.topicPattern || payload.clientId]);
        this.refreshAll();
      }.bind(this), function (error) {
        if (!error.canceled) {
          this.showError(error);
        }
        context.delete().catch(function () { /* transient context already gone */ });
      }.bind(this)).finally(function () {
        this.setBusy(false);
      }.bind(this));
    },

    onPublish: function () {
      var form = this._form();
      if (!form) {
        return;
      }
      if (!form.serviceId && !form.clientId) {
        this.toast("serviceOrClient");
        return;
      }
      this.invokeAction("PublishEvent", form).then(function (result) {
        this.onCloseDialog();
        this.toast(result.delivered > 0 ? "published" : "publishedNoQueue", [result.topic, result.delivered,
          (result.rejectedQueueIds || []).length]);
      }.bind(this), this.showError.bind(this));
    },

    // ── actions ───────────────────────────────────────────────────────────
    onPurge: function () {
      var context = this._selected("queuesTable");
      if (!context) {
        return;
      }
      var name = context.getProperty("name");
      MessageBox.confirm(this.text("confirmPurge", [name]), {
        onClose: function (action) {
          if (action === MessageBox.Action.OK) {
            this.invokeAction("PurgeQueue", { queueId: context.getProperty("id") }).then(function (result) {
              this.toast("purged", [result.removed, name]);
            }.bind(this), this.showError.bind(this));
          }
        }.bind(this)
      });
    },

    onDeliver: function () {
      var context = this._selected("webhooksTable");
      if (!context) {
        return;
      }
      this.invokeAction("DeliverWebhook", { webhookId: context.getProperty("id") }).then(function (r) {
        this.toast("delivered", [r.webhookName, r.delivered, r.attempted, r.retried, r.deadLettered]);
      }.bind(this), this.showError.bind(this));
    },

    onWebhookStatus: function (event) {
      var context = this._selected("webhooksTable");
      if (!context) {
        return;
      }
      context.setProperty("status", event.getSource().data("status")).then(function () {
        this.refreshAll();
      }.bind(this), this.showError.bind(this));
    }
  });
});
