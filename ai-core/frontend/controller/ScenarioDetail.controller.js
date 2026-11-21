sap.ui.define([
  "uim/aicore/controller/BaseController",
  "uim/aicore/model/models"
], function (BaseController, models) {
  "use strict";

  return BaseController.extend("uim.aicore.controller.ScenarioDetail", {
    onInit: function () {
      this.getRouter().getRoute("scenario").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      var key = event.getParameter("arguments").key;
      var parts = models.splitKey(key);
      this.bindTo("Scenarios", key);
      ["scenarioExecutables", "scenarioConfigurations", "scenarioArtifacts"].forEach(function (id) {
        this.filterTable(id, { resourceGroupId: parts.group, scenarioId: parts.id });
      }, this);
    }
  });
});
