sap.ui.define([
  "sap/ui/model/json/JSONModel",
  "sap/ui/model/BindingMode",
  "sap/ui/Device"
], function (JSONModel, BindingMode, Device) {
  "use strict";

  /** Side navigation: entity sets grouped like the SAP Build Work Zone admin console. */
  var NAVIGATION = [
    { key: "overview", text: "navOverview", icon: "sap-icon://home" },
    { key: "collaboration", text: "navCollaboration", icon: "sap-icon://collaborate", items: [
      { key: "Workspaces", icon: "sap-icon://group" },
      { key: "Workpages", icon: "sap-icon://web-cam" },
      { key: "ContentItems", icon: "sap-icon://document-text" },
      { key: "FeedEntries", icon: "sap-icon://feed" },
      { key: "Events", icon: "sap-icon://appointment" },
      { key: "Surveys", icon: "sap-icon://survey" },
      { key: "ForumTopics", icon: "sap-icon://discussion" },
      { key: "KnowledgeBaseArticles", icon: "sap-icon://course-book" },
      { key: "Channels", icon: "sap-icon://share-2" }
    ] },
    { key: "inbox", text: "navInbox", icon: "sap-icon://inbox", items: [
      { key: "Tasks", icon: "sap-icon://task" },
      { key: "Notifications", icon: "sap-icon://bell" }
    ] },
    { key: "integration", text: "navIntegration", icon: "sap-icon://chain-link", items: [
      { key: "Cards", icon: "sap-icon://card" },
      { key: "Apps", icon: "sap-icon://add-product" },
      { key: "Widgets", icon: "sap-icon://grid" },
      { key: "ContentProviders", icon: "sap-icon://connected" },
      { key: "ShellPlugins", icon: "sap-icon://puzzle" }
    ] },
    { key: "sites", text: "navSites", icon: "sap-icon://world", items: [
      { key: "Sites", icon: "sap-icon://world" },
      { key: "NavigationItems", icon: "sap-icon://menu" },
      { key: "Themes", icon: "sap-icon://palette" },
      { key: "PageTemplates", icon: "sap-icon://screen-split-three" }
    ] },
    { key: "administration", text: "navAdministration", icon: "sap-icon://key-user-settings", items: [
      { key: "UserProfiles", icon: "sap-icon://employee" },
      { key: "UserGroups", icon: "sap-icon://group-2" },
      { key: "Roles", icon: "sap-icon://role" },
      { key: "Tags", icon: "sap-icon://tag" }
    ] }
  ];

  return {
    createDeviceModel: function () {
      var oModel = new JSONModel(Device);
      oModel.setDefaultBindingMode(BindingMode.OneWay);
      return oModel;
    },

    /** View state: busy flag, side navigation, create/edit drafts. */
    createViewStateModel: function () {
      return new JSONModel({
        busy: false,
        sideExpanded: !Device.system.phone,
        selectedNav: "overview",
        set: "",
        draft: { title: "", mode: "create", fields: [] }
      });
    },

    createNavigationModel: function () {
      return new JSONModel({ items: NAVIGATION });
    },

    /**
     * Load the resource catalogue (GET api/v1/resources). Falls back to the
     * catalogue shipped in localService when the backend is not reachable.
     */
    loadCatalog: function (sUrl, sFallbackUrl) {
      function load(sFrom) {
        return fetch(sFrom, { credentials: "same-origin", headers: { Accept: "application/json" } }).then(function (oResponse) {
          if (!oResponse.ok) {
            throw new Error(oResponse.status + " " + oResponse.statusText);
          }
          return oResponse.json();
        });
      }
      return load(sUrl).catch(function () {
        return load(sFallbackUrl);
      }).then(function (oData) {
        var mBySet = {};
        (oData.items || []).forEach(function (oResource) {
          mBySet[oResource.odataEntitySet] = oResource;
        });
        return new JSONModel({ items: oData.items || [], bySet: mBySet });
      });
    }
  };
});
