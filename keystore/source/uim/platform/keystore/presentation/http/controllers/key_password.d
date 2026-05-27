/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.presentation.http.controllers.key_password;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:

class KeyPasswordController : ManageController {
  private ManageKeyPasswordsUseCase usecase;

  this(ManageKeyPasswordsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    // Password Storage API: set, get, delete, list
    router.put("/api/v1/passwords/*",      &handleSetPassword);
    router.get("/api/v1/passwords/*",      &handleGetPassword);
    router.delete_("/api/v1/passwords/*",  &handleDeletePassword);
    router.get("/api/v1/passwords",        &handleListPasswords);
  }

  // PUT /api/v1/passwords/{alias}  (set or overwrite a password)
  protected void handleSetPassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto alias_ = extractIdFromPath(req.requestURI.to!string);
      auto j      = req.json;
      SetPasswordRequest r;
      r.accountId     = data.getString("accountId");
      r.applicationId = data.getString("applicationId");
      r.tenantId      = data.getString("tenantId");
      r.alias_        = alias_;
      r.passwordValue = data.getString("passwordValue");

      auto result = usecase.setPassword(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/passwords/{alias}?accountId=...&applicationId=...
  protected void handleGetPassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId      = req.getTenantId;
      auto alias_       = extractIdFromPath(req.requestURI.to!string);
      auto accountId    = req.params.get("accountId", "");
      auto applicationId = req.params.get("applicationId", "");

      auto kp = usecase.getPassword(tenantId, accountId, applicationId, alias_);
      if (kp.isNull) {
        writeError(res, 404, "Password not found");
        return;
      }

      // Return alias and metadata only — never expose the stored value in clear text
      auto j = Json.emptyObject
        .set("id",            kp.id)
        .set("alias",         kp.alias_)
        .set("accountId",     kp.accountId)
        .set("applicationId", kp.applicationId)
        .set("createdAt",     kp.createdAt)
        .set("updatedAt",     kp.updatedAt);
      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // DELETE /api/v1/passwords/{alias}?accountId=...&applicationId=...
  protected void handleDeletePassword(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId      = req.getTenantId;
      auto alias_        = extractIdFromPath(req.requestURI.to!string);
      auto accountId     = req.params.get("accountId", "");
      auto applicationId = req.params.get("applicationId", "");

      auto result = usecase.deletePassword(tenantId, accountId, applicationId, alias_);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/passwords?accountId=...&applicationId=...
  protected void handleListPasswords(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId      = req.getTenantId;
      auto accountId     = req.params.get("accountId", "");
      auto applicationId = req.params.get("applicationId", "");
      auto passwords     = usecase.listByApplication(tenantId, accountId, applicationId);

      auto jarr = Json.emptyArray;
      foreach (kp; passwords) {
        jarr ~= Json.emptyObject
          .set("id",            kp.id)
          .set("alias",         kp.alias_)
          .set("accountId",     kp.accountId)
          .set("applicationId", kp.applicationId)
          .set("createdAt",     kp.createdAt)
          .set("updatedAt",     kp.updatedAt);
      }

      auto resp = Json.emptyObject
          .set("items", jarr)
          .set("totalCount", passwords.length);
          
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
