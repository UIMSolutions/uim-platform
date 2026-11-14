sap.ui.define([
  "uim/translation/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageToast) {
  "use strict";

  return BaseController.extend("uim.translation.controller.ProjectDetail", {

    onInit: function () {
      this.getRouter().getRoute("project").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this._sId = sId;
      this.getView().bindElement({
        path: "/TranslationProjects('" + sId.replace(/'/g, "''") + "')",
        parameters: { $select: "targetLanguages" }
      });
      var oBinding = this.byId("projectTextTable").getBinding("items");
      oBinding.filter(new Filter("projectId", FilterOperator.EQ, sId));
      if (oBinding.isSuspended()) {
        oBinding.resume();
      }
    },

    _refresh: function () {
      this.getView().getElementBinding().refresh();
      this.byId("projectTextTable").getBinding("items").refresh();
    },

    _run: function (sAction, mParameters, sMessageKey) {
      this.getModel("ui").setProperty("/busy", true);
      mParameters.id = this._sId;
      return this.invokeAction(sAction, mParameters).then(function (oResult) {
        MessageToast.show(this.getText(sMessageKey, [oResult.name, this.formatter.enumText(oResult.status), oResult.completionPercent]));
        this._refresh();
      }.bind(this), this.showError.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    },

    /** Translate every text into every target language (TranslateTranslationProject). */
    onTranslate: function () {
      this._run("TranslateTranslationProject", {}, "projectTranslated");
    },

    /** Re-translate machine translations too (reviewed translations are kept). */
    onRetranslate: function () {
      this._run("TranslateTranslationProject", { force: "true" }, "projectTranslated");
    },

    onActivate: function () {
      this._run("ActivateTranslationProject", {}, "actionDoneProject");
    },

    onArchive: function () {
      this._run("ArchiveTranslationProject", {}, "actionDoneProject");
    },

    /** Add a text to this project. */
    onAddText: function () {
      this.askParameters(this.getText("addText"), "name,sourceText").then(function (m) {
        var oContext = this.byId("projectTextTable").getBinding("items").create({
          projectId: this._sId, name: m.name, sourceText: m.sourceText
        });
        return oContext.created().then(function () {
          MessageToast.show(this.getText("created", ["Text"]));
          this.getView().getElementBinding().refresh();
        }.bind(this));
      }.bind(this)).catch(this.showError.bind(this));
    },

    _selectedText: function () {
      var oItem = this.byId("projectTextTable").getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
      }
      return oItem && oItem.getBindingContext();
    },

    /** Enter the translation of one language manually (reviewed). */
    onSetTranslation: function () {
      var oContext = this._selectedText();
      if (!oContext) {
        return;
      }
      var aTargets = this.getView().getBindingContext().getProperty("targetLanguages") || [];
      this.askParameters(this.getText("action_SetTranslationProjectText"), "language,text", { language: aTargets[0] })
        .then(function (m) {
          m.id = oContext.getProperty("id");
          return this.invokeAction("SetTranslationProjectText", m).then(function () {
            MessageToast.show(this.getText("translationSaved"));
            this._refresh();
          }.bind(this));
        }.bind(this)).catch(this.showError.bind(this));
    },

    onReviewText: function () {
      var oContext = this._selectedText();
      if (!oContext) {
        return;
      }
      this.invokeAction("ReviewProjectText", { id: oContext.getProperty("id") }).then(function () {
        MessageToast.show(this.getText("reviewed"));
        this._refresh();
      }.bind(this), this.showError.bind(this));
    },

    onClose: function () {
      this.getRouter().navTo("main", { tab: "projects" });
    }
  });
});
