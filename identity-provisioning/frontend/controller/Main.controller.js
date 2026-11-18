sap.ui.define([
  "uim/identityprovisioning/controller/BaseController",
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
  "sap/m/StepInput"
], function (BaseController, Fragment, Item, Filter, FilterOperator, MessageBox, MessageToast,
  VBox, Label, Input, TextArea, Select, Switch, StepInput) {
  "use strict";

  /** Entity set → table id, tab key and display type. */
  var SETS = {
    SourceSystems: { table: "sourceTable", tab: "sources", type: "Source System", role: "source" },
    TargetSystems: { table: "targetTable", tab: "targets", type: "Target System", role: "target" },
    ProxySystems: { table: "proxyTable", tab: "proxies", type: "Proxy System", role: "proxy" },
    Transformations: { table: "transformationTable", tab: "transformations", type: "Transformation" },
    ProvisioningJobs: { table: "jobTable", tab: "jobs", type: "Job" }
  };

  var AUTH = ["basic", "oauth2ClientCredentials", "certificate", "none"];

  var SYSTEM_FIELDS = [
    { name: "name", label: "Name", required: true },
    { name: "description", label: "Description" },
    { name: "systemType", label: "System Type", type: "systemType", value: "scim", required: true },
    { name: "url", label: "URL", required: true },
    { name: "authenticationType", label: "Authentication", type: "select", value: "basic", options: AUTH },
    { name: "user", label: "User / Client ID" },
    { name: "password", label: "Password / Client Secret (empty = unchanged)", type: "password", secret: true },
    { name: "properties", label: "Connector Properties (key=value per line)", type: "keyValues", value: "" }
  ];

  var MAPPING_TEMPLATE = JSON.stringify([
    { sourcePath: "userName", targetPath: "userName", "function": "lowerCase", mandatory: true },
    { sourcePath: "email", targetPath: "emails[0].value", mandatory: true }
  ], null, 2);

  /**
   * Fields of the generic create/edit dialog
   * (type: text|password|number|textarea|json|keyValues|switch|select|systemType|system|source|target).
   * "fixed" fields cannot be changed after creation.
   */
  var FIELDS = {
    SourceSystems: SYSTEM_FIELDS,
    TargetSystems: SYSTEM_FIELDS,
    ProxySystems: SYSTEM_FIELDS,
    Transformations: [
      { name: "name", label: "Name", required: true },
      { name: "description", label: "Description" },
      { name: "systemRole", label: "Role", type: "select", value: "target", options: ["source", "target", "proxy"], fixed: true },
      { name: "systemId", label: "System", type: "system", required: true, fixed: true },
      { name: "scope", label: "Applies To", type: "select", value: "all", options: ["all", "user", "group"] },
      { name: "sequence", label: "Sequence", type: "number", value: 10 },
      { name: "active", label: "Active", type: "switch", value: true },
      { name: "mappings", label: "Mappings (JSON: sourcePath, targetPath, function, defaultValue, mandatory)", type: "json", value: MAPPING_TEMPLATE },
      { name: "conditions", label: "Conditions (JSON: attribute, operator, value)", type: "json", value: "[]" }
    ],
    ProvisioningJobs: [
      { name: "name", label: "Name (empty = derived from the systems)" },
      { name: "description", label: "Description" },
      { name: "sourceSystemId", label: "Source System", type: "source", required: true },
      { name: "targetSystemId", label: "Target System", type: "target", required: true },
      { name: "jobType", label: "Job Type", type: "select", value: "delta", options: ["delta", "full", "simulate"] },
      { name: "intervalMinutes", label: "Run every N minutes (0 = on demand)", type: "number", value: 0 }
    ]
  };

  return BaseController.extend("uim.identityprovisioning.controller.Main", {

    onInit: function () {
      this._mFilters = {};
      this.getRouter().getRoute("main").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sTab = (oEvent.getParameter("arguments") || {}).tab;
      if (sTab) {
        this.getModel("ui").setProperty("/selectedTab", sTab);
      }
    },

    // ── Navigation, refresh, filters ────────────────────────────────────

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

    onJobPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("job", { id: encodeURIComponent(sId) });
    },

    /** Combine the select filters and the search of a table. */
    _applyFilters: function (sTableId) {
      var mTable = this._mFilters[sTableId] || {};
      var aFilters = Object.keys(mTable).map(function (k) { return mTable[k]; }).filter(Boolean);
      this.byId(sTableId).getBinding("items").filter(aFilters.length ? new Filter({ filters: aFilters, and: true }) : []);
    },

    onSearch: function (sTableId, sPath, oEvent) {
      var sQuery = (oEvent.getParameter("query") || "").trim();
      this._mFilters[sTableId] = this._mFilters[sTableId] || {};
      this._mFilters[sTableId].$search = sQuery
        ? new Filter({ path: sPath || "name", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false }) : null;
      this._applyFilters(sTableId);
    },

    onFilter: function (sTableId, sPath, oEvent) {
      var sKey = oEvent.getParameter("selectedItem").getKey();
      this._mFilters[sTableId] = this._mFilters[sTableId] || {};
      this._mFilters[sTableId][sPath] = sKey ? new Filter(sPath, FilterOperator.EQ, sKey) : null;
      this._applyFilters(sTableId);
    },

    // ── Service actions ─────────────────────────────────────────────────

    /** Run all due scheduled jobs now (RunDueJobs). */
    onRunDueJobs: function () {
      this.getModel("ui").setProperty("/busy", true);
      this.invokeAction("RunDueJobs").then(function (oResult) {
        MessageToast.show(this.getText("dueJobsRun", [oResult.processed, oResult.completed, oResult.failed]));
        this.getModel().refresh();
      }.bind(this), this.showError.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    },

    onPurgeLogs: function () {
      MessageBox.confirm(this.getText("confirmPurge"), {
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          this.invokeAction("PurgeLogs", { olderThanDays: 0 }).then(function (oResult) {
            MessageToast.show(this.getText("logsPurged", [oResult.purged]));
            this.getModel().refresh();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    // ── Transformation preview ──────────────────────────────────────────

    onPreview: function () {
      var oContext = this._selected("transformationTable");
      if (!oContext) {
        return;
      }
      var oUi = this.getModel("ui");
      oUi.setProperty("/preview/id", oContext.getProperty("id"));
      oUi.setProperty("/preview/name", oContext.getProperty("name"));
      oUi.setProperty("/preview/entityType", oContext.getProperty("scope") === "group" ? "group" : "user");
      oUi.setProperty("/preview/result", null);
      if (!this._pPreviewDialog) {
        this._pPreviewDialog = Fragment.load({
          id: this.getView().getId(), name: "uim.identityprovisioning.fragment.PreviewDialog", controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      this._pPreviewDialog.then(function (oDialog) { oDialog.open(); });
    },

    onRunPreview: function () {
      var oUi = this.getModel("ui");
      var p = oUi.getProperty("/preview");
      this.invokeAction("PreviewTransformation", {
        id: p.id,
        entityType: p.entityType,
        attributes: this.formatter.parseKeyValues(p.input)
      }).then(function (oResult) {
        oUi.setProperty("/preview/result", oResult);
      }, this.showError.bind(this));
    },

    onClosePreview: function () {
      this.byId("previewDialog").close();
    },

    // ── Generic create / edit dialog ────────────────────────────────────

    onCreate: function (sSet) {
      this._openEditor(sSet, "create", null);
    },

    onEdit: function (sTableId) {
      var oContext = this._selected(sTableId);
      if (!oContext) {
        return;
      }
      var sSet = Object.keys(SETS).filter(function (k) { return SETS[k].table === sTableId; })[0];
      this.readEntity(sSet, oContext.getProperty("id")).then(function (oEntity) {
        this._openEditor(sSet, "edit", oEntity);
      }.bind(this), this.showError.bind(this));
    },

    /** The text of a payload value as edited in the dialog. */
    _editValue: function (oField, vValue) {
      switch (oField.type) {
        case "keyValues": return this.formatter.keyValueLines(vValue);
        case "json": return JSON.stringify(vValue || [], null, 2);
        case "password": return "";
        default: return vValue === undefined || vValue === null ? "" : vValue;
      }
    },

    /** oEntity: the complete entity (edit) or null (create). */
    _openEditor: function (sSet, sMode, oEntity) {
      var that = this;
      var aFields = FIELDS[sSet].map(function (f) {
        var oField = Object.assign({ type: "text", value: "", required: false, options: [], fixed: false }, f, {
          options: (f.options || []).map(function (o) { return { key: o }; })
        });
        if (oEntity) {
          oField.value = that._editValue(oField, oEntity[f.name]);
          oField.original = oField.value;
          oField.editable = !oField.fixed;
        } else {
          oField.editable = true;
        }
        return oField;
      });
      this.getModel("ui").setProperty("/edit", {
        set: sSet,
        mode: sMode,
        id: oEntity ? oEntity.id : "",
        title: this.getText(sMode === "create" ? "createTitle" : "editTitle", [SETS[sSet].type, oEntity ? oEntity.name : ""]),
        fields: aFields
      });
      if (!this._pEditDialog) {
        this._pEditDialog = Fragment.load({
          id: this.getView().getId(), name: "uim.identityprovisioning.fragment.EditDialog", controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      this._pEditDialog.then(function (oDialog) { oDialog.open(); });
    },

    /** A Select over an entity set (systems, system types). */
    _referenceSelect: function (sPath, sText, aFilters) {
      return new Select({
        selectedKey: "{ui>value}", width: "100%", forceSelection: false, enabled: "{ui>editable}",
        items: { path: sPath, parameters: { $orderby: "name" }, filters: aFilters || [],
          template: new Item({ key: "{id}", text: sText }), templateShareable: false }
      });
    },

    /** Re-bind the system select of a transformation when the role changes. */
    _bindSystemSelect: function (sRole) {
      if (!this._oSystemSelect) {
        return;
      }
      var sSet = { source: "/SourceSystems", target: "/TargetSystems", proxy: "/ProxySystems" }[sRole] || "/TargetSystems";
      this._oSystemSelect.bindItems({ path: sSet, parameters: { $orderby: "name" },
        template: new Item({ key: "{id}", text: "{name}" }), templateShareable: false });
    },

    /** Factory of the edit dialog: label + control bound to ui>value. */
    createField: function (sId, oContext) {
      var oField = oContext.getObject();
      var sRole = (SETS[this.getModel("ui").getProperty("/edit/set")] || {}).role;
      var oControl;
      switch (oField.type) {
        case "select":
          oControl = new Select({ selectedKey: "{ui>value}", width: "100%", enabled: "{ui>editable}",
            items: { path: "ui>options", template: new Item({ key: "{ui>key}", text: "{ui>key}" }), templateShareable: false } });
          if (oField.name === "systemRole") {
            oControl.attachChange(function (oEvent) {
              this.getModel("ui").getProperty("/edit/fields").forEach(function (f, i) {
                if (f.name === "systemId") {
                  this.getModel("ui").setProperty("/edit/fields/" + i + "/value", "");
                }
              }.bind(this));
              this._bindSystemSelect(oEvent.getParameter("selectedItem").getKey());
            }.bind(this));
          }
          break;
        case "systemType":
          oControl = this._referenceSelect("/SystemTypes", "{name}",
            sRole ? [new Filter(sRole + "Supported", FilterOperator.EQ, true)] : []);
          break;
        case "system":
          oControl = this._referenceSelect("/TargetSystems", "{name}");
          this._oSystemSelect = oControl;
          var oRole = this.getModel("ui").getProperty("/edit/fields").filter(function (f) { return f.name === "systemRole"; })[0];
          this._bindSystemSelect(oRole ? oRole.value : "target");
          break;
        case "source":
          oControl = this._referenceSelect("/SourceSystems", "{name} ({status})");
          break;
        case "target":
          oControl = this._referenceSelect("/TargetSystems", "{name} ({status})");
          break;
        case "textarea": case "keyValues": case "json":
          oControl = new TextArea({ value: "{ui>value}", width: "100%", rows: oField.type === "json" ? 8 : 4,
            growing: true, growingMaxLines: 20, editable: "{ui>editable}" });
          if (oField.type === "json") {
            oControl.addStyleClass("sapUiTinyMarginTop");
          }
          break;
        case "switch":
          oControl = new Switch({ state: "{ui>value}", enabled: "{ui>editable}" });
          break;
        case "number":
          oControl = new StepInput({ value: "{ui>value}", min: 0, max: 10080, width: "12rem", editable: "{ui>editable}" });
          break;
        case "password":
          oControl = new Input({ value: "{ui>value}", type: "Password", editable: "{ui>editable}" });
          break;
        default:
          oControl = new Input({ value: "{ui>value}", editable: "{ui>editable}" });
      }
      return new VBox(sId, {
        items: [new Label({ text: oField.label, required: oField.required, labelFor: oControl }), oControl]
      }).addStyleClass("sapUiSmallMarginBottom");
    },

    /** Dialog fields → payload; throws on invalid JSON. */
    _payload: function (oDraft) {
      var oData = {};
      var aMissing = [];
      oDraft.fields.forEach(function (f) {
        var v = f.value;
        var bEmpty = v === "" || v === undefined || v === null;
        if (oDraft.mode === "edit" && (!f.editable || v === f.original || (f.secret && bEmpty))) {
          return; // unchanged, fixed or "keep the stored secret"
        }
        if (f.required && bEmpty) {
          aMissing.push(f.label);
          return;
        }
        if (bEmpty && f.type !== "switch" && oDraft.mode === "create") {
          return;
        }
        if (f.type === "number") {
          v = parseInt(v, 10) || 0;
        } else if (f.type === "keyValues") {
          v = this.formatter.parseKeyValues(v);
        } else if (f.type === "json") {
          try {
            v = JSON.parse(v || "[]");
          } catch (e) {
            throw new Error(this.getText("invalidJson", [f.label, e.message]));
          }
        }
        oData[f.name] = v;
      }.bind(this));
      if (aMissing.length) {
        throw new Error(this.getText("required", [aMissing.join(", ")]));
      }
      return oData;
    },

    onSaveEdit: function () {
      var oDraft = this.getModel("ui").getProperty("/edit");
      var mSet = SETS[oDraft.set];
      var oData;
      try {
        oData = this._payload(oDraft);
      } catch (e) {
        MessageBox.warning(e.message);
        return;
      }
      var pDone;
      if (oDraft.mode === "create") {
        var oContext = this.byId(mSet.table).getBinding("items").create(oData);
        pDone = oContext.created();
      } else {
        pDone = Object.keys(oData).length ? this.patchEntity(oDraft.set, oDraft.id, oData) : Promise.resolve();
      }
      pDone.then(function () {
        MessageToast.show(this.getText(oDraft.mode === "create" ? "created" : "updated", [mSet.type]));
        this.byId("editDialog").close();
        this.getModel().refresh();
      }.bind(this), this.showError.bind(this));
    },

    onCancelEdit: function () {
      this.byId("editDialog").close();
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

    /** Unbound action with the selected id, e.g. RunProvisioningJob, TestConnectionSourceSystem. */
    onAction: function (sTableId, sAction) {
      var oContext = this._selected(sTableId);
      if (!oContext) {
        return;
      }
      this.getModel("ui").setProperty("/busy", true);
      this.invokeAction(sAction, { id: oContext.getProperty("id") }).then(function (oResult) {
        var sDetail = oResult.statusMessage ? " — " + oResult.statusMessage : "";
        MessageToast.show(this.getText("actionDone", [oResult.name, this.formatter.enumText(oResult.status) || ""]) + sDetail,
          { duration: 5000, width: "32rem" });
        this.getModel().refresh();
      }.bind(this), function (oError) {
        this.showError(oError);
        this.getModel().refresh(); // e.g. failed activation sets status "error"
      }.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    }
  });
});
