sap.ui.define([
  "uim/translation/controller/BaseController",
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
  "sap/m/MultiComboBox"
], function (BaseController, Fragment, Item, Filter, FilterOperator, MessageBox, MessageToast,
  VBox, Label, Input, TextArea, Select, Switch, MultiComboBox) {
  "use strict";

  /** Entity set → table id, tab key and display type. */
  var SETS = {
    TranslationProjects: { table: "projectTable", tab: "projects", type: "Project" },
    ProjectTexts: { table: "textTable", tab: "texts", type: "Text" },
    GlossaryEntries: { table: "glossaryTable", tab: "glossary", type: "Glossary Entry" },
    TranslationJobs: { table: "jobTable", tab: "jobs", type: "Job" }
  };

  var PROVIDERS = ["machineMt", "mltr", "companyMltr", "llm"];
  var TEXT_TYPES = ["uiText", "tooltip", "errorMessage", "documentation", "notification", "emailBody", "reportTitle", "log"];

  /**
   * Fields of the generic create dialog
   * (type: text|number|textarea|switch|select|language|languages|domain|project).
   */
  var CREATE_FIELDS = {
    TranslationProjects: [
      { name: "name", label: "Name", required: true },
      { name: "description", label: "Description" },
      { name: "projectType", label: "Source", type: "select", value: "api", options: ["api", "file", "git", "abap"] },
      { name: "sourceLanguage", label: "Source Language", type: "language", value: "en", required: true },
      { name: "targetLanguages", label: "Target Languages", type: "languages", value: [], required: true },
      { name: "provider", label: "Provider", type: "select", value: "machineMt", options: PROVIDERS },
      { name: "domainName", label: "Domain", type: "domain", value: "" },
      { name: "repositoryUrl", label: "Git Repository URL (source git)" },
      { name: "baseBranch", label: "Git Branch (default main)" },
      { name: "abapSystemId", label: "ABAP System ID (source abap)" }
    ],
    ProjectTexts: [
      { name: "projectId", label: "Project", type: "project", required: true },
      { name: "name", label: "Text Key (e.g. BUTTON_SAVE)", required: true },
      { name: "sourceText", label: "Source Text", type: "textarea", required: true },
      { name: "textType", label: "Text Type", type: "select", value: "uiText", options: TEXT_TYPES },
      { name: "maxLength", label: "Maximum Length (0 = unlimited)", type: "number", value: "0" },
      { name: "context", label: "Context for Translators" }
    ],
    GlossaryEntries: [
      { name: "sourceLanguage", label: "Source Language", type: "language", value: "en", required: true },
      { name: "targetLanguage", label: "Target Language", type: "language", value: "de", required: true },
      { name: "sourceTerm", label: "Source Term", required: true },
      { name: "targetTerm", label: "Target Term", required: true },
      { name: "domainName", label: "Domain (empty = every domain)", type: "domain", value: "" },
      { name: "mandatory", label: "Mandatory (enforced by every provider)", type: "switch", value: true },
      { name: "caseSensitive", label: "Case Sensitive", type: "switch", value: false },
      { name: "context", label: "Context" }
    ],
    TranslationJobs: [
      { name: "jobType", label: "Job Type", type: "select", value: "document", options: ["document", "text", "software"] },
      { name: "projectId", label: "Project (software jobs)", type: "project" },
      { name: "sourceLanguage", label: "Source Language (not for software jobs)", type: "language", value: "en" },
      { name: "targetLanguage", label: "Target Language (software: empty = all)", type: "language", value: "de" },
      { name: "provider", label: "Provider", type: "select", value: "machineMt", options: PROVIDERS },
      { name: "contentType", label: "Content Type", type: "select", value: "text/plain",
        options: ["text/plain", "text/markdown", "text/html", "application/json", "text/x-java-properties"] },
      { name: "content", label: "Content", type: "textarea" }
    ]
  };

  return BaseController.extend("uim.translation.controller.Main", {

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

    onProjectPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("project", { id: encodeURIComponent(sId) });
    },

    onSearch: function (sTableId, sPath, oEvent) {
      var sQuery = (oEvent.getParameter("query") || "").trim();
      var aFilters = sQuery ? [new Filter({ path: sPath || "name", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false })] : [];
      this.byId(sTableId).getBinding("items").filter(aFilters);
    },

    onStatusFilter: function (sTableId, oEvent) {
      var sKey = oEvent.getParameter("item").getKey();
      var aFilters = sKey === "all" ? [] : [new Filter("status", FilterOperator.EQ, sKey)];
      this.byId(sTableId).getBinding("items").filter(aFilters);
    },

    // ── Translator workbench (TranslateTexts) ───────────────────────────

    onSwapLanguages: function () {
      var oUi = this.getModel("ui");
      var sSource = oUi.getProperty("/translator/sourceLanguage");
      oUi.setProperty("/translator/sourceLanguage", oUi.getProperty("/translator/targetLanguage"));
      oUi.setProperty("/translator/targetLanguage", sSource);
    },

    onTranslate: function () {
      var oUi = this.getModel("ui");
      var t = oUi.getProperty("/translator");
      var aTexts = (t.input || "").split("\n").map(function (s) { return s.trim(); }).filter(Boolean);
      if (!aTexts.length) {
        MessageToast.show(this.getText("enterText"));
        return;
      }
      oUi.setProperty("/busy", true);
      this.invokeAction("TranslateTexts", {
        sourceLanguage: t.sourceLanguage,
        targetLanguage: t.targetLanguage,
        texts: aTexts,
        provider: t.provider,
        domainName: t.domainName || "",
        textType: t.textType
      }).then(function (oResult) {
        oUi.setProperty("/translator/results", oResult.translations || []);
        oUi.setProperty("/translator/summary", this.getText("translateSummary",
          [oResult.count, this.formatter.enumText(oResult.provider), oResult.averageQuality, oResult.glossaryHits]));
      }.bind(this), this.showError.bind(this)).finally(function () {
        oUi.setProperty("/busy", false);
      });
    },

    /** Submit the workbench input as an asynchronous document job. */
    onSubmitJob: function () {
      var t = this.getModel("ui").getProperty("/translator");
      if (!(t.input || "").trim()) {
        MessageToast.show(this.getText("enterText"));
        return;
      }
      var oContext = this.byId("jobTable").getBinding("items").create({
        jobType: "document",
        sourceLanguage: t.sourceLanguage,
        targetLanguage: t.targetLanguage,
        provider: t.provider,
        domainName: t.domainName || "",
        contentType: "text/plain",
        content: t.input
      });
      oContext.created().then(function () {
        MessageToast.show(this.getText("jobSubmitted"));
        this.refreshStatistics();
      }.bind(this), this.showError.bind(this));
    },

    /** Process all pending jobs now (ProcessJobs). */
    onProcessJobs: function () {
      this.getModel("ui").setProperty("/busy", true);
      this.invokeAction("ProcessJobs").then(function (oResult) {
        MessageToast.show(this.getText("jobsProcessed", [oResult.processed, oResult.completed, oResult.failed]));
        this.getModel().refresh();
      }.bind(this), this.showError.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    },

    // ── Generic create dialog ───────────────────────────────────────────

    onCreate: function (sSet, mDefaults) {
      var aFields = CREATE_FIELDS[sSet].map(function (f) {
        var oField = Object.assign({ type: "text", value: "", required: false, options: [] }, f, {
          options: (f.options || []).map(function (o) { return { key: o }; })
        });
        if (mDefaults && mDefaults[f.name] !== undefined) {
          oField.value = mDefaults[f.name];
        }
        return oField;
      });
      this.getModel("ui").setProperty("/create", {
        set: sSet,
        title: this.getText("createTitle", [SETS[sSet].type]),
        fields: aFields
      });
      if (!this._pCreateDialog) {
        this._pCreateDialog = Fragment.load({
          id: this.getView().getId(),
          name: "uim.translation.fragment.CreateDialog",
          controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      this._pCreateDialog.then(function (oDialog) { oDialog.open(); });
    },

    /** A Select over an entity set (languages, domains, projects). */
    _referenceSelect: function (oField, sPath, sOrderBy, sText) {
      var oSelect = new Select({ selectedKey: "{ui>value}", width: "100%", forceSelection: false,
        items: { path: sPath, parameters: { $orderby: sOrderBy },
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
        case "language":
          oControl = this._referenceSelect(oField, "/Languages", "id", "{id} – {name}");
          break;
        case "languages":
          oControl = new MultiComboBox({ selectedKeys: "{ui>value}", width: "100%",
            items: { path: "/Languages", parameters: { $orderby: "id" },
              template: new Item({ key: "{id}", text: "{id} – {name}" }), templateShareable: false } });
          break;
        case "domain":
          oControl = this._referenceSelect(oField, "/TranslationDomains", "name", "{id} – {name}");
          break;
        case "project":
          oControl = this._referenceSelect(oField, "/TranslationProjects", "name", "{name}");
          break;
        case "textarea":
          oControl = new TextArea({ value: "{ui>value}", width: "100%", rows: 4, growing: true });
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
        var bEmpty = v === "" || v === undefined || v === null || (Array.isArray(v) && !v.length);
        if (f.required && bEmpty) {
          aMissing.push(f.label);
          return;
        }
        if (bEmpty && f.type !== "switch") {
          return;
        }
        if (f.type === "number") {
          v = parseInt(v, 10) || 0;
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
      }.bind(this), this.showError.bind(this));
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

    /** Unbound action with the selected id, e.g. TranslateTranslationProject; asks for extra parameters. */
    onAction: function (sTableId, sAction, sParameters) {
      var oContext = this._selected(sTableId);
      if (!oContext) {
        return;
      }
      this.askParameters(this.getText("action_" + sAction), sParameters).then(function (mParameters) {
        mParameters.id = oContext.getProperty("id");
        return this.invokeAction(sAction, mParameters).then(function (oResult) {
          MessageToast.show(this.getText("actionDone", [oResult.name, this.formatter.enumText(oResult.status)]));
          // project runs change texts and statistics as well
          this.getModel().refresh();
        }.bind(this));
      }.bind(this)).catch(this.showError.bind(this));
    }
  });
});
