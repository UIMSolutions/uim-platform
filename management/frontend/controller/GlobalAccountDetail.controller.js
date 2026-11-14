sap.ui.define([
  "uim/management/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/StandardListItem",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, StandardListItem, MessageToast) {
  "use strict";

  return BaseController.extend("uim.management.controller.GlobalAccountDetail", {

    onInit: function () {
      this.getRouter().getRoute("globalAccount").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      this._sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this.getView().bindElement({ path: "/GlobalAccounts('" + this._sId.replace(/'/g, "''") + "')" });

      var f = this.formatter;
      var oByGa = new Filter("globalAccountId", FilterOperator.EQ, this._sId);
      this.byId("gaDirectories").bindItems({
        path: "/Directories",
        filters: [oByGa],
        template: new StandardListItem({
          title: "{displayName}",
          description: "{description}",
          icon: "sap-icon://folder",
          info: "{= ${subaccountCount} + ' ' + ${i18n>tabSubaccounts} }"
        }),
        templateShareable: false
      });
      this.byId("gaSubaccounts").bindItems({
        path: "/Subaccounts",
        filters: [oByGa],
        template: new StandardListItem({
          title: "{displayName}",
          description: "{subdomain} · {region}",
          icon: "sap-icon://folder-full",
          type: "Navigation",
          press: this.onSubaccountPress.bind(this),
          info: { path: "status", formatter: f.enumText },
          infoState: { path: "status", formatter: f.statusState }
        }),
        templateShareable: false
      });
    },

    onNavBack: function () {
      this.getRouter().navTo("main", { tab: "globalAccounts" });
    },

    onSubaccountPress: function (oEvent) {
      var sId = oEvent.getSource().getBindingContext().getProperty("id");
      this.getRouter().navTo("subaccount", { id: encodeURIComponent(sId) });
    },

    onChanged: function () {
      MessageToast.show(this.getText("saved"));
    },

    _refresh: function () {
      this.getView().getElementBinding().refresh();
    },

    onSuspend: function () {
      this.callAction("SuspendGlobalAccount", { id: this._sId }).then(this._refresh.bind(this), function () {});
    },

    onReactivate: function () {
      this.callAction("ReactivateGlobalAccount", { id: this._sId }).then(this._refresh.bind(this), function () {});
    }
  });
});
