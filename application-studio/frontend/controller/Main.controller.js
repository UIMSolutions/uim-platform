sap.ui.define([
  "uim/studio/controller/BaseController",
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
  "sap/m/Switch"
], function (BaseController, Fragment, Item, Filter, FilterOperator, MessageBox, MessageToast,
  VBox, Label, Input, TextArea, Select, Switch) {
  "use strict";

  /** Entity set → table id, tab key and display type. */
  var SETS = {
    DevSpaces: { table: "devSpaceTable", tab: "devSpaces", type: "Dev Space" },
    Projects: { table: "projectTable", tab: "projects", type: "Project" },
    ServiceBindings: { table: "bindingTable", tab: "serviceBindings", type: "Service Binding" },
    RunConfigurations: { table: "runTable", tab: "runConfigurations", type: "Run Configuration" },
    BuildConfigurations: { table: "buildTable", tab: "buildConfigurations", type: "Build Configuration" },
    Extensions: { table: "extensionTable", tab: "extensions", type: "Extension" },
    DevSpaceTypes: { table: "typeTable", tab: "devSpaceTypes", type: "Dev Space Type" },
    ProjectTemplates: { table: "templateTable", tab: "projectTemplates", type: "Project Template" }
  };

  var PROJECT_TYPES = ["basic", "sapFiori", "sapFioriElements", "sapUi5", "capNodeJs", "capJava", "hanaNative", "mdk",
    "workflow", "multitarget", "sideBySideExtension"];

  /**
   * Fields of the generic create dialog.
   * type: text | number | textarea | switch | select | ref | list | pairs | password
   * ref:  { set, text } — a Select over another entity set (key = id)
   */
  var CREATE_FIELDS = {
    DevSpaces: [
      { name: "name", label: "Name (letters, digits, _)", required: true },
      { name: "devSpaceTypeId", label: "Dev Space Type", type: "ref", ref: { set: "/DevSpaceTypes", text: "{name}" }, required: true },
      { name: "owner", label: "Owner E-Mail", required: true },
      { name: "description", label: "Description" },
      { name: "plan", label: "Plan", type: "select", value: "standard", options: ["free", "standard", "professional"] },
      { name: "region", label: "Region", value: "eu10" },
      { name: "extensions", label: "Additional Extensions (comma separated names)", type: "list" },
      { name: "memoryLimitMb", label: "Memory (MB)", type: "number", value: "4096" },
      { name: "diskLimitGb", label: "Disk (GB)", type: "number", value: "10" },
      { name: "hibernateAfterDays", label: "Hibernate after idle days (0 = never)", type: "number", value: "7" }
    ],
    Projects: [
      { name: "devSpaceId", label: "Dev Space (running)", type: "ref", ref: { set: "/DevSpaces", text: "{name} ({status})" }, required: true },
      { name: "name", label: "Name (lowercase, e.g. travel-ui)", required: true },
      { name: "templateId", label: "Template", type: "ref", ref: { set: "/ProjectTemplates", text: "{title}" } },
      { name: "projectType", label: "Project Type (basic = from template)", type: "select", value: "basic", options: PROJECT_TYPES },
      { name: "description", label: "Description" },
      { name: "namespace", label: "Namespace (e.g. com.acme.travel)" },
      { name: "gitRepositoryUrl", label: "Git Repository" },
      { name: "gitBranch", label: "Branch", value: "main" }
    ],
    ServiceBindings: [
      { name: "devSpaceId", label: "Dev Space", type: "ref", ref: { set: "/DevSpaces", text: "{name}" }, required: true },
      { name: "name", label: "Name", required: true },
      { name: "providerType", label: "Provider", type: "select", value: "sapBtp",
        options: ["sapBtp", "sapS4Hana", "sapSuccessFactors", "externalOData", "externalRest"] },
      { name: "systemAlias", label: "Destination (alternative to URL)" },
      { name: "serviceUrl", label: "Service URL (https://…)" },
      { name: "servicePath", label: "Service Path (OData, e.g. /sap/opu/odata4/…)" },
      { name: "authType", label: "Authentication", type: "select", value: "noAuthentication",
        options: ["noAuthentication", "basicAuthentication", "oauth2ClientCredentials", "principalPropagation"] },
      { name: "user", label: "User / Client ID" },
      { name: "credentials", label: "Password / Client Secret", type: "password" },
      { name: "description", label: "Description" }
    ],
    RunConfigurations: [
      { name: "projectId", label: "Project", type: "ref", ref: { set: "/Projects", text: "{name} ({devSpaceName})" }, required: true },
      { name: "name", label: "Name", required: true },
      { name: "mode", label: "Mode", type: "select", value: "run", options: ["run", "debug", "test", "preview"] },
      { name: "entryPoint", label: "Entry Point (e.g. npm start)", required: true },
      { name: "arguments", label: "Arguments (comma separated)", type: "list" },
      { name: "port", label: "Port", type: "number", value: "4004" },
      { name: "debugPort", label: "Debug Port (debug mode)", type: "number" },
      { name: "environment", label: "Environment (KEY=value, …)", type: "pairs" },
      { name: "serviceBindings", label: "Service Bindings (comma separated names)", type: "list" }
    ],
    BuildConfigurations: [
      { name: "projectId", label: "Project", type: "ref", ref: { set: "/Projects", text: "{name} ({devSpaceName})" }, required: true },
      { name: "name", label: "Name", required: true },
      { name: "deployTarget", label: "Deploy Target", type: "select", value: "cloudFoundry",
        options: ["cloudFoundry", "kyma", "abap", "html5Repository", "docker"] },
      { name: "buildCommand", label: "Build Command", value: "mbt build", required: true },
      { name: "mtaDescriptor", label: "MTA Descriptor (Cloud Foundry, default mta.yaml)" },
      { name: "artifactPath", label: "Artifact (empty = derived)" },
      { name: "deployCommand", label: "Deploy Command (empty = derived)" },
      { name: "description", label: "Description" }
    ],
    Extensions: [
      { name: "name", label: "Name (publisher.package)", required: true },
      { name: "displayName", label: "Display Name" },
      { name: "version", label: "Version", value: "1.0.0" },
      { name: "scope", label: "Scope", type: "select", value: "additional", options: ["additional", "thirdParty"] },
      { name: "publisher", label: "Publisher" },
      { name: "category", label: "Category" },
      { name: "dependencies", label: "Dependencies (comma separated names)", type: "list" },
      { name: "description", label: "Description", type: "textarea" }
    ],
    DevSpaceTypes: [
      { name: "name", label: "Name", required: true },
      { name: "category", label: "Category", type: "select", value: "custom", options: ["custom", "thirdParty"] },
      { name: "runtimeStack", label: "Runtime Stack (e.g. Node.js 20)" },
      { name: "predefinedExtensions", label: "Extensions (comma separated names)", type: "list" },
      { name: "supportedProjectTypes", label: "Project Types (comma separated, empty = all)", type: "list" },
      { name: "description", label: "Description", type: "textarea" }
    ],
    ProjectTemplates: [
      { name: "name", label: "Name (e.g. fiori-worklist)", required: true },
      { name: "title", label: "Title" },
      { name: "category", label: "Category", type: "select", value: "general",
        options: ["general", "sapFiori", "sapCap", "sapHana", "sapMdk", "sapWorkflow"] },
      { name: "targetProjectType", label: "Project Type", type: "select", value: "basic", options: PROJECT_TYPES },
      { name: "version", label: "Version", value: "1.0.0" },
      { name: "requiredExtensions", label: "Required Extensions (comma separated)", type: "list" },
      { name: "scaffoldFiles", label: "Scaffold Files (comma separated paths)", type: "list" },
      { name: "parameters", label: "Parameters (key=value, …)", type: "pairs" },
      { name: "description", label: "Description", type: "textarea" }
    ]
  };

  return BaseController.extend("uim.studio.controller.Main", {

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

    onDevSpacePress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("devSpace", { id: encodeURIComponent(sId) });
    },

    onSearch: function (sTableId, oEvent) {
      var sQuery = (oEvent.getParameter("query") || "").trim();
      var aFilters = sQuery ? [new Filter({ path: "name", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false })] : [];
      this.byId(sTableId).getBinding("items").filter(aFilters);
    },

    /** Run the reconciler (POST /Reconcile) and refresh everything. */
    onReconcile: function () {
      this._runUnbound("Reconcile", function (oResult) {
        return this.getText("reconciled", [oResult.advanced, oResult.examined]);
      });
    },

    /** Install the predefined SAP catalogue (POST /SeedCatalog). */
    onSeedCatalog: function () {
      this._runUnbound("SeedCatalog", function (oResult) {
        return this.getText("seeded", [oResult.created, oResult.skipped]);
      });
    },

    _runUnbound: function (sAction, fnMessage) {
      this.getModel("ui").setProperty("/busy", true);
      this.invokeAction(sAction).then(function (oResult) {
        MessageToast.show(fnMessage.call(this, oResult));
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
          name: "uim.studio.fragment.CreateDialog",
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
        case "ref":
          oControl = new Select({ selectedKey: "{ui>value}", width: "100%", forceSelection: !!oField.required,
            items: { path: oField.ref.set, parameters: { $orderby: "name" },
              template: new Item({ key: "{id}", text: oField.ref.text }), templateShareable: false } });
          if (!oField.required) {
            oControl.insertItem(new Item({ key: "", text: "—" }), 0);
          }
          break;
        case "textarea":
          oControl = new TextArea({ value: "{ui>value}", width: "100%", rows: 4, growing: true });
          break;
        case "switch":
          oControl = new Switch({ state: "{ui>value}" });
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

    /** Unbound action with the selected id, e.g. StartDevSpace; asks for extra parameters. */
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
