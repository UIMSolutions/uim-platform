sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/ui/core/Fragment",
  "sap/ui/core/Item",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "sap/m/Dialog",
  "sap/m/Button",
  "sap/m/Label",
  "sap/m/Input",
  "sap/m/TextArea",
  "sap/m/VBox",
  "sap/m/Select",
  "sap/m/Switch",
  "sap/m/MultiComboBox",
  "sap/m/DatePicker",
  "uim/objectstore/model/formatter",
  "uim/objectstore/model/fields"
], function (Controller, UIComponent, Fragment, Item, MessageBox, MessageToast, Dialog, Button, Label, Input,
  TextArea, VBox, Select, Switch, MultiComboBox, DatePicker, formatter, fields) {
  "use strict";

  /** Relative REST root (works locally and behind the approuter). */
  var REST = "api/v1/object-store";

  return Controller.extend("uim.objectstore.controller.BaseController", {
    formatter: formatter,

    getRouter: function () {
      return UIComponent.getRouterFor(this);
    },

    getModel: function (sName) {
      return this.getView().getModel(sName);
    },

    getText: function (sKey, aArgs) {
      return this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(sKey, aArgs);
    },

    /** URL of the content API for a key (download link). */
    contentUrl: function (sBucketId, sKey, iVersion, bDownload) {
      var sPath = sKey.split("/").map(encodeURIComponent).join("/");
      var aQuery = [];
      if (iVersion) { aQuery.push("version=" + iVersion); }
      if (bDownload) { aQuery.push("download=true"); }
      return REST + "/content/" + encodeURIComponent(sBucketId) + "/" + sPath + (aQuery.length ? "?" + aQuery.join("&") : "");
    },

    /** GET a REST resource as JSON. */
    getJson: function (sPath) {
      return fetch(REST + sPath, { headers: { Accept: "application/json" }, credentials: "same-origin" })
        .then(function (oResponse) {
          return oResponse.json().then(function (oBody) {
            if (!oResponse.ok) {
              throw new Error((oBody.error && oBody.error.message) || oResponse.statusText);
            }
            return oBody;
          });
        });
    },

    /** Show an OData / backend error. */
    showError: function (oError) {
      if (oError && oError.canceled) {
        return;
      }
      var sMessage = (oError && (oError.message || oError.statusText)) || String(oError);
      MessageBox.error(sMessage);
    },

    /** Invoke an unbound OData action with parameters; resolves with the returned object. */
    invokeAction: function (sAction, mParameters) {
      var oOperation = this.getModel().bindContext("/" + sAction + "(...)");
      Object.keys(mParameters || {}).forEach(function (sName) {
        oOperation.setParameter(sName, mParameters[sName]);
      });
      return oOperation.execute().then(function () {
        return oOperation.getBoundContext().getObject();
      });
    },

    /**
     * Ask for action parameters ("targetBucketId,targetKey") and resolve with
     * { name: value }. Resolves immediately when there are none; rejects with
     * { canceled: true } on cancel.
     */
    askParameters: function (sTitle, sParameters, mDefaults) {
      var aNames = (sParameters || "").split(",").map(function (s) { return s.trim(); }).filter(Boolean);
      if (!aNames.length) {
        return Promise.resolve({});
      }
      var that = this;
      return new Promise(function (resolve, reject) {
        var mInputs = {};
        var aItems = [];
        aNames.forEach(function (sName) {
          var oInput = new Input({ value: (mDefaults || {})[sName] || "", placeholder: that.getText("param_" + sName + "_hint") });
          mInputs[sName] = oInput;
          aItems.push(new Label({ text: that.getText("param_" + sName), labelFor: oInput }), oInput);
        });
        var bDone = false;
        var oDialog = new Dialog({
          title: sTitle,
          contentWidth: "28rem",
          content: [new VBox({ items: aItems }).addStyleClass("sapUiSmallMargin")],
          beginButton: new Button({ text: that.getText("ok"), type: "Emphasized", press: function () {
            var mValues = {};
            aNames.forEach(function (sName) {
              var sValue = mInputs[sName].getValue().trim();
              if (sValue) {
                mValues[sName] = sValue;
              }
            });
            bDone = true;
            oDialog.close();
            resolve(mValues);
          } }),
          endButton: new Button({ text: that.getText("cancel"), press: function () { oDialog.close(); } }),
          afterClose: function () {
            oDialog.destroy();
            if (!bDone) {
              reject({ canceled: true });
            }
          }
        });
        that.getView().addDependent(oDialog);
        oDialog.open();
      });
    },

    /** Refresh the KPI header (Statistics singleton), if the view has one. */
    refreshStatistics: function () {
      var oHeader = this.byId("kpiHeader");
      var oBinding = oHeader && oHeader.getElementBinding();
      if (oBinding) {
        oBinding.refresh();
      }
    },

    // ── Generic create dialog ───────────────────────────────────────────

    /** Open the create dialog of an entity set; mDefaults pre-fills (and hides) fields. */
    onCreate: function (sSet, mDefaults) {
      var aFields = fields.CREATE_FIELDS[sSet].map(function (f) {
        var oField = Object.assign({ type: "text", value: "", required: false, options: [], hint: "" }, f, {
          label: f.label ? this.getText(f.label) : f.name,
          hint: f.hint ? this.getText(f.hint) : "",
          options: (f.options || []).map(function (o) { return { key: o, text: formatter.enumText(o) }; })
        });
        if (mDefaults && mDefaults[f.name] !== undefined) {
          oField.value = mDefaults[f.name];
        }
        return oField;
      }.bind(this));
      this.getModel("ui").setProperty("/create", {
        set: sSet,
        title: this.getText("createTitle", [this.getText(fields.SETS[sSet].type)]),
        fields: aFields
      });
      if (!this._pCreateDialog) {
        this._pCreateDialog = Fragment.load({
          id: this.getView().getId(),
          name: "uim.objectstore.fragment.CreateDialog",
          controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      this._pCreateDialog.then(function (oDialog) { oDialog.open(); });
    },

    /** Factory of the create dialog: label + control bound to ui>value. */
    createField: function (sId, oContext) {
      var oField = oContext.getObject();
      var oControl;
      switch (oField.type) {
        case "hidden":
          return new VBox(sId, { visible: false });
        case "select":
          oControl = new Select({ selectedKey: "{ui>value}", width: "100%",
            items: { path: "ui>options", template: new Item({ key: "{ui>key}", text: "{ui>text}" }), templateShareable: false } });
          break;
        case "multi":
          oControl = new MultiComboBox({ selectedKeys: "{ui>value}", width: "100%",
            items: { path: "ui>options", template: new Item({ key: "{ui>key}", text: "{ui>text}" }), templateShareable: false } });
          break;
        case "region":
          oControl = new Select({ selectedKey: "{ui>value}", width: "100%", forceSelection: false,
            items: { path: "/Regions", parameters: { $orderby: "provider,id" },
              template: new Item({ key: "{id}", text: "{id} – {name} ({provider})" }), templateShareable: false } });
          oControl.insertItem(new Item({ key: "", text: this.getText("defaultRegion") }), 0);
          break;
        case "textarea":
          oControl = new TextArea({ value: "{ui>value}", width: "100%", rows: 5, growing: true });
          break;
        case "switch":
          oControl = new Switch({ state: "{ui>value}" });
          break;
        case "date":
          oControl = new DatePicker({ value: "{ui>value}", valueFormat: "yyyy-MM-dd", width: "100%" });
          break;
        default:
          oControl = new Input({ value: "{ui>value}", placeholder: oField.hint,
            type: oField.type === "number" || oField.type === "bytes" ? "Number" : "Text" });
      }
      return new VBox(sId, {
        items: [new Label({ text: oField.label, required: oField.required, labelFor: oControl }), oControl]
      }).addStyleClass("sapUiSmallMarginBottom");
    },

    onSaveCreate: function () {
      var oDraft = this.getModel("ui").getProperty("/create");
      var oData = {};
      var aMissing = [];
      oDraft.fields.forEach(function (f) {
        var v = f.value;
        var bEmpty = v === "" || v === undefined || v === null || (Array.isArray(v) && !v.length);
        if (f.required && bEmpty) {
          aMissing.push(f.label);
          return;
        }
        if (bEmpty && f.type !== "switch") {
          return;
        }
        oData[f.name] = fields.toPayload(f);
      });
      if (aMissing.length) {
        MessageBox.warning(this.getText("required", [aMissing.join(", ")]));
        return;
      }
      var sType = this.getText(fields.SETS[oDraft.set].type);
      this.createEntity(oDraft.set, oData).then(function (oCreated) {
        MessageToast.show(this.getText("created", [sType]));
        this.showCredentials(oCreated);
        this.onCreated(oDraft.set);
      }.bind(this), this.showError.bind(this));
      this.onCancelCreate();
    },

    /** Create an entity through the list binding of its table; resolves with the created data. */
    createEntity: function (sSet, oData) {
      if (sSet === "ServiceBindings") {
        // the one-time secret is only in the POST response, which the v4 cache does not keep
        return this.postEntity(sSet, oData).then(function (oCreated) {
          this.byId(fields.SETS[sSet].table).getBinding("items").refresh();
          return oCreated;
        }.bind(this));
      }
      var oContext = this.byId(fields.SETS[sSet].table).getBinding("items").create(oData);
      return oContext.created().then(function () {
        return oContext.getObject();
      });
    },

    /** POST an entity directly (CSRF token fetched first, as the approuter requires); resolves with the response. */
    postEntity: function (sSet, oData) {
      var sUrl = this.getModel().getServiceUrl() + sSet;
      return fetch(sUrl, { method: "HEAD", headers: { "X-CSRF-Token": "Fetch" }, credentials: "same-origin" })
        .then(function (oHead) {
          return fetch(sUrl, {
            method: "POST",
            credentials: "same-origin",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json;odata.metadata=minimal;IEEE754Compatible=true",
              "X-CSRF-Token": oHead.headers.get("X-CSRF-Token") || ""
            },
            body: JSON.stringify(oData)
          });
        }).then(function (oResponse) {
          return oResponse.json().then(function (oBody) {
            if (!oResponse.ok) {
              throw new Error((oBody.error && oBody.error.message) || oResponse.statusText);
            }
            return oBody;
          });
        });
    },

    /** Hook after a successful create (refresh dependent data). */
    onCreated: function () {
      this.refreshStatistics();
    },

    onCancelCreate: function () {
      this.byId("createDialog").close();
    },

    // ── Credentials (one-time secret of a service binding) ──────────────

    showCredentials: function (oBinding) {
      if (!oBinding || !oBinding.secretAccessKey) {
        return;
      }
      this.getModel("ui").setProperty("/credentials", {
        accessKeyId: oBinding.accessKeyId,
        secretAccessKey: oBinding.secretAccessKey,
        bucketName: oBinding.bucketName,
        endpoint: window.location.origin + window.location.pathname.replace(/[^/]*$/, "") + REST + "/content/" + oBinding.bucketName
      });
      if (!this._pCredentialsDialog) {
        this._pCredentialsDialog = Fragment.load({
          id: this.getView().getId(),
          name: "uim.objectstore.fragment.CredentialsDialog",
          controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      this._pCredentialsDialog.then(function (oDialog) { oDialog.open(); });
    },

    onCopyCredentials: function () {
      var c = this.getModel("ui").getProperty("/credentials");
      var sText = "endpoint=" + c.endpoint + "\naccessKeyId=" + c.accessKeyId + "\nsecretAccessKey=" + c.secretAccessKey + "\n";
      if (navigator.clipboard) {
        navigator.clipboard.writeText(sText).then(function () { MessageToast.show(this.getText("copied")); }.bind(this));
      }
    },

    onCloseCredentials: function () {
      this.getModel("ui").setProperty("/credentials/secretAccessKey", "");
      this.byId("credentialsDialog").close();
    },

    // ── Table helpers: delete & actions ─────────────────────────────────

    _selected: function (sTableId) {
      var oItem = this.byId(sTableId).getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return null;
      }
      return oItem.getBindingContext();
    },

    onDelete: function (sTableId) {
      var oContext = this._selected(sTableId);
      if (!oContext) {
        return;
      }
      var sName = oContext.getProperty("name");
      MessageBox.confirm(this.getText("confirmDelete", [sName]), {
        emphasizedAction: MessageBox.Action.OK,
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          oContext.delete().then(function () {
            MessageToast.show(this.getText("deleted", [sName]));
            this.onChanged();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    /** Bound-style action on the selected row, e.g. RevokeServiceBinding; asks for extra parameters. */
    onAction: function (sTableId, sAction, sParameters) {
      var oContext = this._selected(sTableId);
      if (!oContext) {
        return;
      }
      this.runAction(sAction, oContext.getProperty("id"), sParameters);
    },

    runAction: function (sAction, sId, sParameters, mDefaults) {
      return this.askParameters(this.getText("action_" + sAction), sParameters, mDefaults).then(function (mParameters) {
        mParameters.id = sId;
        this.getModel("ui").setProperty("/busy", true);
        return this.invokeAction(sAction, mParameters).then(function (oResult) {
          MessageToast.show(this.getText("actionDone", [this.getText("action_" + sAction), oResult.name]));
          this.showCredentials(oResult);
          this.onChanged();
          return oResult;
        }.bind(this));
      }.bind(this)).catch(this.showError.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    },

    /** Hook after a change (delete, action): refresh the model. */
    onChanged: function () {
      this.getModel().refresh();
    }
  });
});
