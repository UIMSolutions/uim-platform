sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/routing/History",
  "sap/ui/core/Fragment",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "sap/base/strings/formatMessage",
  "uim/architecture/model/formatter",
  "uim/architecture/model/models"
], function (Controller, UIComponent, History, Fragment, MessageBox, MessageToast, formatMessage, formatter, models) {
  "use strict";

  var csrfToken = null;

  return Controller.extend("uim.architecture.controller.BaseController", {
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

    /** formatMessage("ABB {0} · SBB {1}", a, b) for composite bindings. */
    formatMessage: function (pattern) {
      return pattern ? formatMessage(pattern, Array.prototype.slice.call(arguments, 1)) : "";
    },

    /** "inDevelopment" → "In Development" (i18n). */
    statusText: function (status) {
      return status ? this.text("status_" + status) : "";
    },

    /** "solution" → "Solution (SBB)" (i18n). */
    kindText: function (kind) {
      return kind ? this.text("kind_" + kind) : "";
    },

    toast: function (key, args) {
      MessageToast.show(this.text(key, args));
    },

    /** Show the backend error (OData error message or HTTP status). */
    showError: function (error) {
      MessageBox.error((error && error.message) || this.text("unknownError"));
    },

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

    // ── backend access ────────────────────────────────────────────────────

    /**
     * Plain JSON request against the OData service (entity writes):
     * fetches the CSRF token once (required behind the approuter), resolves
     * with the parsed body, rejects with {message} from the OData error.
     */
    request: function (method, path, body) {
      var root = this.getOwnerComponent().getServiceUrl().replace(/\/$/, "");
      var send = function (retry) {
        var headers = { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": csrfToken || "Fetch" };
        return fetch(root + path, {
          method: method, headers: headers, credentials: "same-origin",
          body: body === undefined ? undefined : JSON.stringify(body)
        }).then(function (response) {
          var token = response.headers.get("X-CSRF-Token");
          if (token && token !== "Required") {
            csrfToken = token;
          }
          if (response.status === 403 && retry && response.headers.get("X-CSRF-Token") === "Required") {
            csrfToken = null;
            return send(false);
          }
          return response.text().then(function (text) {
            var data = text ? JSON.parse(text) : null;
            if (!response.ok) {
              var message = data && data.error && data.error.message;
              throw new Error(message || response.status + " " + response.statusText);
            }
            return data;
          });
        });
      };
      this.setBusy(true);
      return send(true).finally(function () {
        this.setBusy(false);
      }.bind(this));
    },

    /** Invoke an unbound OData action; resolves with the result object (or array). */
    invokeAction: function (name, parameters) {
      var operation = this.getModel().bindContext("/" + name + "(...)");
      Object.keys(parameters || {}).forEach(function (key) {
        if (parameters[key] !== "" && parameters[key] !== undefined && parameters[key] !== null) {
          operation.setParameter(key, parameters[key]);
        }
      });
      this.setBusy(true);
      return operation.execute().then(function () {
        return operation.getBoundContext().getObject();
      }).finally(function () {
        this.setBusy(false);
      }.bind(this));
    },

    // ── shared dialogs ────────────────────────────────────────────────────

    /** Lazily load a dialog fragment of this view. */
    dialog: function (name) {
      this._dialogs = this._dialogs || {};
      if (!this._dialogs[name]) {
        this._dialogs[name] = Fragment.load({
          id: this.getView().getId(), name: "uim.architecture.fragment." + name, controller: this
        }).then(function (dialog) {
          this.getView().addDependent(dialog);
          return dialog;
        }.bind(this));
      }
      return this._dialogs[name];
    },

    /** Open the building block dialog (row = edit, otherwise create). */
    openBlockDialog: function (row, kind) {
      this._editedRow = row || null;
      var form = row ? models.blockToForm(row) : models.emptyBlockForm(kind);
      this.getModel("view").setProperty("/blockForm", form);
      this.dialog("BlockDialog").then(function (d) { d.open(); });
    },

    onBlockDialogSave: function () {
      var form = this.getModel("view").getProperty("/blockForm");
      var payload = models.formToPayload(form, this._editedRow);
      var creating = form.mode === "create";
      var call = creating ? this.request("POST", "/BuildingBlocks", payload)
        : Object.keys(payload).length === 0 ? Promise.resolve(this._editedRow)
          : this.request("PATCH", models.entityPath("BuildingBlocks", form.id), payload);
      call.then(function (row) {
        this.dialog("BlockDialog").then(function (d) { d.close(); });
        this.refreshAll();
        if (creating) {
          this.toast("blockCreated", [row.name]);
          this.getRouter().navTo("block", { id: row.id });
        } else {
          this.toast("blockSaved");
        }
      }.bind(this)).catch(this.showError.bind(this));
    },

    onBlockDialogCancel: function () {
      this.dialog("BlockDialog").then(function (d) { d.close(); });
    },

    /** Open the relationship dialog, optionally with a given source. */
    openRelationshipDialog: function (sourceId) {
      this.getModel("view").setProperty("/relationshipForm", models.emptyRelationshipForm(sourceId));
      this.dialog("RelationshipDialog").then(function (d) { d.open(); });
    },

    onRelationshipDialogSave: function () {
      var form = this.getModel("view").getProperty("/relationshipForm");
      var payload = { type: form.type, sourceId: form.sourceId, targetId: form.targetId };
      if (form.description) {
        payload.description = form.description;
      }
      this.request("POST", "/Relationships", payload).then(function () {
        this.dialog("RelationshipDialog").then(function (d) { d.close(); });
        this.refreshAll();
        this.toast("relationshipCreated");
      }.bind(this)).catch(this.showError.bind(this));
    },

    onRelationshipDialogCancel: function () {
      this.dialog("RelationshipDialog").then(function (d) { d.close(); });
    },

    onDeleteRelationship: function (event) {
      var row = event.getSource().getBindingContext().getObject();
      this.confirm("confirmDeleteRelationship", [formatter.relationshipText(row.sourceName, row.type, row.targetName)])
        .then(function () {
          return this.request("DELETE", models.entityPath("Relationships", row.id));
        }.bind(this))
        .then(function () {
          this.refreshAll();
          this.toast("relationshipDeleted");
        }.bind(this))
        .catch(this.showError.bind(this));
    },

    /** Navigate to a building block from any list item bound to a row with "id" (or a given property). */
    onOpenBlock: function (event) {
      var source = event.getSource();
      var property = source.data("idProperty") || "id";
      var context = (event.getParameter("listItem") || source).getBindingContext();
      this.getRouter().navTo("block", { id: context.getProperty(property) });
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
