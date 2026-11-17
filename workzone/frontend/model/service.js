sap.ui.define([], function () {
  "use strict";

  /**
   * Minimal OData v4 write client (POST / PATCH / DELETE / unbound actions) with
   * CSRF token handling for the approuter. Reads go through the ODataModel.
   * Errors reject with { status, message } taken from the OData error payload.
   */
  function Service(sServiceUrl) {
    this._sUrl = sServiceUrl.replace(/\/?$/, "/");
    this._sToken = null;
  }

  Service.prototype._token = function () {
    if (this._sToken) {
      return Promise.resolve(this._sToken);
    }
    return fetch(this._sUrl, { method: "GET", credentials: "same-origin", headers: { "X-CSRF-Token": "Fetch" } })
      .then(function (oResponse) {
        this._sToken = oResponse.headers.get("X-CSRF-Token") || "unsafe";
        return this._sToken;
      }.bind(this))
      .catch(function () {
        return "unsafe";
      });
  };

  Service.prototype._send = function (sMethod, sPath, oBody, bRetried) {
    return this._token().then(function (sToken) {
      return fetch(this._sUrl + sPath, {
        method: sMethod,
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": sToken
        },
        body: oBody === undefined ? undefined : JSON.stringify(oBody)
      });
    }.bind(this)).then(function (oResponse) {
      if (oResponse.status === 403 && oResponse.headers.get("X-CSRF-Token") === "Required" && !bRetried) {
        this._sToken = null;
        return this._send(sMethod, sPath, oBody, true);
      }
      if (oResponse.status === 204) {
        return null;
      }
      return oResponse.json().catch(function () {
        return {};
      }).then(function (oPayload) {
        if (!oResponse.ok) {
          throw {
            status: oResponse.status,
            message: (oPayload && oPayload.error && oPayload.error.message) || oResponse.statusText
          };
        }
        return oPayload;
      });
    }.bind(this));
  };

  Service.keyPath = function (sSet, sId) {
    return sSet + "('" + encodeURIComponent(String(sId).replace(/'/g, "''")) + "')";
  };

  Service.prototype.create = function (sSet, oData) {
    return this._send("POST", sSet, oData);
  };

  Service.prototype.update = function (sSet, sId, oPatch) {
    return this._send("PATCH", Service.keyPath(sSet, sId), oPatch);
  };

  Service.prototype.remove = function (sSet, sId) {
    return this._send("DELETE", Service.keyPath(sSet, sId));
  };

  /** Unbound action, e.g. invoke("PublishContentItem", { id: "..." }). */
  Service.prototype.invoke = function (sAction, oParameters) {
    return this._send("POST", sAction, oParameters || {});
  };

  return Service;
});
