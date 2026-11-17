sap.ui.define([
  "uim/workzone/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox"
], function (BaseController, Filter, FilterOperator, MessageBox) {
  "use strict";

  /** Sections listing the workspace's aggregates (absolute, suspended bindings in the view). */
  var SECTIONS = ["pageTable", "contentTable", "eventTable", "feedList"];

  return BaseController.extend("uim.workzone.controller.WorkspaceDetail", {
    onInit: function () {
      this.getRouter().getRoute("workspace").attachPatternMatched(this._onRouteMatched, this);
      // header member count follows the members table (collection property)
      this.byId("memberTable").attachUpdateFinished(function (oEvent) {
        this.getModel("ui").setProperty("/memberCount", oEvent.getParameter("total"));
      }, this);
    },

    _onRouteMatched: function (oEvent) {
      this._sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this.getView().bindElement({ path: "/Workspaces('" + this._sId.replace(/'/g, "''") + "')" });
      SECTIONS.forEach(function (sControl) {
        var oBinding = this.byId(sControl).getBinding("items");
        oBinding.filter([new Filter("workspaceId", FilterOperator.EQ, this._sId)]);
        if (oBinding.isSuspended()) {
          oBinding.resume();
        }
      }, this);
    },

    onNavHome: function () {
      this.getRouter().navTo("overview");
    },

    onNavList: function () {
      this.getRouter().navTo("resource", { set: "Workspaces" });
    },

    onAddMember: function () {
      this.askParameters(this.getText("addMember"), ["userId", "displayName", "role"]).then(function (m) {
        this.run(this.service().invoke("AddMemberWorkspace", Object.assign({ id: this._sId }, m)), this.getText("memberAdded"));
      }.bind(this), this.showError.bind(this));
    },

    onRemoveMember: function (oEvent) {
      var oMember = oEvent.getSource().getBindingContext().getObject();
      MessageBox.confirm(this.getText("confirmRemoveMember", [oMember.displayName || oMember.userId]), {
        onClose: function (sAction) {
          if (sAction === MessageBox.Action.OK) {
            this.run(this.service().invoke("RemoveMemberWorkspace", { id: this._sId, userId: oMember.userId }),
              this.getText("memberRemoved"));
          }
        }.bind(this)
      });
    },

    onLifecycle: function (sAction) {
      this.run(this.service().invoke(sAction, { id: this._sId }), this.getText("actionDone", [sAction]));
    }
  });
});
