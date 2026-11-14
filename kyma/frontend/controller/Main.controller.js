sap.ui.define([
  "uim/kyma/controller/BaseController",
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
  "sap/m/Dialog",
  "sap/m/Button"
], function (BaseController, Fragment, Item, Filter, FilterOperator, MessageBox, MessageToast,
  VBox, Label, Input, TextArea, Select, Switch, Dialog, Button) {
  "use strict";

  /** Entity set → table id and REST path. */
  var SETS = {
    Environments: { table: "environmentTable", rest: "environments", tab: "environments", type: "Environment" },
    Namespaces: { table: "namespaceTable", rest: "namespaces", tab: "namespaces", type: "Namespace" },
    Functions: { table: "functionTable", rest: "functions", tab: "functions", type: "Function" },
    ApiRules: { table: "apiRuleTable", rest: "api-rules", tab: "apiRules", type: "API Rule" },
    ServiceInstances: { table: "serviceInstanceTable", rest: "service-instances", tab: "serviceInstances", type: "Service Instance" },
    ServiceBindings: { table: "serviceBindingTable", rest: "service-bindings", tab: "serviceBindings", type: "Service Binding" },
    EventSubscriptions: { table: "subscriptionTable", rest: "event-subscriptions", tab: "subscriptions", type: "Subscription" },
    Modules: { table: "moduleTable", rest: "modules", tab: "modules", type: "Module" },
    Applications: { table: "applicationTable", rest: "applications", tab: "applications", type: "Application" }
  };

  /** Fields of the generic create dialog (type: text|number|textarea|switch|select|parent|list|pairs). */
  var CREATE_FIELDS = {
    Environments: [
      { name: "name", label: "Name", required: true },
      { name: "description", label: "Description" },
      { name: "plan", label: "Plan", type: "select", value: "aws", options: ["aws", "azure", "gcp", "sapConvergedCloud", "trial", "free"] },
      { name: "region", label: "Region (empty = plan default)" },
      { name: "autoScalerMax", label: "Max. Nodes (0 = default)", type: "number", value: "0" },
      { name: "administrators", label: "Administrators (comma separated)", type: "list" }
    ],
    Namespaces: [
      { name: "environmentId", label: "Environment", type: "parent", parentSet: "Environments", required: true },
      { name: "name", label: "Name", required: true },
      { name: "description", label: "Description" },
      { name: "cpuLimit", label: "CPU Limit (e.g. 4)" },
      { name: "memoryLimit", label: "Memory Limit (e.g. 8Gi)" },
      { name: "istioInjection", label: "Istio Sidecar Injection", type: "switch", value: true },
      { name: "labels", label: "Labels (key=value, …)", type: "pairs" }
    ],
    Functions: [
      { name: "namespaceId", label: "Namespace", type: "parent", parentSet: "Namespaces", required: true },
      { name: "name", label: "Name", required: true },
      { name: "runtime", label: "Runtime", type: "select", value: "nodejs20", options: ["nodejs20", "nodejs22", "python312"] },
      { name: "sourceCode", label: "Source Code", type: "textarea", required: true,
        value: "module.exports = {\n  main: function (event, context) {\n    return 'Hello from Kyma';\n  }\n};" },
      { name: "dependencies", label: "Dependencies (package.json / requirements.txt)", type: "textarea" },
      { name: "minReplicas", label: "Min. Replicas", type: "number", value: "1" },
      { name: "maxReplicas", label: "Max. Replicas", type: "number", value: "5" },
      { name: "envVars", label: "Environment Variables (KEY=value, …)", type: "pairs" }
    ],
    ApiRules: [
      { name: "namespaceId", label: "Namespace", type: "parent", parentSet: "Namespaces", required: true },
      { name: "name", label: "Name", required: true },
      { name: "serviceName", label: "Service Name", required: true },
      { name: "servicePort", label: "Service Port", type: "number", value: "80" },
      { name: "host", label: "Host (empty = <name>.<cluster domain>)" },
      { name: "rules", label: "Access Rules (JSON)", type: "textarea",
        value: "[{\"path\": \"/*\", \"methods\": [\"GET\"], \"accessStrategy\": \"noAuth\"}]" }
    ],
    ServiceInstances: [
      { name: "namespaceId", label: "Namespace", type: "parent", parentSet: "Namespaces", required: true },
      { name: "name", label: "Name", required: true },
      { name: "serviceOfferingName", label: "Service Offering (e.g. xsuaa)", required: true },
      { name: "servicePlanName", label: "Service Plan (e.g. application)", required: true },
      { name: "parametersJson", label: "Parameters (JSON)", type: "textarea" }
    ],
    ServiceBindings: [
      { name: "serviceInstanceId", label: "Service Instance", type: "parent", parentSet: "ServiceInstances", required: true },
      { name: "name", label: "Name", required: true },
      { name: "secretName", label: "Secret Name (empty = name)" }
    ],
    EventSubscriptions: [
      { name: "namespaceId", label: "Namespace", type: "parent", parentSet: "Namespaces", required: true },
      { name: "name", label: "Name", required: true },
      { name: "source", label: "Source (application)", required: true },
      { name: "eventTypes", label: "Event Types (comma separated)", type: "list", required: true },
      { name: "sinkServiceName", label: "Sink Service" },
      { name: "sinkUrl", label: "Sink URL (instead of a service)" },
      { name: "typeEncoding", label: "Type Matching", type: "select", value: "exact", options: ["exact", "prefix"] }
    ],
    Modules: [
      { name: "environmentId", label: "Environment", type: "parent", parentSet: "Environments", required: true },
      { name: "moduleType", label: "Module", type: "select", value: "serverless",
        options: ["istio", "api-gateway", "btp-operator", "serverless", "eventing", "nats", "telemetry", "keda",
          "connectivity-proxy", "application-connector", "custom"] },
      { name: "name", label: "Name (custom modules only)" },
      { name: "channel", label: "Channel", type: "select", value: "regular", options: ["regular", "fast"] }
    ],
    Applications: [
      { name: "environmentId", label: "Environment", type: "parent", parentSet: "Environments", required: true },
      { name: "name", label: "Name", required: true },
      { name: "description", label: "Description" },
      { name: "registrationType", label: "Registers", type: "select", value: "apiAndEvents", options: ["api", "events", "apiAndEvents"] },
      { name: "apis", label: "APIs (JSON)", type: "textarea" },
      { name: "events", label: "Events (JSON)", type: "textarea" }
    ]
  };

  return BaseController.extend("uim.kyma.controller.Main", {

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

    onEnvironmentPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("environment", { id: encodeURIComponent(sId) });
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
          name: "uim.kyma.fragment.CreateDialog",
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
        case "parent":
          oControl = new Select({ selectedKey: "{ui>value}", width: "100%", forceSelection: true,
            items: { path: "/" + oField.parentSet, parameters: { $orderby: "name" },
              template: new Item({ key: "{id}", text: "{name}" }), templateShareable: false } });
          break;
        case "textarea":
          oControl = new TextArea({ value: "{ui>value}", width: "100%", rows: 6, growing: true });
          break;
        case "switch":
          oControl = new Switch({ state: "{ui>value}" });
          break;
        default:
          oControl = new Input({ value: "{ui>value}", type: oField.type === "number" ? "Number" : "Text" });
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

    // ── Delete, actions, manifest ───────────────────────────────────────

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
      var sType = Object.keys(SETS).map(function (k) { return SETS[k]; })
        .filter(function (m) { return m.table === sTableId; })[0].type;
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

    /** Unbound action with the selected id, e.g. PauseEventSubscription. */
    onAction: function (sTableId, sAction, bNeedsNamespace) {
      var oContext = this._selected(sTableId);
      if (!oContext) {
        return;
      }
      var mParameters = { id: oContext.getProperty("id") };
      var fnRun = function () {
        this.invokeAction(sAction, mParameters).then(function (oResult) {
          MessageToast.show(this.getText("actionDone", [oResult.name, this.formatter.enumText(oResult.status)]));
          this.byId(sTableId).getBinding("items").refresh();
          this.refreshStatistics();
        }.bind(this), this.showError.bind(this));
      }.bind(this);

      if (!bNeedsNamespace) {
        fnRun();
        return;
      }
      var oInput = new Input({ placeholder: this.getText("namespacePrompt") });
      var oDialog = new Dialog({
        title: this.getText("bindNamespace"),
        content: [oInput.addStyleClass("sapUiSmallMargin")],
        beginButton: new Button({ text: "OK", type: "Emphasized", press: function () {
          mParameters.namespace = oInput.getValue().trim();
          oDialog.close();
          fnRun();
        } }),
        endButton: new Button({ text: this.getText("cancel"), press: function () { oDialog.close(); } }),
        afterClose: function () { oDialog.destroy(); }
      });
      this.getView().addDependent(oDialog);
      oDialog.open();
    },

    /** Show the Kubernetes custom resource of the selected entry (REST /manifest). */
    onManifest: function (sTableId, sTab) {
      var oContext = this._selected(sTableId);
      if (!oContext) {
        return;
      }
      var sRest = Object.keys(SETS).map(function (k) { return SETS[k]; })
        .filter(function (m) { return m.tab === sTab; })[0].rest;
      fetch("api/v1/" + sRest + "/" + encodeURIComponent(oContext.getProperty("id")) + "/manifest", {
        headers: { Accept: "application/json" }, credentials: "same-origin"
      }).then(function (oResponse) {
        return oResponse.json().then(function (oJson) {
          if (!oResponse.ok) {
            throw new Error((oJson.error && oJson.error.message) || oResponse.statusText);
          }
          return oJson;
        });
      }).then(function (oManifest) {
        this.getModel("ui").setProperty("/manifest", JSON.stringify(oManifest, null, 2));
        if (!this._pManifestDialog) {
          this._pManifestDialog = Fragment.load({
            id: this.getView().getId(),
            name: "uim.kyma.fragment.ManifestDialog",
            controller: this
          }).then(function (oDialog) {
            this.getView().addDependent(oDialog);
            return oDialog;
          }.bind(this));
        }
        return this._pManifestDialog.then(function (oDialog) { oDialog.open(); });
      }.bind(this)).catch(this.showError.bind(this));
    },

    onCloseManifest: function () {
      this.byId("manifestDialog").close();
    }
  });
});
