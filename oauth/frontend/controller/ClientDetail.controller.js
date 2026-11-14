sap.ui.define([
  "uim/oauth/controller/BaseController",
  "uim/oauth/model/models",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/ui/core/Messaging",
  "sap/m/ColumnListItem",
  "sap/m/Text",
  "sap/m/ObjectStatus",
  "sap/m/FlexBox"
], function (BaseController, models, Filter, FilterOperator, Messaging, ColumnListItem, Text, ObjectStatus, FlexBox) {
  "use strict";

  var GROUP = "clientEdit";

  return BaseController.extend("uim.oauth.controller.ClientDetail", {
    onInit: function () {
      this.getRouter().getRoute("client").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      var id = event.getParameter("arguments").id;
      this.getModel().resetChanges(GROUP);
      this.getView().bindElement({
        path: "/OAuthClients('" + encodeURIComponent(id) + "')",
        parameters: { $$updateGroupId: GROUP }
      });
      this._loadEditState();
    },

    /** Lists are edited as text / multi selections in the view model. */
    _loadEditState: function () {
      var context = this.getView().getBindingContext();
      if (!context) {
        this.getView().getElementBinding().attachEventOnce("change", this._loadEditState, this);
        return;
      }
      context.requestObject().then(function (client) {
        this._original = {
          grantTypes: client.grantTypes || [],
          allowedScopes: client.allowedScopes || [],
          redirectUris: client.redirectUris || [],
          contacts: client.contacts || []
        };
        this.getModel("view").setProperty("/edit", {
          grantTypes: this._original.grantTypes.slice(),
          allowedScopes: this._original.allowedScopes.slice(),
          redirectUris: this._original.redirectUris.join("\n"),
          contacts: this._original.contacts.join("\n")
        });
        this._bindTokens(client.clientId);
      }.bind(this), this.showError.bind(this));
    },

    _bindTokens: function (clientId) {
      var formatter = this.formatter;
      this.byId("clientTokensTable").bindItems({
        path: "/AccessTokens",
        parameters: { $orderby: "issuedAt desc" },
        filters: [new Filter("clientId", FilterOperator.EQ, clientId)],
        template: new ColumnListItem({
          cells: [
            new Text({ text: "{userId}" }),
            new Text({ text: { path: "grantType", formatter: formatter.enumText } }),
            new ObjectStatus({
              text: { path: "status", formatter: formatter.enumText },
              state: { path: "status", formatter: formatter.statusState }
            }),
            // collection-valued property: list binding, one tag per scope
            new FlexBox({
              wrap: "Wrap",
              items: {
                path: "scopes",
                templateShareable: false,
                template: new ObjectStatus({ text: { path: "", targetType: "any" }, inverted: true, state: "Indication05" })
                  .addStyleClass("sapUiTinyMarginEnd")
              }
            }),
            new Text({ text: "{expiresAt}" })
          ]
        })
      });
    },

    /**
     * Scalar fields are two-way bound to the V4 context (update group
     * "clientEdit"). UI5 1.120 cannot set collection-valued properties through
     * a context ("Not a primitive value"), so changed lists are sent first as
     * one JSON PATCH (with the model's headers, i.e. the CSRF token).
     */
    onSave: function () {
      var context = this.getView().getBindingContext();
      var edit = this.getModel("view").getProperty("/edit");
      var lists = {
        grantTypes: edit.grantTypes,
        allowedScopes: edit.allowedScopes,
        redirectUris: models.lines(edit.redirectUris),
        contacts: models.lines(edit.contacts)
      };
      var changed = {};
      Object.keys(lists).forEach(function (key) {
        if (JSON.stringify(lists[key]) !== JSON.stringify(this._original[key])) {
          changed[key] = lists[key];
        }
      }, this);
      Messaging.removeAllMessages();
      this.setBusy(true);
      this._patchLists(context.getProperty("id"), changed).then(function () {
        return this.getModel().submitBatch(GROUP);
      }.bind(this)).then(function () {
        if (this.getModel().hasPendingChanges(GROUP)) {
          var errors = Messaging.getMessageModel().getData().filter(function (m) { return m.getType() === "Error"; });
          throw new Error(errors.length ? errors[errors.length - 1].getMessage() : this.text("saveFailed"));
        }
        this.toast("saved");
        this.refreshAll();
        this._loadEditState();
      }.bind(this)).catch(this.showError.bind(this)).finally(function () {
        this.setBusy(false);
      }.bind(this));
    },

    _patchLists: function (id, changed) {
      if (Object.keys(changed).length === 0) {
        return Promise.resolve();
      }
      var model = this.getModel();
      var headers = Object.assign({}, model.getHttpHeaders(), {
        "Content-Type": "application/json",
        "Accept": "application/json"
      });
      return fetch(model.getServiceUrl() + "OAuthClients('" + encodeURIComponent(id) + "')", {
        method: "PATCH", headers: headers, credentials: "same-origin", body: JSON.stringify(changed)
      }).then(function (response) {
        if (response.ok) {
          return undefined;
        }
        return response.json().catch(function () { return {}; }).then(function (body) {
          throw new Error((body.error && body.error.message) || response.statusText);
        });
      });
    },

    onCancel: function () {
      this.getModel().resetChanges(GROUP);
      this._loadEditState();
      this.onNavBack();
    },

    onRotateSecret: function () {
      var context = this.getView().getBindingContext();
      this.confirm("confirmRotate", [context.getProperty("name")]).then(function () {
        return this.invokeAction("RotateClientSecret", { id: context.getProperty("id") }).then(function (r) {
          this.showSecret(r.clientId, r.clientSecret, r.revokedTokens);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    },

    onRevokeTokens: function () {
      var context = this.getView().getBindingContext();
      this.confirm("confirmRevokeClient", [context.getProperty("name")]).then(function () {
        return this.invokeAction("RevokeClientTokens", { id: context.getProperty("id") }).then(function (r) {
          this.toast("revokedCounts", [r.accessTokens, r.refreshTokens, r.codes]);
        }.bind(this), this.showError.bind(this));
      }.bind(this));
    }
  });
});
