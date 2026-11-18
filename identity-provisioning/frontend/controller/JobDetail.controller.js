sap.ui.define([
  "uim/identityprovisioning/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageBox, MessageToast) {
  "use strict";

  return BaseController.extend("uim.identityprovisioning.controller.JobDetail", {

    onInit: function () {
      this.getRouter().getRoute("job").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      this._sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this.getView().bindElement({
        path: "/ProvisioningJobs('" + this._sId.replace(/'/g, "''") + "')",
        events: { dataReceived: this._filterTables.bind(this) }
      });
      this._filterTables();
    },

    /** Log: last run / failed / all runs of this job. Entities: the job's (source, target) pair. */
    _filterTables: function () {
      var oContext = this.getView().getBindingContext();
      var oJob = oContext && oContext.getObject();
      if (!oJob || oJob.id !== this._sId) {
        return;
      }
      var sScope = this.getModel("ui").getProperty("/jobLogScope");
      var aLog = [new Filter("jobId", FilterOperator.EQ, this._sId)];
      if (sScope === "last") {
        aLog.push(new Filter("runNumber", FilterOperator.EQ, oJob.runCount || 0));
      } else if (sScope === "failed") {
        aLog.push(new Filter("status", FilterOperator.EQ, "failed"));
      }
      this._resume(this.byId("jobLogTable").getBinding("items"), aLog);
      this._resume(this.byId("jobEntityTable").getBinding("items"), [
        new Filter("sourceSystemId", FilterOperator.EQ, oJob.sourceSystemId),
        new Filter("targetSystemId", FilterOperator.EQ, oJob.targetSystemId)
      ]);
    },

    _resume: function (oBinding, aFilters) {
      oBinding.filter(new Filter({ filters: aFilters, and: true }));
      if (oBinding.isSuspended()) {
        oBinding.resume();
      }
    },

    onLogScope: function () {
      this._filterTables();
    },

    _refresh: function () {
      this.getView().getElementBinding().refresh();
    },

    _run: function (sAction, sMessageKey) {
      this.getModel("ui").setProperty("/busy", true);
      return this.invokeAction(sAction, { id: this._sId }).then(function (oResult) {
        MessageToast.show(this.getText(sMessageKey, [oResult.name, this.formatter.enumText(oResult.status), oResult.statusMessage]),
          { duration: 5000, width: "32rem" });
        this._refresh();
      }.bind(this), this.showError.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    },

    onRun: function () {
      this._run("RunProvisioningJob", "jobRun");
    },

    onCancel: function () {
      this._run("CancelProvisioningJob", "jobChanged");
    },

    onResume: function () {
      this._run("ResumeProvisioningJob", "jobChanged");
    },

    onReset: function () {
      MessageBox.confirm(this.getText("confirmReset"), {
        onClose: function (sAction) {
          if (sAction === MessageBox.Action.OK) {
            this._run("ResetProvisioningJob", "jobChanged");
          }
        }.bind(this)
      });
    },

    onClose: function () {
      this.getRouter().navTo("main", { tab: "jobs" });
    }
  });
});
