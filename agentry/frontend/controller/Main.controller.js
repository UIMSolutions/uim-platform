sap.ui.define([
  "uim/agentry/controller/BaseController",
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
    apps: "appTable",
    definitions: "definitionTable",
    versions: "versionTable",
    devices: "deviceTable",
    syncs: "syncTable",
    connections: "connectionTable",
    deployments: "deploymentTable"
  };

  /**
   * Create dialog definitions per entity set.
   * type: text (default) | area | bool | select (options) | ref (OData value help: set, text)
   */
  var CREATE_FORMS = {
    appTable: { title: "newApp", fields: [
      { key: "name", label: "colName", required: true },
      { key: "packageName", label: "colPackage", required: true, placeholder: "com.example.app" },
      { key: "platform", label: "colPlatform", type: "select", options: ["android", "ios", "windows", "web", "cross"] },
      { key: "vendor", label: "colVendor" },
      { key: "category", label: "colCategory" },
      { key: "contactEmail", label: "colEmail" },
      { key: "description", label: "colDescription", type: "area" },
      { key: "offlineCapable", label: "colOffline", type: "bool" },
      { key: "pushNotificationsEnabled", label: "colPush", type: "bool" }
    ] },
    definitionTable: { title: "newDefinition", fields: [
      { key: "applicationId", label: "colApplication", type: "ref", set: "/MobileApplications", text: "name", required: true },
      { key: "name", label: "colName", required: true },
      { key: "definitionFormat", label: "colFormat", type: "select", options: ["json", "xml"] },
      { key: "schemaVersion", label: "colSchema", value: "1.0" },
      { key: "targetPlatform", label: "colPlatform" },
      { key: "businessObjectModel", label: "colBom" },
      { key: "definitionContent", label: "colContent", type: "area", required: true, value: "{\n  \"screens\": []\n}" }
    ] },
    versionTable: { title: "newVersion", fields: [
      { key: "mobileApplicationId", label: "colApplication", type: "ref", set: "/MobileApplications", text: "name", required: true },
      { key: "definitionId", label: "colDefinition", type: "ref", set: "/AppDefinitions", text: "name", required: true },
      { key: "versionNumber", label: "colVersion", required: true, placeholder: "1.0.0" },
      { key: "artifactUrl", label: "colArtifact" },
      { key: "checksum", label: "colChecksum" },
      { key: "releaseNotes", label: "colReleaseNotes", type: "area" },
      { key: "isMandatoryUpdate", label: "colMandatory", type: "bool" }
    ] },
    deviceTable: { title: "enrollDevice", fields: [
      { key: "mobileApplicationId", label: "colApplication", type: "ref", set: "/MobileApplications", text: "name", required: true },
      { key: "deviceName", label: "colDevice", required: true },
      { key: "osVersion", label: "colOs", required: true },
      { key: "deviceModel", label: "colModel" },
      { key: "manufacturer", label: "colManufacturer" },
      { key: "groupName", label: "colGroup" },
      { key: "userEmail", label: "colEmail" },
      { key: "isManaged", label: "colManaged", type: "bool" }
    ] },
    syncTable: { title: "newSync", fields: [
      { key: "deviceId", label: "colDevice", type: "ref", set: "/Devices", text: "deviceName", required: true },
      { key: "applicationId", label: "colApplication", type: "ref", set: "/MobileApplications", text: "name", required: true },
      { key: "connectionId", label: "colConnection", type: "ref", set: "/BackendConnections", text: "name", required: true },
      { key: "direction", label: "colDirection", type: "select", options: ["bidirectional", "download", "upload"] },
      { key: "clientAppVersion", label: "colClientVersion" }
    ] },
    connectionTable: { title: "newConnection", fields: [
      { key: "name", label: "colName", required: true },
      { key: "backendUrl", label: "colUrl", required: true, value: "https://" },
      { key: "backendType", label: "colType", type: "select", options: ["s4hana", "ecc", "btp", "crm", "custom"] },
      { key: "authMethod", label: "colAuth", type: "select", options: ["oauth2", "basic", "saml", "certificate", "none"] },
      { key: "sysId", label: "colSysId" },
      { key: "client", label: "colClient" },
      { key: "language", label: "colLanguage", value: "EN" },
      { key: "destinationName", label: "colDestination" },
      { key: "sslEnabled", label: "colSsl", type: "bool", value: true }
    ] },
    deploymentTable: { title: "newDeployment", fields: [
      { key: "appVersionId", label: "colVersion", type: "ref", set: "/AppVersions", text: "versionNumber", required: true },
      { key: "scope", label: "colScope", type: "select", options: ["tenant", "group", "device"] },
      { key: "targetGroupName", label: "colGroup" },
      { key: "targetDeviceId", label: "colDevice", type: "ref", set: "/Devices", text: "deviceName", optional: true },
      { key: "notes", label: "colNotes", type: "area" }
    ] }
  };

  return BaseController.extend("uim.agentry.controller.Main", {

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

    // ── Create (generic dialog driven by CREATE_FORMS) ──────────────────

    onCreate: function (oEvent) {
      var sTableId = oEvent.getSource().data("table");
      var oForm = CREATE_FORMS[sTableId];
      var oDraft = {};
      var oSimpleForm = new SimpleForm({ editable: true, layout: "ResponsiveGridLayout", labelSpanL: 4, labelSpanM: 4 });

      oForm.fields.forEach(function (f) {
        oDraft[f.key] = f.value !== undefined ? f.value : (f.type === "bool" ? false : (f.options ? f.options[0] : ""));
        var sPath = "ui>/draft/" + f.key;
        var oControl;
        switch (f.type) {
          case "area":
            oControl = new TextArea({ value: "{" + sPath + "}", rows: f.key === "definitionContent" ? 8 : 3, width: "100%" });
            break;
          case "bool":
            oControl = new Switch({ state: "{" + sPath + "}" });
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
              forceSelection: !f.optional,
              items: {
                path: f.set,
                parameters: { $select: "id," + f.text },
                template: new Item({ key: "{id}", text: "{" + f.text + "}" })
              }
            });
            if (f.optional) {
              oControl.insertItem(new Item({ key: "", text: "—" }), 0);
            }
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
          text: this.getText("save"),
          type: "Emphasized",
          press: function () {
            this._saveDraft(sTableId, oForm, oDialog);
          }.bind(this)
        }),
        endButton: new Button({ text: this.getText("cancel"), press: function () { oDialog.close(); } }),
        afterClose: function () { oDialog.destroy(); }
      });
      this.getView().addDependent(oDialog);
      oDialog.open();
    },

    _saveDraft: function (sTableId, oForm, oDialog) {
      var oDraft = this.getModel("ui").getProperty("/draft");
      var aMissing = oForm.fields.filter(function (f) {
        return f.required && !oDraft[f.key];
      });
      if (aMissing.length) {
        MessageBox.warning(this.getText("requiredMissing", [aMissing.map(function (f) {
          return this.getText(f.label);
        }, this).join(", ")]));
        return;
      }
      var oPayload = {};
      Object.keys(oDraft).forEach(function (k) {
        if (oDraft[k] !== "") {
          oPayload[k] = oDraft[k];
        }
      });
      var oContext = this.byId(sTableId).getBinding("items").create(oPayload);
      oContext.created().then(function () {
        MessageToast.show(this.getText("created"));
        this._refreshStatistics();
      }.bind(this), function (oError) {
        oContext.delete(); // drop the transient row
        this.showError(oError);
      }.bind(this));
      oDialog.close();
    },

    // ── Delete ──────────────────────────────────────────────────────────

    onDelete: function (oEvent) {
      var oItem = this._selected(oEvent.getSource().data("table"));
      if (!oItem) {
        return;
      }
      MessageBox.confirm(this.getText("confirmDelete"), {
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          oItem.getBindingContext().delete().then(function () {
            MessageToast.show(this.getText("deleted"));
            this._refreshStatistics();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    // ── Lifecycle actions (OData unbound actions) ───────────────────────

    /**
     * Generic action button: custom data "table", "action" and optional
     * "status" (for Set…Status actions).
     */
    onAction: function (oEvent) {
      var oSource = oEvent.getSource();
      var oItem = this._selected(oSource.data("table"));
      if (!oItem) {
        return;
      }
      var oParams = { id: oItem.getBindingContext().getProperty("id") };
      if (oSource.data("status")) {
        oParams.status = oSource.data("status");
      }
      if (oSource.data("action") === "CompleteDeployment") {
        oParams.devicesSucceeded = oItem.getBindingContext().getProperty("devicesTotal") || 0;
        oParams.devicesFailed = 0;
      }
      var sConfirm = oSource.data("confirm");
      if (sConfirm) {
        MessageBox.confirm(this.getText(sConfirm), {
          onClose: function (sAction) {
            if (sAction === MessageBox.Action.OK) {
              this._runAction(oSource.data("action"), oParams, oSource.data("table"));
            }
          }.bind(this)
        });
        return;
      }
      this._runAction(oSource.data("action"), oParams, oSource.data("table"));
    },

    _runAction: function (sAction, oParams, sTableId) {
      var oOperation = this.getModel().bindContext("/" + sAction + "(...)");
      Object.keys(oParams).forEach(function (k) {
        oOperation.setParameter(k, oParams[k]);
      });
      this.getModel("ui").setProperty("/busy", true);
      oOperation.execute().then(function () {
        var oResult = oOperation.getBoundContext().getObject() || {};
        MessageToast.show(this.getText("actionDone", [this.formatter.enumText(oResult.status || sAction)]));
        if (oResult.validationErrors) {
          MessageBox.warning(oResult.validationErrors);
        }
        this.byId(sTableId).getBinding("items").refresh();
        this._refreshStatistics();
      }.bind(this), this.showError.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    },

    // ── helpers ─────────────────────────────────────────────────────────

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
