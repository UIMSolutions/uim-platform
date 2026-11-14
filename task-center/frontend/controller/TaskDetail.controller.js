sap.ui.define([
  "uim/taskcenter/controller/BaseController",
  "uim/taskcenter/model/models",
  "sap/ui/core/Fragment",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator"
], function (BaseController, models, Fragment, Filter, FilterOperator) {
  "use strict";

  var CHILD_LISTS = ["commentsList", "attachmentsTable", "historyTable"];

  return BaseController.extend("uim.taskcenter.controller.TaskDetail", {
    onInit: function () {
      this.getRouter().getRoute("task").attachPatternMatched(this._onMatched, this);
    },

    _onMatched: function (event) {
      if (this._taskId && this._taskId !== event.getParameter("arguments").id) {
        this.getView().unbindElement();
      }
      var id = event.getParameter("arguments").id;
      this._taskId = id;
      this.getModel("view").setProperty("/detail/can", this.formatter.actionFlags(null));
      this._path = "/Tasks('" + encodeURIComponent(id).replace(/'/g, "''") + "')";
      this.getView().bindElement({ path: this._path });
      this._updateActions();
      CHILD_LISTS.forEach(function (listId) {
        var binding = this.byId(listId).getBinding("items");
        binding.filter(new Filter("taskId", FilterOperator.EQ, id));
        if (binding.isSuspended()) {
          binding.resume();
        }
      }, this);
    },

    /** availableActions is caller specific: (re)read it and drive the footer buttons. */
    _updateActions: function () {
      if (!this._path) {
        return;
      }
      // caller specific and changed by every action: always read it fresh from the server
      this.getModel().bindContext(this._path, null, { $select: "availableActions" }).requestObject().then(function (row) {
        return row.availableActions;
      }).then(function (available) {
        this.getModel("view").setProperty("/detail/can", this.formatter.actionFlags(available));
      }.bind(this), function () {
        this.getModel("view").setProperty("/detail/can", this.formatter.actionFlags(null));
      }.bind(this));
    },

    onRefresh: function () {
      this.refreshAll();
      this._updateActions();
    },

    _context: function () {
      return this.getView().getBindingContext();
    },

    /** claim, release, escalate, resubmit — no input needed */
    onAction: function (event) {
      this.performTaskAction(this._taskId, event.getSource().data("action")).then(this._updateActions.bind(this), function () {});
    },

    /** approve, reject, complete, cancel — optional comment */
    onDecision: function (event) {
      this._openTaskDialog("decision", "DecisionDialog", { action: event.getSource().data("action"), comment: "" });
    },

    onOpenForward: function () {
      this._openTaskDialog("forward", "ForwardDialog", models.emptyForms().forward);
    },

    _openTaskDialog: function (key, fragment, form) {
      this._dialogs = this._dialogs || {};
      this.getModel("view").setProperty("/form/" + key, form);
      if (!this._dialogs[key]) {
        this._dialogs[key] = Fragment.load({ id: this.getView().getId(), name: "uim.taskcenter.fragment." + fragment, controller: this })
          .then(function (dialog) {
            this.getView().addDependent(dialog);
            return dialog;
          }.bind(this));
      }
      this._dialogs[key].then(function (dialog) {
        this._openDialogControl = dialog;
        dialog.open();
      }.bind(this));
    },

    onCloseDialog: function () {
      if (this._openDialogControl) {
        this._openDialogControl.close();
      }
    },

    onConfirmDecision: function () {
      var form = this.getModel("view").getProperty("/form/decision");
      this.performTaskAction(this._taskId, form.action, { comment: form.comment }).then(function () {
        this.onCloseDialog();
        this._updateActions();
      }.bind(this), function () {});
    },

    onConfirmForward: function () {
      var form = this.getModel("view").getProperty("/form/forward");
      if (!form.forwardTo) {
        this.toast("requiredMissing");
        return;
      }
      this.performTaskAction(this._taskId, "forward", form).then(function () {
        this.onCloseDialog();
        this._updateActions();
      }.bind(this), function () {});
    },

    onPostComment: function (event) {
      var content = event.getParameter("value");
      var context = this.byId("commentsList").getBinding("items").create({ taskId: this._taskId, content: content }, true);
      context.created().then(function () {
        this.toast("commentAdded");
        this.refreshAll();
      }.bind(this), function (error) {
        if (!error.canceled) {
          this.showError(error);
        }
      }.bind(this));
    }
  });
});
