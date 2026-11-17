sap.ui.define([
  "uim/workzone/controller/BaseController",
  "sap/ui/core/Fragment",
  "sap/ui/core/Item",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/Table",
  "sap/m/Column",
  "sap/m/ColumnListItem",
  "sap/m/OverflowToolbar",
  "sap/m/ToolbarSpacer",
  "sap/m/Title",
  "sap/m/SearchField",
  "sap/m/Text",
  "sap/m/ObjectIdentifier",
  "sap/m/ObjectStatus",
  "sap/m/VBox",
  "sap/m/Label",
  "sap/m/Input",
  "sap/m/TextArea",
  "sap/m/Select",
  "sap/m/Switch",
  "sap/m/MultiComboBox",
  "sap/m/DateTimePicker",
  "sap/base/Log"
], function (BaseController, Fragment, Item, Filter, FilterOperator, MessageBox, Table, Column, ColumnListItem,
  OverflowToolbar, ToolbarSpacer, Title, SearchField, Text, ObjectIdentifier, ObjectStatus, VBox, Label, Input,
  TextArea, Select, Switch, MultiComboBox, DateTimePicker, Log) {
  "use strict";

  /** Display field of a referenced set (first column of its catalogue entry). */
  function displayField(oResource) {
    var aColumns = (oResource && oResource.columns) || [];
    return aColumns.length ? aColumns[0].field : "id";
  }

  /** Text of a value for the edit form (inverse of the backend's lenient parsing). */
  function inputValue(oField, vValue) {
    if (vValue === undefined || vValue === null) {
      return oField.kind === "boolean" ? false : oField.kind === "enumList" ? [] : "";
    }
    switch (oField.kind) {
      case "textList":
        return vValue.join(", ");
      case "enumList":
        return vValue.slice();
      case "records":
        return oField.recordType === "KeyValue"
          ? vValue.map(function (p) { return p.key + "=" + p.value; }).join(", ")
          : (vValue.length ? JSON.stringify(vValue, null, 2) : "");
      case "dateTime":
        return vValue ? String(vValue).replace(/(\.\d+)?Z$/, "") : "";
      default:
        return vValue;
    }
  }

  /** Payload value of a form value; throws on invalid JSON. */
  function payloadValue(oField, vValue) {
    switch (oField.kind) {
      case "integer":
        return vValue === "" ? 0 : parseInt(vValue, 10) || 0;
      case "boolean":
        return !!vValue;
      case "dateTime":
        return vValue ? new Date(vValue).toISOString() : null;
      case "textList":
        return String(vValue).split(",").map(function (s) { return s.trim(); }).filter(Boolean);
      case "enumList":
        return vValue || [];
      case "records":
        if (oField.recordType === "KeyValue") {
          return String(vValue).split(",").map(function (s) { return s.trim(); }).filter(Boolean).map(function (s) {
            var i = s.indexOf("=");
            return i < 0 ? { key: s, value: "" } : { key: s.slice(0, i).trim(), value: s.slice(i + 1).trim() };
          });
        }
        return String(vValue).trim() ? JSON.parse(vValue) : [];
      default:
        return vValue;
    }
  }

  return BaseController.extend("uim.workzone.controller.Resource", {

    onInit: function () {
      this.getRouter().getRoute("resource").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sSet = oEvent.getParameter("arguments").set;
      this.getOwnerComponent().catalogLoaded().then(function () {
        var oResource = this.resourceOf(sSet);
        if (!oResource) {
          this.getRouter().navTo("overview", {}, true);
          return;
        }
        var oUi = this.getModel("ui");
        oUi.setProperty("/set", sSet);
        oUi.setProperty("/title", this.getText("set_" + sSet));
        oUi.setProperty("/actions", oResource.actions || []);
        this._buildTable(oResource);
      }.bind(this)).catch(function (oError) {
        Log.error("Cannot show " + sSet, oError && oError.stack || String(oError), "uim.workzone.Resource");
        this.showError(oError);
      }.bind(this));
    },

    // ── table ───────────────────────────────────────────────────────────

    _kinds: function (oResource) {
      var mKinds = {};
      (oResource.inputFields || []).forEach(function (f) { mKinds[f.name] = f.kind; });
      return mKinds;
    },

    _buildTable: function (oResource) {
      var oContainer = this.byId("tableContainer");
      oContainer.destroyItems();
      var sSet = oResource.odataEntitySet;
      var mKinds = this._kinds(oResource);
      var aColumns = oResource.columns.filter(function (c) { return c.field !== "id"; });
      var formatter = this.formatter;

      var oTable = new Table(this.createId("resourceTable"), {
        mode: "SingleSelectLeft",
        growing: true,
        growingThreshold: 50,
        sticky: ["ColumnHeaders", "HeaderToolbar"],
        noDataText: this.getText("noData"),
        headerToolbar: new OverflowToolbar({
          content: [
            new Title({ text: "{ui>/title}", level: "H3" }),
            new ToolbarSpacer(),
            new SearchField({ width: "16rem", search: this.onSearch.bind(this) })
          ]
        }),
        columns: aColumns.map(function (c, i) {
          return new Column({ header: new Text({ text: c.header }), minScreenWidth: i > 2 ? "Tablet" : "", demandPopin: i > 2 });
        })
      });

      // Collection-valued properties cannot be bound by OData v4 property bindings:
      // their cells are filled from the row context when the table updates.
      var aCollections = [];
      var aCells = aColumns.map(function (c, i) {
        if (/^(textList|enumList|records)$/.test(mKinds[c.field])) {
          aCollections.push({ index: i, field: c.field });
          return new Text({ wrapping: false });
        }
        if (i === 0) {
          return new ObjectIdentifier({ title: "{" + c.field + "}" });
        }
        if (c.field === "status") {
          return new ObjectStatus({
            text: { path: c.field, formatter: formatter.enumText },
            state: { path: c.field, formatter: formatter.statusState }
          });
        }
        return new Text({
          wrapping: false,
          text: { path: c.field, targetType: "any", formatter: mKinds[c.field] === "enumeration" ? formatter.enumText : formatter.cellText }
        });
      });
      var bNavigates = sSet === "Workspaces";
      var oTemplate = new ColumnListItem({ type: bNavigates ? "Navigation" : "Inactive", cells: aCells });
      if (bNavigates) {
        oTemplate.attachPress(this.onItemPress, this);
      }
      oTable.bindItems({
        path: "/" + sSet,
        parameters: {
          $count: true,
          $orderby: aColumns[0].field,
          $select: aCollections.map(function (c) { return c.field; }).concat(["id"]).join(",")
        },
        templateShareable: false,
        template: oTemplate
      });
      oTable.attachUpdateFinished(function () {
        oTable.getItems().forEach(function (oItem) {
          var oRow = oItem.getBindingContext() && oItem.getBindingContext().getObject();
          aCollections.forEach(function (c) {
            oItem.getCells()[c.index].setText(formatter.cellText(oRow ? oRow[c.field] : null));
          });
        });
      });
      oContainer.addItem(oTable);
      this._oTable = oTable;
      this._sSearchField = aColumns[0].field;
    },

    onSearch: function (oEvent) {
      var sQuery = (oEvent.getParameter("query") || "").trim();
      var aFilters = sQuery ? [new Filter({ path: this._sSearchField, operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false })] : [];
      this._oTable.getBinding("items").filter(aFilters);
    },

    onItemPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("workspace", { id: encodeURIComponent(sId) });
    },

    _selected: function () {
      var oItem = this._oTable && this._oTable.getSelectedItem();
      if (!oItem) {
        MessageBox.information(this.getText("selectFirst"));
        return null;
      }
      return oItem.getBindingContext().getObject();
    },

    // ── create / edit ───────────────────────────────────────────────────

    onCreate: function () {
      this._openDraft("create", null);
    },

    onEdit: function () {
      var oRow = this._selected();
      if (oRow) {
        this._openDraft("edit", oRow);
      }
    },

    _openDraft: function (sMode, oRow) {
      var sSet = this.getModel("ui").getProperty("/set");
      var oResource = this.resourceOf(sSet);
      var aFields = oResource.inputFields.filter(function (f) {
        return sMode === "create" || f.name !== oResource.parentField;
      }).map(function (f) {
        var vValue = oRow ? inputValue(f, oRow[f.name]) : inputValue(f, undefined);
        return Object.assign({}, f, {
          value: vValue,
          initial: vValue,
          reference: (oResource.references || {})[f.name] || "",
          required: f.name === oResource.parentField || f.name === "name" || f.name === "title",
          options: (f.options || []).map(function (o) { return { key: o }; })
        });
      });
      this.getModel("ui").setProperty("/draft", {
        mode: sMode,
        id: oRow ? oRow.id : "",
        title: this.getText(sMode === "create" ? "createTitle" : "editTitle", [this.getText("set_" + sSet)]),
        fields: aFields
      });
      if (!this._pDialog) {
        this._pDialog = Fragment.load({
          id: this.getView().getId(),
          name: "uim.workzone.fragment.EditDialog",
          controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      this._pDialog.then(function (oDialog) { oDialog.open(); });
    },

    /** Factory of the dialog: label + control bound to ui>value. */
    createField: function (sId, oContext) {
      var oField = oContext.getObject();
      var oControl;
      if (oField.reference) {
        var sText = "{" + displayField(this.resourceOf(oField.reference)) + "}";
        oControl = new Select({ selectedKey: "{ui>value}", width: "100%", forceSelection: false,
          items: { path: "/" + oField.reference, templateShareable: false, template: new Item({ key: "{id}", text: sText }) } });
        oControl.insertItem(new Item({ key: "", text: "—" }), 0);
      } else {
        switch (oField.kind) {
          case "enumeration":
            oControl = new Select({ selectedKey: "{ui>value}", width: "100%",
              items: { path: "ui>options", templateShareable: false, template: new Item({ key: "{ui>key}", text: "{ui>key}" }) } });
            break;
          case "enumList":
            oControl = new MultiComboBox({ selectedKeys: "{ui>value}", width: "100%",
              items: { path: "ui>options", templateShareable: false, template: new Item({ key: "{ui>key}", text: "{ui>key}" }) } });
            break;
          case "boolean":
            oControl = new Switch({ state: "{ui>value}" });
            break;
          case "dateTime":
            oControl = new DateTimePicker({ value: "{ui>value}", valueFormat: "yyyy-MM-dd'T'HH:mm:ss", width: "100%" });
            break;
          case "records":
            oControl = oField.recordType === "KeyValue"
              ? new Input({ value: "{ui>value}", placeholder: "key=value, key2=value2" })
              : new TextArea({ value: "{ui>value}", width: "100%", rows: 5, growing: true,
                placeholder: this.getText("jsonHint", [oField.recordType]) }).addStyleClass("wzMono");
            break;
          case "integer":
            oControl = new Input({ value: "{ui>value}", type: "Number" });
            break;
          case "textList":
            oControl = new Input({ value: "{ui>value}", placeholder: "a, b, c" });
            break;
          default:
            oControl = /^(body|description|summary|customCss|message)$/.test(oField.name)
              ? new TextArea({ value: "{ui>value}", width: "100%", rows: 4, growing: true })
              : new Input({ value: "{ui>value}", type: /^(authToken|authConfig)$/.test(oField.name) ? "Password" : "Text" });
        }
      }
      return new VBox(sId, {
        items: [new Label({ text: oField.label, required: oField.required, labelFor: oControl }), oControl]
      }).addStyleClass("sapUiSmallMarginBottom");
    },

    onSaveDraft: function () {
      var oDraft = this.getModel("ui").getProperty("/draft");
      var sSet = this.getModel("ui").getProperty("/set");
      var oBody = {};
      var aMissing = [];
      try {
        oDraft.fields.forEach(function (f) {
          var bChanged = JSON.stringify(f.value) !== JSON.stringify(f.initial);
          if (oDraft.mode === "edit" && !bChanged) {
            return;
          }
          if (f.required && (f.value === "" || f.value === null || f.value === undefined)) {
            aMissing.push(f.label);
            return;
          }
          if (oDraft.mode === "create" && (f.value === "" || (Array.isArray(f.value) && !f.value.length))) {
            return;
          }
          oBody[f.name] = payloadValue(f, f.value);
        });
      } catch (e) {
        MessageBox.error(this.getText("invalidJson", [e.message]));
        return;
      }
      if (aMissing.length) {
        MessageBox.warning(this.getText("required", [aMissing.join(", ")]));
        return;
      }
      var sType = this.getText("set_" + sSet);
      var pCall = oDraft.mode === "create"
        ? this.service().create(sSet, oBody)
        : this.service().update(sSet, oDraft.id, oBody);
      this.run(pCall, this.getText(oDraft.mode === "create" ? "created" : "updated", [sType]));
      this.onCancelDraft();
    },

    onCancelDraft: function () {
      this.byId("editDialog").close();
    },

    // ── delete & actions ────────────────────────────────────────────────

    onDelete: function () {
      var oRow = this._selected();
      if (!oRow) {
        return;
      }
      var sSet = this.getModel("ui").getProperty("/set");
      var sName = oRow.name || oRow.title || oRow.displayName || oRow.id;
      MessageBox.confirm(this.getText("confirmDelete", [sName]), {
        onClose: function (sAction) {
          if (sAction === MessageBox.Action.OK) {
            this.run(this.service().remove(sSet, oRow.id), this.getText("deleted", [sName]));
          }
        }.bind(this)
      });
    },

    /** Lifecycle action of the selected row → unbound OData action <Action><Type>. */
    onAction: function (oEvent) {
      var oRow = this._selected();
      if (!oRow) {
        return;
      }
      var sOData = oEvent.getParameter("item").getKey();
      var oAction = this.getModel("ui").getProperty("/actions").filter(function (a) { return a.odataAction === sOData; })[0];
      this.askParameters(oAction.label, oAction.parameters).then(function (mParameters) {
        var oPayload = Object.assign({ id: oRow.id }, mParameters);
        this.run(this.service().invoke(sOData, oPayload), this.getText("actionDone", [oAction.label]));
      }.bind(this), this.showError.bind(this));
    }
  });
});
