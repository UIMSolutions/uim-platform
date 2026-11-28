sap.ui.define([
  "uim/ailaunchpad/controller/BaseController",
  "uim/ailaunchpad/model/models"
], function (BaseController, models) {
  "use strict";

  /** Generative AI hub: prompts, collections and the playground. */
  return BaseController.extend("uim.ailaunchpad.controller.GenAI", {
    onInit: function () {
      this.attachPage("genai", "genaiTitle", "prompts");
    },

    /** Open the selected prompt in the playground. */
    onTryPrompt: function () {
      var context = this.selected("promptsTable");
      if (!context) {
        return;
      }
      this.getModel("view").setProperty("/playground/promptId", context.getProperty("id"));
      this.getRouter().navTo("genai", { tab: "playground" }, true);
      this.loadPlaygroundPrompt(context.getProperty("id"));
    },

    onPlaygroundPrompt: function () {
      this.loadPlaygroundPrompt(this.getModel("view").getProperty("/playground/promptId"));
    },

    /** Read the prompt and offer one input per placeholder (keeping values typed before). */
    loadPlaygroundPrompt: function (id) {
      var view = this.getModel("view");
      if (!id) {
        view.setProperty("/playground/prompt", null);
        view.setProperty("/playground/inputs", []);
        return Promise.resolve();
      }
      var binding = this.getModel().bindContext(models.entityPath("Prompts", id));
      return binding.requestObject().then(function (p) {
        var before = {};
        (view.getProperty("/playground/inputs") || []).forEach(function (i) { before[i.name] = i.value; });
        var names = p.inputParams && p.inputParams.length ? p.inputParams : models.placeholders(p.systemMessage, p.userMessage);
        view.setProperty("/playground/prompt", p);
        view.setProperty("/playground/result", null);
        view.setProperty("/playground/inputs", names.map(function (name) {
          return { name: name, value: before[name] || "" };
        }));
      }, this.showError.bind(this)).finally(function () {
        binding.destroy();
      });
    },

    onRunPrompt: function () {
      var view = this.getModel("view");
      var pg = view.getProperty("/playground");
      if (!pg.promptId) {
        this.toast("selectPrompt");
        return;
      }
      var inputs = {};
      var missing = false;
      pg.inputs.forEach(function (i) {
        inputs[i.name] = i.value;
        missing = missing || !String(i.value || "").trim();
      });
      if (missing) {
        this.toast("requiredMissing");
        return;
      }
      view.setProperty("/playground/busy", true);
      this.invokeAction("RunPrompt", { id: pg.promptId, inputs: JSON.stringify(inputs) }, true).then(function (r) {
        view.setProperty("/playground/result", r);
      }, this.showError.bind(this)).finally(function () {
        view.setProperty("/playground/busy", false);
      });
    }
  });
});
