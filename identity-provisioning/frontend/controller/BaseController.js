sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent",
  "sap/m/MessageBox",
  "uim/identityprovisioning/model/formatter"
], function (Controller, UIComponent, MessageBox, formatter) {
  "use strict";

  return Controller.extend("uim.identityprovisioning.controller.BaseController", {
    formatter: formatter,

    getRouter: function () {
      return UIComponent.getRouterFor(this);
    },

    getModel: function (sName) {
      return this.getView().getModel(sName);
    },

    getText: function (sKey, aArgs) {
      return this.getOwnerComponent().getModel("i18n").getResourceBundle().getText(sKey, aArgs);
    },

    /** Show an OData / backend error. */
    showError: function (oError) {
      if (oError && oError.canceled) {
        return;
      }
      var sMessage = (oError && (oError.message || oError.statusText)) || String(oError);
      MessageBox.error(sMessage);
    },

    /** Invoke an unbound OData action with parameters; resolves with the returned object. */
    invokeAction: function (sAction, mParameters) {
      var oOperation = this.getModel().bindContext("/" + sAction + "(...)");
      Object.keys(mParameters || {}).forEach(function (sName) {
        oOperation.setParameter(sName, mParameters[sName]);
      });
      return oOperation.execute().then(function () {
        return oOperation.getBoundContext().getObject();
      });
    },

    /** The OData service root ("odata/v4/identity-provisioning/"). */
    serviceUrl: function () {
      return this.getModel().getServiceUrl();
    },

    /** URL of one entity. */
    entityUrl: function (sSet, sId) {
      return this.serviceUrl() + sSet + "('" + encodeURIComponent(String(sId).replace(/'/g, "''")) + "')";
    },

    /**
     * GET a complete entity (table rows only carry the displayed properties,
     * because the model requests $select automatically).
     */
    readEntity: function (sSet, sId) {
      return fetch(this.entityUrl(sSet, sId), { credentials: "same-origin", headers: { "Accept": "application/json" } })
        .then(function (oResponse) {
          return oResponse.json().then(function (oBody) {
            if (!oResponse.ok) {
              throw new Error((oBody.error && oBody.error.message) || oResponse.statusText);
            }
            return oBody;
          });
        });
    },

    /**
     * PATCH several properties of an entity in ONE request (the backend validates
     * the entity as a whole, e.g. system type + URL). Fetches an X-CSRF-Token
     * first, as required behind the approuter.
     */
    patchEntity: function (sSet, sId, oData) {
      var sRoot = this.serviceUrl();
      var sUrl = this.entityUrl(sSet, sId);
      return fetch(sRoot, { method: "HEAD", headers: { "X-CSRF-Token": "Fetch" }, credentials: "same-origin" })
        .then(function (oResponse) {
          return fetch(sUrl, {
            method: "PATCH",
            credentials: "same-origin",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "OData-Version": "4.0",
              "X-CSRF-Token": oResponse.headers.get("X-CSRF-Token") || ""
            },
            body: JSON.stringify(oData)
          });
        }).then(function (oResponse) {
          return oResponse.json().catch(function () { return {}; }).then(function (oBody) {
            if (!oResponse.ok) {
              throw new Error((oBody.error && oBody.error.message) || oResponse.statusText);
            }
            return oBody;
          });
        });
    },

    /** Refresh the KPI header (Statistics singleton). */
    refreshStatistics: function () {
      var oHeader = this.byId("kpiHeader");
      var oBinding = oHeader && oHeader.getElementBinding();
      if (oBinding) {
        oBinding.refresh();
      }
    }
  });
});
