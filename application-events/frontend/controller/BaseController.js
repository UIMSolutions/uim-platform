sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/routing/History",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "sap/ui/core/Fragment",
  "uim/appevents/model/formatter",
  "uim/appevents/model/models",
  "uim/appevents/model/session",
  "uim/appevents/model/dialogs"
], function (Controller, UIComponent, History, Filter, FilterOperator, MessageBox, MessageToast, Fragment, formatter, models,
  session, DIALOGS) {
  "use strict";

  return Controller.extend("uim.appevents.controller.BaseController", {
    formatter: formatter,

    getRouter: function () {
      return UIComponent.getRouterFor(this);
    },

    getModel: function (name) {
      return this.getView().getModel(name);
    },

    text: function (key, args) {
      return this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(key, args);
    },

    toast: function (key, args) {
      MessageToast.show(this.text(key, args));
    },

    /** Show the backend error; an expired session (401) leads back to the login. */
    showError: function (error) {
      if (error && error.status === 401 && this.getModel("session").getProperty("/loginRequired")) {
        MessageBox.warning(this.text("sessionExpired"), {
          onClose: function () { this.getOwnerComponent().logout(); }.bind(this)
        });
        return;
      }
      MessageBox.error((error && error.message) || this.text("unknownError"));
    },

    // ── session (built-in JWT login) ───────────────────────────────────────
    onUserMenu: function (event) {
      var button = event.getSource();
      if (!this._userMenu) {
        this._userMenu = Fragment.load({ id: this.getView().getId(), name: "uim.appevents.fragment.UserMenu", controller: this })
          .then(function (menu) {
            this.getView().addDependent(menu);
            return menu;
          }.bind(this));
      }
      this._userMenu.then(function (menu) { menu.openBy(button); });
    },

    onLogout: function () {
      this.getOwnerComponent().logout();
    },

    onChangePassword: function () {
      if (!this._passwordDialog) {
        this._passwordDialog = Fragment.load({ id: this.getView().getId(), name: "uim.appevents.fragment.PasswordDialog",
          controller: this }).then(function (dialog) {
          this.getView().addDependent(dialog);
          return dialog;
        }.bind(this));
      }
      this.getModel("view").setProperty("/password", { current: "", next: "", repeat: "" });
      this._passwordDialog.then(function (dialog) { dialog.open(); });
    },

    onSavePassword: function () {
      var p = this.getModel("view").getProperty("/password");
      if (!p.current || !p.next) {
        this.toast("requiredMissing");
        return;
      }
      if (p.next !== p.repeat) {
        this.toast("passwordMismatch");
        return;
      }
      session.changePassword(this.getModel("session").getProperty("/token"), p.current, p.next).then(function () {
        this._passwordDialog.then(function (dialog) { dialog.close(); });
        this.toast("passwordChanged");
      }.bind(this), this.showError.bind(this));
    },

    onClosePassword: function () {
      this._passwordDialog.then(function (dialog) { dialog.close(); });
    },

    // ── helpers ────────────────────────────────────────────────────────────
    /** Re-read everything (lists, the Statistics header, the detail page). */
    refreshAll: function () {
      this.getModel().refresh();
    },

    setBusy: function (busy) {
      this.getModel("view").setProperty("/busy", busy);
    },

    /** OK/Cancel confirmation; resolves only on OK. */
    confirm: function (key, args) {
      return new Promise(function (resolve) {
        MessageBox.confirm(this.text(key, args), {
          onClose: function (action) {
            if (action === MessageBox.Action.OK) {
              resolve();
            }
          }
        });
      }.bind(this));
    },

    /** Invoke an unbound OData action and refresh on success; resolves with the result. */
    invokeAction: function (name, parameters) {
      var operation = this.getModel().bindContext("/" + name + "(...)");
      Object.keys(parameters || {}).forEach(function (key) {
        if (parameters[key] !== "" && parameters[key] !== undefined && parameters[key] !== null) {
          operation.setParameter(key, parameters[key]);
        }
      });
      this.setBusy(true);
      return operation.execute().then(function () {
        this.refreshAll();
        return operation.getBoundContext().getObject();
      }.bind(this)).finally(function () {
        this.setBusy(false);
      }.bind(this));
    },

    /** Apply filters to the items of a (possibly suspended) table and resume it. */
    applyFilters: function (tableId, filters) {
      var binding = this.byId(tableId).getBinding("items");
      binding.filter(filters);
      if (binding.isSuspended()) {
        binding.resume();
      }
    },

    /** EQ filters from {property: value}; empty values are skipped. */
    eqFilters: function (values) {
      return Object.keys(values).filter(function (name) {
        return values[name] !== "" && values[name] !== undefined && values[name] !== null;
      }).map(function (name) {
        return new Filter(name, FilterOperator.EQ, values[name]);
      });
    },

    filterTable: function (tableId, values) {
      this.applyFilters(tableId, this.eqFilters(values));
    },

    /** $search on the table named in the SearchField's customData. */
    onSearch: function (event) {
      var table = this.byId(event.getSource().data("table"));
      var query = event.getParameter("query");
      table.getBinding("items").changeParameters({ $search: query ? query : undefined });
    },

    /** Bind the view to "/<set>('<key>')". */
    bindTo: function (set, key) {
      this.getView().bindElement({ path: models.entityPath(set, key) });
    },

    // ── dialogs ─────────────────────────────────────────────────────────────
    dialogs: function () {
      return DIALOGS;
    },

    /** Prefill of a dialog opened from a toolbar (override). */
    dialogPrefill: function () {
      return {};
    },

    /** Open the dialog of a form key: reset the form to its defaults plus prefill, load the fragment once. */
    openDialog: function (key, prefill) {
      var def = this.dialogs()[key];
      this._dialogs = this._dialogs || {};
      this._current = key;
      this.getModel("view").setProperty("/form/" + key, Object.assign(models.emptyForms()[key], prefill || {}));
      if (!this._dialogs[key]) {
        this._dialogs[key] = Fragment.load({
          id: this.getView().getId(),
          name: "uim.appevents.fragment." + def.fragment,
          controller: this
        }).then(function (dialog) {
          this.getView().addDependent(dialog);
          return dialog;
        }.bind(this));
      }
      return this._dialogs[key].then(function (dialog) {
        this._openDialogControl = dialog;
        dialog.open();
        return dialog;
      }.bind(this));
    },

    onOpenDialog: function (event) {
      var key = event.getSource().data("dialog");
      this.openDialog(key, this.dialogPrefill(key));
    },

    onCloseDialog: function () {
      if (this._openDialogControl) {
        this._openDialogControl.close();
      }
    },

    /** Edit the selected row in its dialog (customData: table, dialog): copy the matching members. */
    onEdit: function (event) {
      var source = event.getSource();
      var context = this.selected(source.data("table"));
      if (!context) {
        return;
      }
      this.editRow(source.data("dialog"), context.getObject());
    },

    /** Edit the object of a detail page (customData: dialog). */
    onEditObject: function (event) {
      var context = this.getView().getBindingContext();
      if (context) {
        this.editRow(event.getSource().data("dialog"), context.getObject());
      }
    },

    editRow: function (dialog, row) {
      var form = models.emptyForms()[dialog];
      Object.keys(form).forEach(function (name) {
        if (row[name] !== undefined && row[name] !== null) {
          form[name] = Array.isArray(row[name]) ? row[name].join("\n") : row[name];
        }
      });
      form.edit = true;
      this.openDialog(dialog, form);
    },

    /** The current form, or null (toast) if a required field is empty. */
    currentForm: function () {
      var key = this._current;
      var form = Object.assign({}, this.getModel("view").getProperty("/form/" + key));
      var missing = (this.dialogs()[key].required || []).some(function (name) {
        return form[name] === "" || form[name] === undefined || form[name] === null;
      });
      if (missing) {
        this.toast("requiredMissing");
        return null;
      }
      return form;
    },

    /**
     * Save the current dialog: an entity create (def.set) through a
     * separate, unrendered list binding, a PATCH of an existing entity
     * (def.patch) or an action (def.action). Closes and refreshes on success
     * (def.keepOpen: the result is shown by dialogResult).
     */
    onSave: function () {
      var form = this.currentForm();
      if (!form) {
        return;
      }
      var key = this._current;
      var def = this.dialogs()[key];
      if (def.check && !def.check(form)) {
        this.toast(key === "publish" ? "invalidJson" : "requiredMissing");
        return;
      }
      var done = function (result) {
        result = result || {};
        if (def.keepOpen) {
          this.dialogResult(key, result, form);
          return;
        }
        this.onCloseDialog();
        this.toast(def.toast || "saved", def.toastArgs ? def.toastArgs(result, form) : []);
        this.refreshAll();
      }.bind(this);
      var action = typeof def.action === "function" ? def.action(form) : def.action;
      if (action) {
        this.invokeAction(action, def.payload(form)).then(done, this.showError.bind(this));
        return;
      }
      if (def.patch && def.patch(form)) {
        var serviceUrl = this.getOwnerComponent().getManifestEntry("/sap.app/dataSources/mainService").uri;
        this.setBusy(true);
        session.patch(serviceUrl, models.entityPath(def.set, def.patch(form)), def.payload(form),
          this.getModel("session").getProperty("/token"))
          .then(done, this.showError.bind(this)).finally(function () {
            this.setBusy(false);
          }.bind(this));
        return;
      }
      var binding = this.getModel().bindList("/" + def.set);
      var created = binding.create(def.payload(form), true);
      this.setBusy(true);
      created.created().then(function () {
        done(created.getObject());
      }, function (error) {
        if (!error.canceled) {
          this.showError(error);
        }
        created.delete().catch(function () { /* transient context already gone */ });
      }.bind(this)).finally(function () {
        this.setBusy(false);
        binding.destroy();
      }.bind(this));
    },

    /** Dialogs that keep their result: the publish result is shown in a message box. */
    dialogResult: function (key, result, form) {
      if (key !== "publish") {
        return;
      }
      if (!form.preview) {
        this.onCloseDialog();
      }
      var text = result.summary + (result.outcomes ? "\n\n" + result.outcomes : "") + (result.notes ? "\n\n" + result.notes : "");
      var title = this.text(form.preview ? "previewTitle" : "publishedTitle", [result.eventId]);
      var box = result.deadLettered > 0 ? MessageBox.warning : result.routed > 0 ? MessageBox.success : MessageBox.information;
      box(text, { title: title });
    },

    /** Selected row context of a table, or null (toast). */
    selected: function (tableId) {
      var item = this.byId(tableId).getSelectedItem();
      if (!item) {
        this.toast("selectFirst");
        return null;
      }
      return item.getBindingContext();
    },

    /** Delete the selected row of the table named in the button's customData. */
    onDelete: function (event) {
      var context = this.selected(event.getSource().data("table"));
      if (!context) {
        return;
      }
      var name = context.getProperty("name") || context.getProperty("title") || context.getProperty("summary")
        || context.getProperty("id");
      this.confirm("confirmDelete", [name]).then(function () {
        return context.delete().then(function () {
          this.toast("deleted");
          this.refreshAll();
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    // ── operations ──────────────────────────────────────────────────────────
    /** The context of the pressed button's row, the selected row of a table (customData table) or the page object. */
    targetContext: function (event) {
      var source = event.getSource();
      var tableId = source.data && source.data("table");
      if (tableId) {
        return this.selected(tableId);
      }
      var own = source.getBindingContext();
      var page = this.getView().getBindingContext();
      return own && (!page || own.getPath() !== page.getPath()) && own.getPath().indexOf("(") > 0 ? own : page;
    },

    /**
     * Action on the selected row of a table or on the bound object of a
     * detail view (customData: table (optional), action, status (optional),
     * toast, confirm (optional i18n key)).
     */
    onOperation: function (event) {
      var source = event.getSource();
      var context = this.targetContext(event);
      if (!context) {
        return;
      }
      var parameters = { id: context.getProperty("id") };
      if (source.data("status")) {
        parameters.status = source.data("status");
      }
      var run = function () {
        return this.invokeAction(source.data("action"), parameters).then(function (r) {
          r = r || {};
          var name = r.name || r.title || r.subscriptionName || r.eventType || r.id || r.messageId;
          var status = this.formatter.enumText.call(this, r.status);
          this.toast(source.data("toast") || "done", [name, status, r.message || ""]);
        }.bind(this), this.showError.bind(this));
      }.bind(this);
      if (source.data("confirm")) {
        var label = context.getProperty("name") || context.getProperty("eventType") || context.getProperty("id");
        this.confirm(source.data("confirm"), [label]).then(run);
      } else {
        run();
      }
    },

    /** Pause or resume the subscription of the row / page. */
    onPauseResume: function (event) {
      var context = this.targetContext(event);
      if (!context) {
        return;
      }
      var paused = context.getProperty("status") === "paused";
      this.invokeAction(paused ? "ResumeSubscription" : "PauseSubscription", { id: context.getProperty("id") })
        .then(function (r) {
          this.toast(paused ? "resumed" : "paused", [r.name]);
        }.bind(this), this.showError.bind(this));
    },

    /** Publish (or preview) an event; prefilled from a subscription or event type when available. */
    onPublish: function (event) {
      var source = event.getSource();
      var context = source.data("table") ? null : this.getView().getBindingContext();
      var prefill = { preview: source.data("preview") === "true" };
      if (context) {
        var o = context.getObject();
        if (o.producerSystemId) {
          prefill.source = o.producerSystemId;
          prefill.type = o.eventType && o.eventType.indexOf("*") < 0 ? o.eventType : "";
        }
      }
      this.openDialog("publish", prefill);
    },

    /** Switch the publish dialog to preview and run it. */
    onPreviewPublish: function () {
      this.getModel("view").setProperty("/form/publish/preview", true);
      this.onSave();
    },

    onSendPublish: function () {
      this.getModel("view").setProperty("/form/publish/preview", false);
      this.onSave();
    },

    /** Deliver all due messages now. */
    onDispatch: function () {
      this.invokeAction("DispatchDue", {}).then(function (r) {
        MessageBox.information(this.text("dispatchText", [r.due, r.attempted, r.delivered, r.queued, r.retrying,
          r.deadLettered, r.dropped, r.waiting]) + (r.messages ? "\n\n" + r.messages : ""), { title: this.text("dispatch") });
      }.bind(this), this.showError.bind(this));
    },

    /** Attempt the selected / pressed message now. */
    onDeliver: function (event) {
      var context = this.targetContext(event);
      if (!context) {
        return;
      }
      this.invokeAction("DeliverMessage", { id: context.getProperty("id") }).then(this.showDelivery.bind(this),
        this.showError.bind(this));
    },

    /** Requeue the selected / pressed dead letter. */
    onRequeue: function (event) {
      var context = this.targetContext(event);
      if (!context) {
        return;
      }
      this.invokeAction("RequeueDeadLetter", { id: context.getProperty("id") }).then(this.showDelivery.bind(this),
        this.showError.bind(this));
    },

    /** Requeue every open dead letter (of the subscription of the page, if any). */
    onRequeueAll: function () {
      var context = this.getView().getBindingContext();
      var subscription = context && context.getPath().indexOf("/Subscriptions(") === 0 ? context.getProperty("id") : "";
      this.confirm("confirmRequeueAll").then(function () {
        this.invokeAction("RequeueDeadLetters", { subscriptionId: subscription }).then(function (r) {
          this.toast("requeuedAll", [r.attempted, r.delivered, r.deadLettered]);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    showDelivery: function (r) {
      var text = this.text("deliveryText", [this.formatter.enumText.call(this, r.status), r.attempts, r.message || ""]);
      var box = r.status === "delivered" || r.status === "queued" ? MessageBox.success
        : r.status === "retrying" ? MessageBox.warning : MessageBox.error;
      box(text, { title: r.subscriptionName || r.messageId });
    },

    /** Show the payload (CloudEvent data) of a message / dead letter row. */
    onShowPayload: function (event) {
      var context = this.targetContext(event);
      if (!context) {
        return;
      }
      var o = context.getObject();
      var details = this.text("payloadHeader", [o.eventType, o.eventId, o.subject || "–"]);
      MessageBox.information(details + "\n\n" + (models.prettyJson(o.payload) || this.text("noPayload")),
        { title: this.text("payload"), contentWidth: "40rem" });
    },

    onSubscriptionPress: function (event) {
      var context = event.getSource().getBindingContext();
      var own = context.getPath().indexOf("/Subscriptions(") === 0;
      var id = context.getProperty(own ? "id" : "subscriptionId");
      if (id) {
        this.getRouter().navTo("subscription", { id: id });
      }
    },

    onChannelPress: function (event) {
      var context = event.getSource().getBindingContext();
      var own = context.getPath().indexOf("/Channels(") === 0;
      var id = context.getProperty(own ? "id" : "channelId");
      if (id) {
        this.getRouter().navTo("channel", { id: id });
      }
    },

    onNavBack: function () {
      if (History.getInstance().getPreviousHash() !== undefined) {
        window.history.go(-1);
      } else {
        this.getRouter().navTo("main", {}, true);
      }
    },

    onRefresh: function () {
      this.refreshAll();
    }
  });
});
