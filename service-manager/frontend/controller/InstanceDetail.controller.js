sap.ui.define([
  "uim/servicemanager/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/ColumnListItem",
  "sap/m/Text",
  "sap/m/ObjectStatus",
  "sap/m/Button"
], function (BaseController, Filter, FilterOperator, ColumnListItem, Text, ObjectStatus, Button) {
  "use strict";

  return BaseController.extend("uim.servicemanager.controller.InstanceDetail", {
    onInit: function () {
      this.getRouter().getRoute("instance").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      var id = event.getParameter("arguments").id;
      this._instanceId = id;
      var key = "'" + String(id).replace(/'/g, "''") + "'";
      this.getView().bindElement({ path: "/ServiceInstances(" + key + ")", parameters: { $$updateGroupId: "$auto" } });

      var byInstance = new Filter("instanceId", FilterOperator.EQ, id);
      var byResource = new Filter("resourceId", FilterOperator.EQ, id);
      var formatter = this.formatter;

      this.byId("detailBindings").bindItems({
        path: "/ServiceBindings", filters: [byInstance], parameters: { $orderby: "name" },
        template: new ColumnListItem({ cells: [
          new Text({ text: "{name}" }),
          new ObjectStatus({ text: { path: "status", formatter: formatter.enumText }, state: { path: "status", formatter: formatter.statusState } }),
          new Text({ text: { path: "credentials", formatter: formatter.prettyJson }, renderWhitespace: true, maxLines: 6 })
        ] })
      });
      this.byId("detailOperations").bindItems({
        path: "/Operations", filters: [byResource], parameters: { $orderby: "createdAt desc" },
        template: new ColumnListItem({ cells: [
          new Text({ text: "{description}" }),
          new ObjectStatus({ text: { path: "status", formatter: formatter.enumText }, state: { path: "status", formatter: formatter.statusState } }),
          new Text({ text: "{completedAt}" })
        ] })
      });
      this.byId("detailLabels").bindItems({
        path: "/Labels", filters: [byResource], parameters: { $orderby: "key" },
        template: new ColumnListItem({ cells: [
          new Text({ text: "{key}" }),
          new Text({ text: "{value}" }),
          new Button({ icon: "sap-icon://delete", type: "Transparent", press: this.onDeleteLabel.bind(this) })
        ] })
      });
    },

    onRefresh: function () {
      this.refreshAll();
    },

    onOpenDashboard: function (event) {
      var url = event.getSource().getText();
      if (url) {
        window.open(url, "_blank", "noopener");
      }
    },

    onAddLabel: function () {
      var view = this.getModel("view");
      var label = view.getProperty("/newLabel");
      if (!label.key) {
        this.toast("requiredMissing");
        return;
      }
      var context = this.byId("detailLabels").getBinding("items").create({
        resourceType: "serviceInstance", resourceId: this._instanceId, key: label.key, value: label.value || ""
      }, true);
      context.created().then(function () {
        view.setProperty("/newLabel", { key: "", value: "" });
      }, function (error) {
        if (!error.canceled) {
          this.showError(error);
        }
        context.delete().catch(function () { /* already gone */ });
      }.bind(this));
    },

    onDeleteLabel: function (event) {
      event.getSource().getBindingContext().delete().catch(this.showError.bind(this));
    }
  });
});
