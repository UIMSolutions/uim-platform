sap.ui.define([
  "uim/abap/controller/BaseController",
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
    Systems: { table: "systemTable", tab: "systems", type: "System" },
    SoftwareComponents: { table: "componentTable", tab: "softwareComponents", type: "Software Component" },
    CommunicationArrangements: { table: "arrangementTable", tab: "communicationArrangements", type: "Communication Arrangement" },
    ServiceBindings: { table: "bindingTable", tab: "serviceBindings", type: "Service Binding" },
    BusinessRoles: { table: "roleTable", tab: "businessRoles", type: "Business Role" },
    BusinessUsers: { table: "userTable", tab: "businessUsers", type: "Business User" },
    TransportRequests: { table: "transportTable", tab: "transports", type: "Transport Request" },
    ApplicationJobs: { table: "jobTable", tab: "applicationJobs", type: "Application Job" }
  };

  /** Fields of the generic create dialog (type: text|number|textarea|switch|select|system|list|pairs|password|datetime). */
  var CREATE_FIELDS = {
    Systems: [
      { name: "name", label: "Name", required: true },
      { name: "description", label: "Description" },
      { name: "plan", label: "Plan", type: "select", value: "standard", options: ["standard", "development", "test", "production", "free"] },
      { name: "region", label: "Region", value: "eu10" },
      { name: "sapSystemId", label: "SAP System ID (empty = derived from the name)" },
      { name: "adminEmail", label: "Administrator E-Mail", required: true },
      { name: "abapRuntimeSize", label: "ABAP Runtime (GB, multiple of 16)", type: "number", value: "16" },
      { name: "hanaMemorySize", label: "HANA Memory (GB, multiple of 16)", type: "number", value: "64" }
    ],
    SoftwareComponents: [
      { name: "systemInstanceId", label: "System", type: "system", required: true },
      { name: "name", label: "Name (e.g. ZTRAVEL or /DMO/FLIGHT)", required: true },
      { name: "description", label: "Description" },
      { name: "componentType", label: "Type", type: "select", value: "development", options: ["development", "businessConfiguration"] },
      { name: "repositoryUrl", label: "Repository URL", required: true },
      { name: "branch", label: "Branch", value: "main" },
      { name: "namespace", label: "Namespace (e.g. /DMO/)" }
    ],
    CommunicationArrangements: [
      { name: "systemInstanceId", label: "System", type: "system", required: true },
      { name: "name", label: "Name", required: true },
      { name: "scenarioId", label: "Scenario (e.g. SAP_COM_0510)", required: true },
      { name: "communicationSystem", label: "Communication System (host)" },
      { name: "direction", label: "Direction", type: "select", value: "inbound", options: ["inbound", "outbound", "both"] },
      { name: "authMethod", label: "Authentication", type: "select", value: "basicAuthentication",
        options: ["basicAuthentication", "oauth2ClientCredentials", "oauth2SamlBearerAssertion", "clientCertificate", "noAuthentication"] },
      { name: "communicationUser", label: "Communication User" },
      { name: "communicationPassword", label: "Password", type: "password" },
      { name: "clientId", label: "OAuth Client ID" },
      { name: "clientSecret", label: "OAuth Client Secret", type: "password" },
      { name: "tokenEndpoint", label: "Token Endpoint (https://…)" },
      { name: "certificateId", label: "Certificate ID" }
    ],
    ServiceBindings: [
      { name: "systemInstanceId", label: "System", type: "system", required: true },
      { name: "name", label: "Name (e.g. ZUI_TRAVEL_O4)", required: true },
      { name: "serviceDefinition", label: "Service Definition (e.g. ZUI_TRAVEL)", required: true },
      { name: "bindingType", label: "Binding Type", type: "select", value: "odataV4Ui",
        options: ["odataV4Ui", "odataV4WebApi", "odataV2Ui", "odataV2WebApi", "soapHttp", "restHttp", "sqlWebApi", "inboundRfc"] },
      { name: "description", label: "Description" },
      { name: "serviceVersion", label: "Service Version", value: "0001" }
    ],
    BusinessRoles: [
      { name: "systemInstanceId", label: "System", type: "system", required: true },
      { name: "name", label: "Name (e.g. Z_BR_TRAVEL_PROCESSOR)", required: true },
      { name: "description", label: "Description" },
      { name: "roleType", label: "Access", type: "select", value: "unrestricted", options: ["unrestricted", "restricted", "custom"] },
      { name: "businessCatalogs", label: "Business Catalogs (comma separated)", type: "list" },
      { name: "restrictionTypes", label: "Restriction Types (comma separated)", type: "list" }
    ],
    BusinessUsers: [
      { name: "systemInstanceId", label: "System", type: "system", required: true },
      { name: "name", label: "User Name", required: true },
      { name: "firstName", label: "First Name" },
      { name: "lastName", label: "Last Name" },
      { name: "email", label: "E-Mail", required: true },
      { name: "roles", label: "Business Roles (comma separated names)", type: "list" }
    ],
    TransportRequests: [
      { name: "sourceSystemId", label: "Source System", type: "system", required: true },
      { name: "targetSystemId", label: "Target System", type: "system" },
      { name: "description", label: "Description", required: true },
      { name: "owner", label: "Owner", required: true },
      { name: "transportType", label: "Type", type: "select", value: "workbench", options: ["workbench", "customizing", "transportOfCopies"] }
    ],
    ApplicationJobs: [
      { name: "systemInstanceId", label: "System", type: "system", required: true },
      { name: "name", label: "Name", required: true },
      { name: "jobTemplateName", label: "Job Template (e.g. SAP_CORE_DELETE_LOGS)", required: true },
      { name: "description", label: "Description" },
      { name: "frequency", label: "Frequency", type: "select", value: "once", options: ["once", "hourly", "daily", "weekly", "monthly"] },
      { name: "scheduledAt", label: "First Run (empty = now)", type: "datetime" },
      { name: "cronExpression", label: "Cron Expression (optional, 5 fields)" },
      { name: "parameters", label: "Parameters (key=value, …)", type: "pairs" }
    ]
  };

  return BaseController.extend("uim.abap.controller.Main", {

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

    onSystemPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("system", { id: encodeURIComponent(sId) });
    },

    onSearch: function (sTableId, oEvent) {
      var sQuery = (oEvent.getParameter("query") || "").trim();
      var aFilters = sQuery ? [new Filter({ path: "name", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false })] : [];
      this.byId(sTableId).getBinding("items").filter(aFilters);
    },

    /** Run the reconciler (POST /Reconcile) and refresh everything. */
    onReconcile: function () {
      this.getModel("ui").setProperty("/busy", true);
      this.invokeAction("Reconcile").then(function (oResult) {
        MessageToast.show(this.getText("reconciled", [oResult.advanced, oResult.examined]));
        this.getModel().refresh();
      }.bind(this), this.showError.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
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
          name: "uim.abap.fragment.CreateDialog",
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
        case "select":
          oControl = new Select({ selectedKey: "{ui>value}", width: "100%",
            items: { path: "ui>options", template: new Item({ key: "{ui>key}", text: "{ui>key}" }), templateShareable: false } });
          break;
        case "system":
          oControl = new Select({ selectedKey: "{ui>value}", width: "100%", forceSelection: !!oField.required,
            items: { path: "/Systems", parameters: { $orderby: "name" },
              template: new Item({ key: "{id}", text: "{name} ({sapSystemId})" }), templateShareable: false } });
          if (!oField.required) {
            oControl.insertItem(new Item({ key: "", text: "—" }), 0);
          }
          break;
        case "textarea":
          oControl = new TextArea({ value: "{ui>value}", width: "100%", rows: 6, growing: true });
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

    /** Unbound action with the selected id, e.g. ReleaseTransportRequest; asks for extra parameters. */
    onAction: function (sTableId, sAction, sParameters) {
      var oContext = this._selected(sTableId);
      if (!oContext) {
        return;
      }
      this.askParameters(this.getText("action_" + sAction), sParameters).then(function (mParameters) {
        mParameters.id = oContext.getProperty("id");
        return this.invokeAction(sAction, mParameters).then(function (oResult) {
          MessageToast.show(this.getText("actionDone", [oResult.name, this.formatter.enumText(oResult.status)]));
          this.byId(sTableId).getBinding("items").refresh();
          this.refreshStatistics();
        }.bind(this));
      }.bind(this)).catch(function (oError) {
        if (!oError || !oError.canceled) {
          this.showError(oError);
        }
      }.bind(this));
    }
  });
});
