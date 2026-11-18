sap.ui.define([
  "uim/objectstore/controller/BaseController",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast"
], function (BaseController, Filter, FilterOperator, MessageBox, MessageToast) {
  "use strict";

  return BaseController.extend("uim.objectstore.controller.Main", {

    onInit: function () {
      this.getRouter().getRoute("main").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sTab = (oEvent.getParameter("arguments") || {}).tab;
      if (sTab) {
        this.getModel("ui").setProperty("/selectedTab", sTab);
      }
    },

    // ── Navigation & refresh ────────────────────────────────────────────

    onTabSelect: function (oEvent) {
      this.getRouter().navTo("main", { tab: oEvent.getParameter("key") }, true);
    },

    onTile: function (oEvent) {
      this.getModel("ui").setProperty("/selectedTab", oEvent.getSource().data("tab"));
    },

    onRefresh: function () {
      this.getModel().refresh();
      MessageToast.show(this.getText("refreshed"));
    },

    onBucketPress: function (oEvent) {
      this._openBucket(oEvent.getSource().getBindingContext().getProperty("id"));
    },

    onBucketLink: function (oEvent) {
      this._openBucket(oEvent.getSource().getBindingContext().getProperty("bucketId"));
    },

    _openBucket: function (sId) {
      this.getRouter().navTo("bucket", { id: encodeURIComponent(sId) });
    },

    onSearch: function (sTableId, sPath, oEvent) {
      var sQuery = (oEvent.getParameter("query") || "").trim();
      var aFilters = sQuery ? [new Filter({ path: sPath || "name", operator: FilterOperator.Contains, value1: sQuery, caseSensitive: false })] : [];
      this.byId(sTableId).getBinding("items").filter(aFilters);
    },

    /** "standard: 3 · coldline: 1" from the Statistics usage records. */
    usageText: function (aUsage) {
      return (aUsage || []).filter(function (u) { return u.objects > 0; }).map(function (u) {
        return this.formatter.enumText(u.storageClass) + ": " + u.objects + " (" + this.formatter.bytes(u.bytes) + ")";
      }.bind(this)).join(" · ") || "–";
    },

    // ── Buckets ─────────────────────────────────────────────────────────

    onEmptyBucket: function () {
      var oContext = this._selected("bucketTable");
      if (!oContext) {
        return;
      }
      MessageBox.warning(this.getText("confirmEmpty", [oContext.getProperty("name"), oContext.getProperty("objectCount")]), {
        actions: [MessageBox.Action.DELETE, MessageBox.Action.CANCEL],
        emphasizedAction: MessageBox.Action.DELETE,
        onClose: function (sAction) {
          if (sAction === MessageBox.Action.DELETE) {
            this.runAction("EmptyBucket", oContext.getProperty("id"), "");
          }
        }.bind(this)
      });
    },

    onApplyLifecycle: function () {
      this.getModel("ui").setProperty("/busy", true);
      this.invokeAction("ApplyLifecycle", { bucketId: "" }).then(function (r) {
        var sText = this.getText("lifecycleDone", [r.expired, r.transitioned, r.versionsPurged]);
        if (r.messages && r.messages.length) {
          MessageBox.information(sText, { details: r.messages.join("\n") });
        } else {
          MessageToast.show(sText);
        }
        this.getModel().refresh();
      }.bind(this), this.showError.bind(this)).finally(function () {
        this.getModel("ui").setProperty("/busy", false);
      }.bind(this));
    },

    // ── Tools ───────────────────────────────────────────────────────────

    onEvaluateAccess: function () {
      var oUi = this.getModel("ui");
      var t = oUi.getProperty("/tools/access");
      if (!t.bucketId) {
        MessageToast.show(this.getText("selectBucket"));
        return;
      }
      this.invokeAction("EvaluateAccess", { bucketId: t.bucketId, principal: t.principal, action: t.action, key: t.key })
        .then(function (r) { oUi.setProperty("/tools/access/result", r); }, this.showError.bind(this));
    },

    onCheckCors: function () {
      var oUi = this.getModel("ui");
      var t = oUi.getProperty("/tools/cors");
      if (!t.bucketId) {
        MessageToast.show(this.getText("selectBucket"));
        return;
      }
      var aHeaders = (t.requestHeaders || "").split(",").map(function (s) { return s.trim(); }).filter(Boolean);
      this.invokeAction("CheckCors", { bucketId: t.bucketId, origin: t.origin, method: t.method, requestHeaders: aHeaders })
        .then(function (r) { oUi.setProperty("/tools/cors/result", r); }, this.showError.bind(this));
    },

    onVerifyCredentials: function () {
      var oUi = this.getModel("ui");
      var t = oUi.getProperty("/tools/credentials");
      this.invokeAction("VerifyCredentials", { accessKeyId: t.accessKeyId.trim(), secretAccessKey: t.secretAccessKey.trim() })
        .then(function (r) {
          oUi.setProperty("/tools/credentials/result", r);
          this.byId("bindingTable").getBinding("items").refresh();
        }.bind(this), this.showError.bind(this));
    }
  });
});
