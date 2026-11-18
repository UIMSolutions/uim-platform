sap.ui.define([
  "uim/objectstore/controller/BaseController",
  "sap/ui/core/Fragment",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageBox",
  "sap/m/MessageToast",
  "sap/m/library"
], function (BaseController, Fragment, Filter, FilterOperator, MessageBox, MessageToast, mobileLibrary) {
  "use strict";

  /** Tables of the bucket configuration, filtered by bucketId. */
  var CHILD_TABLES = ["policyTable", "lifecycleTable", "corsTable", "bindingTable"];

  return BaseController.extend("uim.objectstore.controller.BucketDetail", {

    onInit: function () {
      this.getRouter().getRoute("bucket").attachPatternMatched(this._onRouteMatched, this);
    },

    _onRouteMatched: function (oEvent) {
      var sId = decodeURIComponent(oEvent.getParameter("arguments").id);
      this._sBucketId = sId;
      this.getView().bindElement({
        path: "/Buckets('" + sId.replace(/'/g, "''") + "')",
        parameters: { $select: "labels,status,versioningEnabled,objectCount" },
        events: {
          dataReceived: function (oData) {
            if (!oData.getParameter("data")) {
              MessageBox.error(this.getText("bucketNotFound", [sId]), { onClose: this.onNavBack.bind(this) });
            }
          }.bind(this)
        }
      });
      CHILD_TABLES.forEach(function (sTable) {
        var oBinding = this.byId(sTable).getBinding("items");
        oBinding.filter(new Filter("bucketId", FilterOperator.EQ, sId));
        if (oBinding.isSuspended()) {
          oBinding.resume();
        }
      }, this);
      this.getModel("ui").setProperty("/browser", { bucketId: sId, prefix: "", crumbs: [], rows: [], selected: null });
      this._loadFolder("");
    },

    onNavBack: function () {
      this.getRouter().navTo("main", { tab: "buckets" }, true);
    },

    // ── Folder browser ──────────────────────────────────────────────────

    _loadFolder: function (sPrefix) {
      var oUi = this.getModel("ui");
      var sBucket = this._sBucketId;
      this.getJson("/buckets/" + encodeURIComponent(sBucket) + "/list?delimiter=/&prefix=" + encodeURIComponent(sPrefix))
        .then(function (r) {
          var aRows = r.commonPrefixes.map(function (p) { return { name: p, folder: true }; }).concat(r.objects);
          var aCrumbs = [{ text: r.bucketName, prefix: "" }];
          var sPath = "";
          sPrefix.split("/").filter(Boolean).forEach(function (sPart) {
            sPath += sPart + "/";
            aCrumbs.push({ text: sPart, prefix: sPath });
          });
          // the last crumb is the current location
          var oCurrent = aCrumbs.pop();
          oUi.setProperty("/browser/prefix", sPrefix);
          oUi.setProperty("/browser/bucketName", r.bucketName);
          oUi.setProperty("/browser/crumbs", sPrefix ? aCrumbs : []);
          oUi.setProperty("/browser/rows", aRows);
          this.byId("crumbs").setCurrentLocationText(oCurrent.text);
          this.byId("browserTable").removeSelections(true);
        }.bind(this), this.showError.bind(this));
    },

    onOpenFolder: function (oEvent) {
      var oRow = oEvent.getSource().getBindingContext("ui").getObject();
      if (oRow.folder) {
        this._loadFolder(oRow.name);
      }
    },

    onCrumb: function (oEvent) {
      this._loadFolder(oEvent.getSource().getBindingContext("ui").getProperty("prefix"));
    },

    onUp: function () {
      var sPrefix = this.getModel("ui").getProperty("/browser/prefix").replace(/[^/]*\/$/, "");
      this._loadFolder(sPrefix);
    },

    /** The selected object row (not a folder), or null. */
    _selectedObject: function () {
      var oItem = this.byId("browserTable").getSelectedItem();
      var oRow = oItem && oItem.getBindingContext("ui").getObject();
      if (!oRow || oRow.folder) {
        MessageToast.show(this.getText("selectObject"));
        return null;
      }
      this.getModel("ui").setProperty("/browser/selected", oRow);
      return oRow;
    },

    _reload: function () {
      this._loadFolder(this.getModel("ui").getProperty("/browser/prefix"));
      this.getView().getElementBinding().refresh();
    },

    /** Upload a file to <prefix><file name> (base64 through the PutObjectContent action). */
    onUpload: function (oEvent) {
      var oFile = (oEvent.getParameter("files") || [])[0];
      if (!oFile) {
        return;
      }
      var sKey = this.getModel("ui").getProperty("/browser/prefix") + oFile.name;
      var oUi = this.getModel("ui");
      oUi.setProperty("/busy", true);
      new Promise(function (resolve, reject) {
        var oReader = new FileReader();
        oReader.onload = function () { resolve(String(oReader.result).replace(/^data:[^,]*,/, "")); };
        oReader.onerror = function () { reject(oReader.error); };
        oReader.readAsDataURL(oFile);
      }).then(function (sBase64) {
        return this.invokeAction("PutObjectContent", {
          bucketId: this._sBucketId, key: sKey, content: sBase64, contentEncoding: "base64",
          contentType: oFile.type || "application/octet-stream"
        });
      }.bind(this)).then(function (oObject) {
        MessageToast.show(this.getText("uploaded", [sKey, oObject.currentVersion]));
        this._reload();
      }.bind(this), this.showError.bind(this)).finally(function () {
        oUi.setProperty("/busy", false);
        this.byId("uploader").clear();
      }.bind(this));
    },

    onNewObject: function () {
      this.onCreate("StorageObjects", { bucketId: this._sBucketId, name: this.getModel("ui").getProperty("/browser/prefix") });
    },

    /** Text objects of the create dialog are written through PutObjectContent as well. */
    createEntity: function (sSet, oData) {
      if (sSet !== "StorageObjects") {
        return BaseController.prototype.createEntity.apply(this, arguments);
      }
      return this.invokeAction("PutObjectContent", {
        bucketId: this._sBucketId, key: oData.name, content: oData.content || "", contentEncoding: "text",
        contentType: oData.contentType || "text/plain", metadata: oData.metadata || []
      });
    },

    onCreateChild: function (sSet) {
      this.onCreate(sSet, { bucketId: this._sBucketId });
    },

    onCreated: function () {
      this._reload();
    },

    onChanged: function () {
      this.getModel().refresh();
      this._reload();
    },

    onDownload: function () {
      var oRow = this._selectedObject();
      if (oRow) {
        mobileLibrary.URLHelper.redirect(this.contentUrl(this._sBucketId, oRow.name, 0, true), true);
      }
    },

    onObjectAction: function (sAction, sParameters) {
      var oRow = this._selectedObject();
      if (oRow) {
        this.runAction(sAction, oRow.id, sParameters, { targetBucketId: this.getModel("ui").getProperty("/browser/bucketName"),
          targetKey: oRow.name.replace(/(\.[^./]*)?$/, "-copy$1") });
      }
    },

    onDeleteObject: function () {
      var oRow = this._selectedObject();
      if (!oRow) {
        return;
      }
      var bVersioned = this.getView().getBindingContext().getProperty("versioningEnabled");
      MessageBox.confirm(this.getText(bVersioned ? "confirmDeleteVersioned" : "confirmDeleteObject", [oRow.name]), {
        emphasizedAction: MessageBox.Action.OK,
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.OK) {
            return;
          }
          this.getModel().bindContext("/StorageObjects('" + oRow.id + "')").getBoundContext().delete().then(function () {
            MessageToast.show(this.getText("deleted", [oRow.name]));
            this.onChanged();
          }.bind(this), this.showError.bind(this));
        }.bind(this)
      });
    },

    // ── Versions ────────────────────────────────────────────────────────

    onVersions: function () {
      var oRow = this._selectedObject();
      if (!oRow) {
        return;
      }
      if (!this._pVersionsDialog) {
        this._pVersionsDialog = Fragment.load({
          id: this.getView().getId(),
          name: "uim.objectstore.fragment.VersionsDialog",
          controller: this
        }).then(function (oDialog) {
          this.getView().addDependent(oDialog);
          return oDialog;
        }.bind(this));
      }
      this._pVersionsDialog.then(function (oDialog) {
        var oBinding = this.byId("versionTable").getBinding("items");
        oBinding.filter(new Filter("objectId", FilterOperator.EQ, oRow.id));
        if (oBinding.isSuspended()) {
          oBinding.resume();
        }
        oDialog.open();
      }.bind(this));
    },

    _selectedVersion: function () {
      var oItem = this.byId("versionTable").getSelectedItem();
      if (!oItem) {
        MessageToast.show(this.getText("selectFirst"));
        return null;
      }
      return oItem.getBindingContext();
    },

    onDownloadVersion: function () {
      var oContext = this._selectedVersion();
      if (oContext && !oContext.getProperty("isDeleteMarker")) {
        mobileLibrary.URLHelper.redirect(this.contentUrl(this._sBucketId, oContext.getProperty("objectKey"),
          oContext.getProperty("versionNumber"), true), true);
      }
    },

    onPromoteVersion: function () {
      var oContext = this._selectedVersion();
      if (oContext) {
        this.runAction("PromoteObjectVersion", oContext.getProperty("id"), "").then(function () {
          this.byId("versionTable").getBinding("items").refresh();
        }.bind(this));
      }
    },

    onDeleteVersion: function () {
      var oContext = this._selectedVersion();
      if (!oContext) {
        return;
      }
      MessageBox.confirm(this.getText("confirmDeleteVersion", [oContext.getProperty("name")]), {
        emphasizedAction: MessageBox.Action.OK,
        onClose: function (sAction) {
          if (sAction === MessageBox.Action.OK) {
            oContext.delete().then(this.onChanged.bind(this), this.showError.bind(this));
          }
        }.bind(this)
      });
    },

    onCloseVersions: function () {
      this.byId("versionsDialog").close();
    },

    // ── Bucket actions ──────────────────────────────────────────────────

    onBucketAction: function (sAction) {
      this.runAction(sAction, this._sBucketId, "");
    },

    onEmpty: function () {
      var oContext = this.getView().getBindingContext();
      MessageBox.warning(this.getText("confirmEmpty", [oContext.getProperty("name"), oContext.getProperty("objectCount")]), {
        actions: [MessageBox.Action.DELETE, MessageBox.Action.CANCEL],
        emphasizedAction: MessageBox.Action.DELETE,
        onClose: function (sAction) {
          if (sAction === MessageBox.Action.DELETE) {
            this.runAction("EmptyBucket", this._sBucketId, "");
          }
        }.bind(this)
      });
    },

    onApplyLifecycle: function () {
      this.invokeAction("ApplyLifecycle", { bucketId: this._sBucketId }).then(function (r) {
        MessageToast.show(this.getText("lifecycleDone", [r.expired, r.transitioned, r.versionsPurged]));
        this.onChanged();
      }.bind(this), this.showError.bind(this));
    },

    /** "→ coldline after 30 d · delete after 365 d · old versions after 7 d". */
    ruleText: function (iTransition, sClass, iExpiration, iNoncurrent) {
      var a = [];
      if (iTransition > 0) { a.push(this.getText("ruleTransition", [this.formatter.enumText(sClass), iTransition])); }
      if (iExpiration > 0) { a.push(this.getText("ruleExpiration", [iExpiration])); }
      if (iNoncurrent > 0) { a.push(this.getText("ruleNoncurrent", [iNoncurrent])); }
      return a.join(" · ");
    }
  });
});
