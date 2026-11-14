sap.ui.define([
  "uim/connectivity/controller/BaseController",
  "sap/ui/core/Fragment",
  "sap/ui/core/Item",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "sap/m/VBox",
  "sap/m/Label",
  "sap/m/Input",
  "sap/m/TextArea",
  "sap/m/Select",
  "sap/m/Switch",
  "sap/m/DateTimePicker"
], function (BaseController, Fragment, Item, Filter, FilterOperator, MessageBox, MessageToast,
  VBox, Label, Input, TextArea, Select, Switch, DateTimePicker) {
  "use strict";

  /** Entity set → table id, tab key and display type. */
  var SETS = {
    Destinations: { table: "destinationTable", tab: "destinations", type: "Destination" },
    CloudConnectors: { table: "connectorTable", tab: "connectors", type: "Cloud Connector" },
    ServiceChannels: { table: "channelTable", tab: "channels", type: "Service Channel" },
    AccessRules: { table: "ruleTable", tab: "accessRules", type: "Access Rule" },
    Certificates: { table: "certificateTable", tab: "certificates", type: "Certificate" },
    ConnectivityLogs: { table: "logTable", tab: "logs", type: "Log Entry" }
  };

  var AUTH_TYPES = ["noAuthentication", "basicAuthentication", "oauth2ClientCredentials", "oauth2SAMLBearerAssertion",
    "oauth2UserTokenExchange", "oauth2JWTBearer", "oauth2Password", "oauth2AuthorizationCode",
    "clientCertificateAuthentication", "principalPropagation", "samlAssertion"];

  /** Fields of the generic create dialog (type: text|number|textarea|switch|select|connector|certificate|list|pairs|password|datetime). */
  var CREATE_FIELDS = {
    Destinations: [
      { name: "name", label: "Name (letters, digits, - and _)", required: true },
      { name: "description", label: "Description" },
      { name: "destinationType", label: "Type", type: "select", value: "http", options: ["http", "rfc", "mail", "ldap", "tcp"] },
      { name: "url", label: "URL (e.g. https://erp.virtual:443/sap/opu/odata)" },
      { name: "proxyType", label: "Proxy Type", type: "select", value: "internet", options: ["internet", "onPremise", "privateLink"] },
      { name: "cloudConnectorLocationId", label: "Cloud Connector Location ID (on premise, empty = default)" },
      { name: "authenticationType", label: "Authentication", type: "select", value: "noAuthentication", options: AUTH_TYPES },
      { name: "user", label: "User" },
      { name: "password", label: "Password", type: "password" },
      { name: "clientId", label: "OAuth Client ID" },
      { name: "clientSecret", label: "OAuth Client Secret", type: "password" },
      { name: "tokenServiceUrl", label: "Token Service URL (https://…)" },
      { name: "certificateId", label: "Certificate", type: "certificate" },
      { name: "properties", label: "Additional Properties (key=value, …)", type: "pairs" },
      { name: "additionalHeaders", label: "Additional Headers (key=value, …)", type: "pairs" }
    ],
    CloudConnectors: [
      { name: "name", label: "Name", required: true },
      { name: "locationId", label: "Location ID (empty = default location)" },
      { name: "subaccountId", label: "Subaccount" },
      { name: "host", label: "Host", required: true },
      { name: "port", label: "Port", type: "number", value: "8443" },
      { name: "connectorVersion", label: "Version" },
      { name: "description", label: "Description" }
    ],
    ServiceChannels: [
      { name: "connectorId", label: "Cloud Connector", type: "connector", required: true },
      { name: "name", label: "Name", required: true },
      { name: "channelType", label: "Type", type: "select", value: "http", options: ["http", "rfc", "tcp"] },
      { name: "virtualHost", label: "Virtual Host", required: true },
      { name: "virtualPort", label: "Virtual Port", type: "number", required: true },
      { name: "backendHost", label: "Back-end Host", required: true },
      { name: "backendPort", label: "Back-end Port", type: "number", required: true },
      { name: "connectionCount", label: "Connections (1–20)", type: "number", value: "1" }
    ],
    AccessRules: [
      { name: "connectorId", label: "Cloud Connector", type: "connector", required: true },
      { name: "protocol", label: "Protocol", type: "select", value: "https", options: ["http", "https", "rfc", "rfcs", "tcp", "tcpSsl", "ldap", "ldaps"] },
      { name: "virtualHost", label: "Virtual Host", required: true },
      { name: "virtualPort", label: "Virtual Port", type: "number", value: "443", required: true },
      { name: "internalHost", label: "Internal Host (empty = virtual host)" },
      { name: "internalPort", label: "Internal Port (empty = virtual port)", type: "number" },
      { name: "urlPathPrefix", label: "URL Path Prefix (HTTP/S)", value: "/" },
      { name: "includeSubPaths", label: "Include Sub-Paths", type: "switch", value: true },
      { name: "policy", label: "Policy", type: "select", value: "allow", options: ["allow", "deny"] },
      { name: "principalPropagation", label: "Principal Propagation", type: "switch", value: false },
      { name: "name", label: "Name (empty = derived from the resource)" },
      { name: "description", label: "Description" }
    ],
    Certificates: [
      { name: "name", label: "Name", required: true },
      { name: "certificateType", label: "Type", type: "select", value: "x509", options: ["x509", "pkcs12", "pem", "jks"] },
      { name: "usage", label: "Usage", type: "select", value: "authentication", options: ["authentication", "signing", "encryption", "trust"] },
      { name: "subjectDN", label: "Subject DN (CN=…)" },
      { name: "issuerDN", label: "Issuer DN" },
      { name: "serialNumber", label: "Serial Number" },
      { name: "fingerprint", label: "SHA-256 Fingerprint" },
      { name: "issuedAt", label: "Valid From", type: "datetime" },
      { name: "expiresAt", label: "Valid To", type: "datetime", required: true }
    ],
    ConnectivityLogs: [
      { name: "eventType", label: "Event", type: "select", value: "configurationChanged",
        options: ["connectionEstablished", "connectionLost", "connectionRefused", "authenticationFailure", "accessDenied", "configurationChanged"] },
      { name: "severity", label: "Severity", type: "select", value: "info", options: ["info", "warning", "error", "critical"] },
      { name: "sourceType", label: "Source Type", type: "select", value: "service",
        options: ["service", "destination", "cloudConnector", "serviceChannel", "accessRule", "certificate"] },
      { name: "sourceName", label: "Source Name" },
      { name: "message", label: "Message", type: "textarea", required: true }
    ]
  };

  return BaseController.extend("uim.connectivity.controller.Main", {

    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sTab = (oEvent.getParameter("arguments") || {}).tab;
      if (sTab) {
        this.getModel("ui").setProperty("/selectedTab", sTab);
      }
    },

    // ── Navigation & refresh ────────────────────────────────────────────

    onTabSelect: function (oEvent) {
      this.getRouter().navTo("main", { tab: oEvent.getParameter("key") }, true);
    },

    onTile: function (oEvent) {
      this.getModel("ui").setProperty("/selectedTab", oEvent.getSource().data("tab"));
    },

    onRefresh: function () {
      this.getModel().refresh();
      MessageToast.show(this.getText("refreshed"));
    },

    onDestinationPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("destination", { id: encodeURIComponent(sId) });
    },

    onSearch: function (sTableId, sPath, oEvent) {
      var sQuery = (oEvent.getParameter("query") || "").trim();
      var aFilters = sQuery ? [new Filter({ path: sPath || "name", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false })] : [];
      this.byId(sTableId).getBinding("items").filter(aFilters);
    },

    onSeverityFilter: function (oEvent) {
      var sKey = oEvent.getParameter("item").getKey();
      var aFilters = sKey === "all" ? [] : [new Filter("severity", FilterOperator.EQ, sKey)];
      this.byId("logTable").getBinding("items").filter(aFilters);
    },

    /** Run the health check (POST /RunHealthCheck) and refresh everything. */
    onHealthCheck: function () {
      this.getModel("ui").setProperty("/busy", true);
      this.invokeAction("RunHealthCheck").then(function (oResult) {
        MessageToast.show(this.getText("healthChecked", [oResult.changed, oResult.examined]));
        if (oResult.changes && oResult.changes.length) {
          MessageBox.information(oResult.changes.join("\n"), { title: this.getText("healthCheck") });
        }
        this.getModel().refresh();
      }.bind(this), this.showError.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    },

    /** Dry run of the Cloud Connector access control (POST /CheckAccess). */
    onAccessCheck: function () {
      var oContext = this.byId("connectorTable").getSelectedItem();
      var sConnector = oContext ? oContext.getBindingContext().getProperty("name") : "";
      this.askParameters(this.getText("accessCheck"), "connector,url", { connector: sConnector, url: "https://" })
        .then(function (mParameters) {
          return this.invokeAction("CheckAccess", mParameters).then(function (oResult) {
            var fnShow = oResult.allowed ? MessageBox.success : MessageBox.warning;
            fnShow(oResult.reason, { title: this.getText(oResult.allowed ? "accessAllowed" : "accessDenied") });
            this.byId("logTable").getBinding("items").refresh();
            this.refreshStatistics();
          }.bind(this));
        }.bind(this)).catch(function (oError) {
          if (!oError || !oError.canceled) {
            this.showError(oError);
          }
        }.bind(this));
    },

    // ── Generic create dialog ───────────────────────────────────────────

    onCreate: function (sSet) {
      var aFields = CREATE_FIELDS[sSet].map(function (f) {
        return Object.assign({ type: "text", value: "", required: false, options: [] }, f, {
          options: (f.options || []).map(function (o) { return { key: o }; })
        });
      });
      this.getModel("ui").setProperty("/create", {
        set: sSet,
        title: this.getText("createTitle", [SETS[sSet].type]),
        fields: aFields
      });
      if (!this._pCreateDialog) {
        this._pCreateDialog = Fragment.load({
          id: this.getView().getId(),
          name: "uim.connectivity.fragment.CreateDialog",
          controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      this._pCreateDialog.then(function (oDialog) { oDialog.open(); });
    },

    /** A Select over an entity set (Cloud Connectors, Certificates). */
    _referenceSelect: function (oField, sPath, sText) {
      var oSelect = new Select({ selectedKey: "{ui>value}", width: "100%", forceSelection: !!oField.required,
        items: { path: sPath, parameters: { $orderby: "name" },
          template: new Item({ key: "{id}", text: sText }), templateShareable: false } });
      if (!oField.required) {
        oSelect.insertItem(new Item({ key: "", text: "—" }), 0);
      }
      return oSelect;
    },

    /** Factory of the create dialog: label + control bound to ui>value. */
    createField: function (sId, oContext) {
      var oField = oContext.getObject();
      var oControl;
      switch (oField.type) {
        case "select":
          oControl = new Select({ selectedKey: "{ui>value}", width: "100%",
            items: { path: "ui>options", template: new Item({ key: "{ui>key}", text: "{ui>key}" }), templateShareable: false } });
          break;
        case "connector":
          oControl = this._referenceSelect(oField, "/CloudConnectors", "{name} ({locationId})");
          break;
        case "certificate":
          oControl = this._referenceSelect(oField, "/Certificates", "{name} – {status}");
          break;
        case "textarea":
          oControl = new TextArea({ value: "{ui>value}", width: "100%", rows: 4, growing: true });
          break;
        case "switch":
          oControl = new Switch({ state: "{ui>value}" });
          break;
        case "datetime":
          oControl = new DateTimePicker({ value: "{ui>value}", valueFormat: "yyyy-MM-dd'T'HH:mm:ss'Z'", width: "100%" });
          break;
        default:
          oControl = new Input({ value: "{ui>value}", type: oField.type === "number" ? "Number"
            : oField.type === "password" ? "Password" : "Text" });
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
        if (f.required && (v === "" || v === undefined || v === null)) {
          aMissing.push(f.label);
          return;
        }
        if (v === "" || v === undefined) {
          return;
        }
        if (f.type === "number") {
          v = parseInt(v, 10) || 0;
        } else if (f.type === "list") {
          v = String(v).split(",").map(function (s) { return s.trim(); }).filter(Boolean);
        } else if (f.type === "pairs") {
          v = String(v).split(",").map(function (s) { return s.trim(); }).filter(Boolean).map(function (s) {
            var i = s.indexOf("=");
            return i < 0 ? { key: s, value: "" } : { key: s.slice(0, i).trim(), value: s.slice(i + 1).trim() };
          });
        }
        oData[f.name] = v;
      });
      if (aMissing.length) {
        MessageBox.warning(this.getText("required", [aMissing.join(", ")]));
        return;
      }
      var mSet = SETS[oDraft.set];
      var oContext = this.byId(mSet.table).getBinding("items").create(oData);
      oContext.created().then(function () {
        MessageToast.show(this.getText("created", [mSet.type]));
        this.refreshStatistics();
      }.bind(this), function (oError) {
        if (!oError.canceled) {
          this.showError(oError);
        }
      }.bind(this));
      this.onCancelCreate();
    },

    onCancelCreate: function () {
      this.byId("createDialog").close();
    },

    // ── Delete & actions ────────────────────────────────────────────────

    _selected: function (sTableId) {
      var oItem = this.byId(sTableId).getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return null;
      }
      return oItem.getBindingContext();
    },

    _typeOf: function (sTableId) {
      return Object.keys(SETS).map(function (k) { return SETS[k]; })
        .filter(function (m) { return m.table === sTableId; })[0].type;
    },

    onDelete: function (sTableId) {
      var oContext = this._selected(sTableId);
      if (!oContext) {
        return;
      }
      var sName = oContext.getProperty("name");
      var sType = this._typeOf(sTableId);
      MessageBox.confirm(this.getText("confirmDelete", [sType, sName]), {
        emphasizedAction: MessageBox.Action.OK,
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          oContext.delete().then(function () {
            MessageToast.show(this.getText("deleted", [sType + " " + sName]));
            this.getModel().refresh();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    /** Unbound action with the selected id, e.g. OpenServiceChannel; asks for extra parameters. */
    onAction: function (sTableId, sAction, sParameters) {
      var oContext = this._selected(sTableId);
      if (!oContext) {
        return;
      }
      this.askParameters(this.getText("action_" + sAction), sParameters).then(function (mParameters) {
        mParameters.id = oContext.getProperty("id");
        return this.invokeAction(sAction, mParameters).then(function (oResult) {
          MessageToast.show(this.getText("actionDone", [oResult.name, this.formatter.enumText(oResult.status)]));
          // actions on connectors also close channels and write log entries
          this.getModel().refresh();
        }.bind(this));
      }.bind(this)).catch(function (oError) {
        if (!oError || !oError.canceled) {
          this.showError(oError);
        }
      }.bind(this));
    }
  });
});
