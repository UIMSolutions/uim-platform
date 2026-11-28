sap.ui.define([
  "sap/ui/model/json/JSONModel"
], function (JSONModel) {
  "use strict";

  /**
   * Session of the built-in JWT login.
   *   mode "jwt"    the backend requires a bearer token: login dialog, token in sessionStorage
   *   mode "xsuaa"  the approuter logs in and forwards its token (nothing to do here)
   *   mode "open"   no authentication (local development)
   * The token is kept per browser tab (sessionStorage) until it expires.
   */
  var KEY = "uim.ailaunchpad.session";
  var ALL_SCOPES = ["Read", "Operate", "Develop", "Manage", "Admin"];

  function readStored() {
    try {
      var s = JSON.parse(window.sessionStorage.getItem(KEY) || "null");
      return s && s.token && s.expiresAt > Date.now() / 1000 + 30 ? s : null;
    } catch (e) {
      return null;
    }
  }

  function store(value) {
    try {
      if (value) {
        window.sessionStorage.setItem(KEY, JSON.stringify(value));
      } else {
        window.sessionStorage.removeItem(KEY);
      }
    } catch (e) { /* private mode: keep the token in memory only */ }
  }

  function request(method, url, body, token) {
    var headers = { "Accept": "application/json" };
    if (body) {
      headers["Content-Type"] = "application/json";
    }
    if (token) {
      headers.Authorization = "Bearer " + token;
    }
    return fetch(url, { method: method, headers: headers, body: body ? JSON.stringify(body) : undefined, credentials: "same-origin" })
      .then(function (response) {
        if (response.status === 204) {
          return {};
        }
        return response.json().catch(function () { return {}; }).then(function (json) {
          if (!response.ok) {
            var error = new Error((json.error && json.error.message) || response.statusText);
            error.status = response.status;
            throw error;
          }
          return json;
        });
      });
  }

  /** "Ada Lovelace" → "AL", "admin" → "AD" */
  function initials(name) {
    var parts = String(name || "").trim().split(/[\s._-]+/).filter(Boolean);
    if (parts.length === 0) {
      return "?";
    }
    if (parts.length === 1) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  return {
    /** Base path of the /auth endpoints (same origin as the OData service). */
    authRoot: "/auth",

    initials: initials,

    createSessionModel: function () {
      return new JSONModel({
        mode: "open", loginRequired: false, authenticated: false, user: "", displayName: "", initials: "?", email: "",
        tenant: "", roles: [], scopes: ALL_SCOPES.slice(), isAdmin: true, canManage: true, canDevelop: true,
        canOperate: true, token: "", expiresAt: 0
      });
    },

    /** Ask the backend which authentication applies (open if it cannot be reached, e.g. mock server). */
    loadConfig: function () {
      return request("GET", this.authRoot + "/config").catch(function () {
        return { mode: "open", loginRequired: false };
      });
    },

    /** The stored, still valid session or null. */
    stored: readStored,

    login: function (username, password, tenant) {
      var body = { username: username, password: password };
      if (tenant) {
        body.tenant = tenant;
      }
      return request("POST", this.authRoot + "/login", body).then(function (r) {
        var session = {
          token: r.access_token,
          expiresAt: Math.floor(Date.now() / 1000) + (r.expires_in || 3600),
          user: r.user
        };
        store(session);
        return session;
      });
    },

    changePassword: function (token, currentPassword, newPassword) {
      return request("POST", this.authRoot + "/password", { currentPassword: currentPassword, newPassword: newPassword }, token);
    },

    logout: function (token) {
      store(null);
      return request("POST", this.authRoot + "/logout", null, token).catch(function () { return {}; });
    },

    /** Call onExpired shortly before the token ends (never later than 24 days: setTimeout limit). */
    scheduleExpiry: function (session, onExpired) {
      var ms = Math.min((session.expiresAt - Date.now() / 1000 - 10) * 1000, 2000000000);
      if (ms > 0) {
        window.setTimeout(onExpired, ms);
      }
    },

    /**
     * PATCH an entity directly (the OData V4 model cannot set collection
     * valued properties). Fetches a CSRF token first (required behind the
     * approuter, harmless otherwise).
     */
    patch: function (serviceUrl, path, payload, token) {
      var headers = { "Accept": "application/json", "Content-Type": "application/json", "X-CSRF-Token": "Fetch" };
      if (token) {
        headers.Authorization = "Bearer " + token;
      }
      return fetch(serviceUrl, { method: "HEAD", headers: headers, credentials: "same-origin" }).then(function (head) {
        headers["X-CSRF-Token"] = head.headers.get("X-CSRF-Token") || "unsafe";
        return fetch(serviceUrl.replace(/\/$/, "") + path, {
          method: "PATCH", headers: headers, body: JSON.stringify(payload), credentials: "same-origin"
        });
      }).then(function (response) {
        if (response.ok) {
          return response.status === 204 ? {} : response.json();
        }
        return response.json().catch(function () { return {}; }).then(function (json) {
          var error = new Error((json.error && json.error.message) || response.statusText);
          error.status = response.status;
          throw error;
        });
      });
    },

    /** Fill the session model from the auth config and a session (scopes drive what the UI offers). */
    apply: function (model, config, session) {
      var user = (session && session.user) || {};
      var scopes = user.scopes || (config.loginRequired ? [] : ALL_SCOPES.slice());
      var has = function (s) { return scopes.indexOf(s) >= 0; };
      var name = user.displayName || user.id || "";
      model.setData({
        mode: config.mode,
        loginRequired: !!config.loginRequired,
        authenticated: !!session,
        user: user.id || "",
        displayName: name,
        initials: initials(name || (config.loginRequired ? "" : "Dev")),
        email: user.email || "",
        tenant: user.tenant || config.defaultTenant || "",
        roles: user.roles || [],
        scopes: scopes,
        isAdmin: has("Admin"),
        canManage: has("Manage"),
        canDevelop: has("Develop") || has("Manage"),
        canOperate: has("Operate") || has("Develop") || has("Manage"),
        token: (session && session.token) || "",
        expiresAt: (session && session.expiresAt) || 0
      });
    }
  };
});
