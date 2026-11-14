sap.ui.define([
  "uim/ias/controller/BaseController",
  "sap/m/Dialog",
  "sap/m/Button",
  "sap/m/Label",
  "sap/m/Input",
  "sap/m/TextArea",
  "sap/m/Select",
  "sap/m/Switch",
  "sap/ui/core/Item",
  "sap/ui/layout/form/SimpleForm",
  "sap/m/MessageBox",
  "sap/m/MessageToast"
], function (BaseController, Dialog, Button, Label, Input, TextArea, Select, Switch, Item, SimpleForm,
  MessageBox, MessageToast) {
  "use strict";

  /** Tab key → table id. */
  var TAB_TABLES = {
    users: "userTable",
    groups: "groupTable",
    apps: "appTable",
    policies: "policyTable",
    risk: "riskTable",
    idps: "idpTable",
    sessions: "sessionTable",
    tokens: "tokenTable"
  };

  var USER_REF = { type: "ref", set: "/Users", text: "userName", required: true };

  /**
   * Dialog definitions.
   * type: text (default) | password | area | bool | select (options) | ref (OData value help: set, text)
   */
  var CREATE_FORMS = {
    userTable: { title: "newUser", fields: [
      { key: "email", label: "colEmail", required: true, placeholder: "jane.doe@example.com" },
      { key: "userName", label: "colUser", placeholder: "jane.doe" },
      { key: "firstName", label: "colFirstName" },
      { key: "lastName", label: "colLastName" },
      { key: "phoneNumber", label: "colPhone" },
      { key: "password", label: "colPassword", type: "password", required: true }
    ] },
    groupTable: { title: "newGroup", fields: [
      { key: "name", label: "colName", required: true },
      { key: "description", label: "colDescription", type: "area" }
    ] },
    appTable: { title: "newApp", fields: [
      { key: "name", label: "colName", required: true },
      { key: "protocol", label: "colProtocol", type: "select", options: ["oidc", "saml"] },
      { key: "redirectUris", label: "colRedirectUris", placeholder: "https://app.example.com/callback" },
      { key: "allowedScopes", label: "colScopes", value: "openid profile email" },
      { key: "samlEntityId", label: "colSamlEntityId" },
      { key: "samlAcsUrl", label: "colSamlAcsUrl" },
      { key: "description", label: "colDescription", type: "area" }
    ] },
    policyTable: { title: "newPolicy", fields: [
      { key: "name", label: "colName", required: true },
      { key: "rules", label: "colRules", type: "area", required: true, value: "group:in:admins",
        placeholder: "attribute:operator:value — one per line" },
      { key: "applicationIds", label: "colApplications", placeholder: "empty = all applications" },
      { key: "description", label: "colDescription", type: "area" }
    ] },
    riskTable: { title: "newRiskRule", fields: [
      { key: "name", label: "colName", required: true },
      { key: "conditions", label: "colConditions", type: "area", required: true, value: "ip_range:not_in:10.0.0.0/8" },
      { key: "riskLevel", label: "colRisk", type: "select", options: ["medium", "high", "critical", "low"] },
      { key: "requiredMfa", label: "colMfa", type: "select", options: ["totp", "email", "sms", "none"] },
      { key: "denyAccess", label: "colDeny", type: "bool" }
    ] },
    idpTable: { title: "newIdp", fields: [
      { key: "name", label: "colName", required: true },
      { key: "idpType", label: "colType", type: "select", options: ["oidc", "saml", "ldap", "corporate"] },
      { key: "authorizationEndpoint", label: "colEndpoint", placeholder: "https://login.example.com/authorize" },
      { key: "tokenEndpoint", label: "colTokenEndpoint" },
      { key: "metadataUrl", label: "colMetadataUrl" },
      { key: "clientId", label: "colClientId" },
      { key: "clientSecret", label: "colClientSecret", type: "password" },
      { key: "domainHints", label: "colDomains", placeholder: "example.com, example.org" },
      { key: "isDefault", label: "colDefault", type: "bool" }
    ] }
  };

  /** Extra action parameters asked for before the call (custom data "prompt"). */
  var PROMPTS = {
    newPassword: { title: "resetPassword", fields: [
      { key: "newPassword", label: "colPassword", type: "password", required: true }
    ] },
    mfaType: { title: "enrollMfa", fields: [
      { key: "mfaType", label: "colMfa", type: "select", options: ["totp", "email", "sms"] }
    ] },
    userId: { title: "selectUser", fields: [
      Object.assign({ key: "userId", label: "colUser" }, USER_REF)
    ] }
  };

  var EVALUATE_FORM = { title: "evaluate", fields: [
    { key: "applicationId", label: "colApplications", type: "ref", set: "/Applications", text: "name", required: true },
    Object.assign({ key: "userId", label: "colUser" }, USER_REF),
    { key: "ipAddress", label: "colIp" },
    { key: "mfaUsed", label: "colMfa", type: "bool" }
  ] };

  var SIMULATE_FORM = { title: "simulate", fields: [
    Object.assign({ key: "userId", label: "colUser" }, USER_REF),
    { key: "ipAddress", label: "colIp", placeholder: "203.0.113.10" },
    { key: "userAgent", label: "colUserAgent" }
  ] };

  return BaseController.extend("uim.ias.controller.Main", {

    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sTab = (oEvent.getParameter("arguments") || {}).tab;
      if (sTab && (TAB_TABLES[sTab] || sTab === "overview")) {
        this.getModel("ui").setProperty("/selectedTab", sTab);
      }
    },

    // ── Navigation & refresh ────────────────────────────────────────────

    onTabSelect: function (oEvent) {
      this.getRouter().navTo("main", { tab: oEvent.getParameter("key") }, true);
    },

    onRefresh: function () {
      this.getModel().refresh();
      MessageToast.show(this.getText("refreshed"));
    },

    onTilePress: function (oEvent) {
      var sTab = oEvent.getSource().data("tab");
      this.getModel("ui").setProperty("/selectedTab", sTab);
      this.getRouter().navTo("main", { tab: sTab }, true);
    },

    onSearch: function (oEvent) {
      var oTable = oEvent.getSource().getParent().getParent();
      var sQuery = (oEvent.getParameter("query") || "").trim();
      oTable.getBinding("items").changeParameters({ $search: sQuery || undefined });
    },

    // ── Generic form dialog ─────────────────────────────────────────────

    /** Open a form; fnSubmit(oValues) is called with the non-empty values. */
    _openForm: function (oForm, fnSubmit) {
      var oDraft = {};
      var oSimpleForm = new SimpleForm({ editable: true, layout: "ResponsiveGridLayout", labelSpanL: 4, labelSpanM: 4 });

      oForm.fields.forEach(function (f) {
        oDraft[f.key] = f.value !== undefined ? f.value : (f.type === "bool" ? false : (f.options ? f.options[0] : ""));
        var sPath = "ui>/draft/" + f.key;
        var oControl;
        switch (f.type) {
          case "area":
            oControl = new TextArea({ value: "{" + sPath + "}", rows: 3, width: "100%", placeholder: f.placeholder || "" });
            break;
          case "bool":
            oControl = new Switch({ state: "{" + sPath + "}" });
            break;
          case "password":
            oControl = new Input({ value: "{" + sPath + "}", type: "Password" });
            break;
          case "select":
            oControl = new Select({ selectedKey: "{" + sPath + "}", width: "100%" });
            f.options.forEach(function (o) {
              oControl.addItem(new Item({ key: o, text: this.formatter.enumText(o) }));
            }, this);
            break;
          case "ref":
            oControl = new Select({
              selectedKey: "{" + sPath + "}",
              width: "100%",
              forceSelection: true,
              items: {
                path: f.set,
                parameters: { $select: "id," + f.text },
                template: new Item({ key: "{id}", text: "{" + f.text + "}" })
              }
            });
            break;
          default:
            oControl = new Input({ value: "{" + sPath + "}", placeholder: f.placeholder || "" });
        }
        oSimpleForm.addContent(new Label({ text: this.getText(f.label), required: !!f.required }));
        oSimpleForm.addContent(oControl);
      }, this);

      this.getModel("ui").setProperty("/draft", oDraft);
      var oDialog = new Dialog({
        title: this.getText(oForm.title),
        contentWidth: "36rem",
        content: [oSimpleForm],
        beginButton: new Button({
          text: this.getText("ok"),
          type: "Emphasized",
          press: function () {
            var oValues = this.getModel("ui").getProperty("/draft");
            var aMissing = oForm.fields.filter(function (f) {
              return f.required && !oValues[f.key];
            });
            if (aMissing.length) {
              MessageBox.warning(this.getText("requiredMissing", [aMissing.map(function (f) {
                return this.getText(f.label);
              }, this).join(", ")]));
              return;
            }
            var oPayload = {};
            Object.keys(oValues).forEach(function (k) {
              if (oValues[k] !== "") {
                oPayload[k] = oValues[k];
              }
            });
            oDialog.close();
            fnSubmit(oPayload);
          }.bind(this)
        }),
        endButton: new Button({ text: this.getText("cancel"), press: function () { oDialog.close(); } }),
        afterClose: function () { oDialog.destroy(); }
      });
      this.getView().addDependent(oDialog);
      oDialog.open();
    },

    // ── Create ──────────────────────────────────────────────────────────

    onCreate: function (oEvent) {
      var sTableId = oEvent.getSource().data("table");
      this._openForm(CREATE_FORMS[sTableId], function (oPayload) {
        var oContext = this.byId(sTableId).getBinding("items").create(oPayload);
        oContext.created().then(function () {
          var sSecret = oContext.getProperty("clientSecret");
          if (sTableId === "appTable" && sSecret) {
            this._showSecret("clientCredentials", {
              clientId: oContext.getProperty("clientId"),
              clientSecret: sSecret
            });
          } else {
            MessageToast.show(this.getText("created"));
          }
          this._refreshStatistics();
        }.bind(this), function (oError) {
          oContext.delete(); // drop the transient row
          this.showError(oError);
        }.bind(this));
      }.bind(this));
    },

    // ── Delete / revoke ─────────────────────────────────────────────────

    onDelete: function (oEvent) {
      var oSource = oEvent.getSource();
      var oItem = this._selected(oSource.data("table"));
      if (!oItem) {
        return;
      }
      var bRevoke = !!oSource.data("confirm");
      MessageBox.confirm(this.getText(oSource.data("confirm") || "confirmDelete"), {
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          oItem.getBindingContext().delete().then(function () {
            MessageToast.show(this.getText(bRevoke ? "revoked" : "deleted"));
            if (bRevoke) {
              this.byId(oSource.data("table")).getBinding("items").refresh(); // revoked rows stay visible
            }
            this._refreshStatistics();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    onPurge: function () {
      this._runAction("PurgeExpired", {}).then(function (oResult) {
        MessageToast.show(this.getText("purged", [oResult.sessions, oResult.tokens]));
        this.getModel().refresh();
      }.bind(this));
    },

    // ── Actions on the selected row (OData unbound actions) ─────────────

    /**
     * Generic action button: custom data "table", "action" and optional
     * "status", "prompt" (extra parameters) and "confirm" (i18n key).
     */
    onAction: function (oEvent) {
      var oSource = oEvent.getSource();
      var sTableId = oSource.data("table");
      var sAction = oSource.data("action");
      var oItem = this._selected(sTableId);
      if (!oItem) {
        return;
      }
      var oParams = { id: oItem.getBindingContext().getProperty("id") };
      if (oSource.data("status")) {
        oParams.status = oSource.data("status");
      }

      var fnRun = function (oExtra) {
        this._runAction(sAction, Object.assign(oParams, oExtra || {})).then(function (oResult) {
          if (oResult.secret) {
            this._showSecret("mfaSecret", { secret: oResult.secret, provisioningUri: oResult.provisioningUri });
          } else if (oResult.clientSecret) {
            this._showSecret("clientCredentials", { clientId: oResult.clientId, clientSecret: oResult.clientSecret });
          } else {
            MessageToast.show(this.getText("actionDone", [this.formatter.enumText(oResult.status || sAction)]));
          }
          this.byId(sTableId).getBinding("items").refresh();
          this._refreshStatistics();
        }.bind(this));
      }.bind(this);

      var fnAfterConfirm = function () {
        if (oSource.data("prompt")) {
          this._openForm(PROMPTS[oSource.data("prompt")], fnRun);
        } else {
          fnRun();
        }
      }.bind(this);

      if (oSource.data("confirm")) {
        MessageBox.confirm(this.getText(oSource.data("confirm")), {
          onClose: function (sChoice) {
            if (sChoice === MessageBox.Action.OK) {
              fnAfterConfirm();
            }
          }
        });
      } else {
        fnAfterConfirm();
      }
    },

    /** Policy simulation: would the user get access to the application? */
    onEvaluate: function () {
      this._openForm(EVALUATE_FORM, function (oParams) {
        this._runAction("EvaluateAccess", oParams).then(function (oResult) {
          if (oResult.granted) {
            MessageBox.success(this.getText("accessGranted"));
          } else {
            MessageBox.error(this.getText("accessDenied", [oResult.denyingPolicies || "—"]));
          }
        }.bind(this));
      }.bind(this));
    },

    /** Risk simulation of a login. */
    onSimulate: function () {
      this._openForm(SIMULATE_FORM, function (oParams) {
        this._runAction("AssessRisk", oParams).then(function (oResult) {
          var sText = this.getText("riskResult", [this.formatter.enumText(oResult.riskLevel),
            this.formatter.mfaText(oResult.requiredMfa) || "—", oResult.triggeredRules || "—"]);
          if (oResult.denied) {
            MessageBox.error(sText);
          } else {
            MessageBox.information(sText);
          }
        }.bind(this));
      }.bind(this));
    },

    /** Execute an unbound action; resolves with the returned object. */
    _runAction: function (sAction, oParams) {
      var oOperation = this.getModel().bindContext("/" + sAction + "(...)");
      Object.keys(oParams).forEach(function (k) {
        oOperation.setParameter(k, oParams[k]);
      });
      this.getModel("ui").setProperty("/busy", true);
      return oOperation.execute().then(function () {
        return oOperation.getBoundContext().getObject() || {};
      }, function (oError) {
        this.showError(oError);
        throw oError;
      }.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    },

    // ── helpers ─────────────────────────────────────────────────────────

    /** One-time secrets: shown once, the backend only keeps a hash. */
    _showSecret: function (sTitleKey, oValues) {
      var sText = Object.keys(oValues).map(function (k) {
        return k + ":\n" + oValues[k];
      }).join("\n\n");
      MessageBox.warning(this.getText("secretOnce") + "\n\n" + sText, { title: this.getText(sTitleKey) });
    },

    _selected: function (sTableId) {
      var oItem = this.byId(sTableId).getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
      }
      return oItem;
    },

    _refreshStatistics: function () {
      ["kpiHeader", "overviewGrid"].forEach(function (sId) {
        var oBinding = this.byId(sId).getElementBinding();
        if (oBinding) {
          oBinding.refresh();
        }
      }, this);
    }
  });
});
