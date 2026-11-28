sap.ui.define([
  "uim/ailaunchpad/controller/BaseController",
  "sap/ui/model/json/JSONModel",
  "sap/ui/model/Sorter",
  "uim/ailaunchpad/model/models"
], function (BaseController, JSONModel, Sorter, models) {
  "use strict";

  /**
   * The launchpad: the tiles of the current user (LaunchpadTiles — the
   * server filters them by the user's scopes and adds the KPI values),
   * grouped by section, searchable. A tile opens an app route
   * ("lifecycle/executions") or an external URL.
   */
  return BaseController.extend("uim.ailaunchpad.controller.Launchpad", {
    onInit: function () {
      this.getView().setModel(new JSONModel({ tiles: [], groups: [], query: "", busy: true, empty: false }), "launchpad");
      this.getRouter().getRoute("launchpad").attachPatternMatched(function () {
        var view = this.getModel("view");
        view.setProperty("/page", "launchpad");
        view.setProperty("/pageTitle", "");
        view.setProperty("/tab", "");
        this.loadTiles();
      }, this);
    },

    /** Read the tiles and the statistics (KPI values change while the user works). */
    loadTiles: function () {
      var model = this.getModel("launchpad");
      model.setProperty("/busy", true);
      var list = this.getModel().bindList("/LaunchpadTiles", null, [new Sorter("sortOrder")]);
      var stats = this.getModel().bindContext("/Statistics");
      return Promise.all([
        list.requestContexts(0, 500),
        stats.requestObject().catch(function () { return {}; })
      ]).then(function (results) {
        var tiles = results[0].map(function (c) { return c.getObject(); });
        model.setProperty("/tiles", tiles);
        model.setProperty("/empty", (results[1] || {}).workspaces === 0);
        this.onFilterTiles();
      }.bind(this), this.showError.bind(this)).finally(function () {
        model.setProperty("/busy", false);
        list.destroy();
        stats.destroy();
      });
    },

    onFilterTiles: function () {
      var model = this.getModel("launchpad");
      model.setProperty("/groups", models.groupTiles(model.getProperty("/tiles"), model.getProperty("/query")));
    },

    onTilePress: function (event) {
      var tile = event.getSource().getBindingContext("launchpad").getObject();
      if (tile.targetType === "url") {
        window.open(tile.target, "_blank", "noopener,noreferrer");
        return;
      }
      var target = models.parseTarget(tile.target);
      this.getRouter().navTo(target.route, target.tab ? { tab: target.tab } : {});
    },

    onRefresh: function () {
      this.loadTiles();
    },

    onSeed: function () {
      this.invokeAction("SeedDemoData", {}).then(function (r) {
        this.toast("seeded", [r.workspaces, r.scenarios, r.executions, r.prompts]);
        this.loadTiles();
      }.bind(this), this.showError.bind(this));
    }
  });
});
