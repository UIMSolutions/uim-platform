/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.business_user;


// 
// 
// import uim.platform.abap_environment.application.usecases.manage.business_users;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.business_user;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
class BusinessUserController : PlatformController {
  private ManageBusinessUsersUseCase usecase;

  this(ManageBusinessUsersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/business-users", &handleCreate);
    router.get("/api/v1/business-users", &handleList);
    router.get("/api/v1/business-users/*", &handleGet);
    router.put("/api/v1/business-users/*", &handleUpdate);
    router.delete_("/api/v1/business-users/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto j = req.json;
      CreateBusinessUserRequest r;
      r.tenantId = tenantId;
      r.systemInstanceId = SystemInstanceId(j.getString("systemInstanceId"));
      r.username = j.getString("username");
      r.firstName = j.getString("firstName");
      r.lastName = j.getString("lastName");
      r.email = j.getString("email");
      r.roleIds = getStrings(j, "roleIds");

      auto result = usecase.createBusinessUser(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
        .set("id", result.id)
        .set("message", "Business user created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));
      
      auto users = usecase.listBusinessUsers(tenantId, systemId);
      auto arr = users.map!(user => user.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", users.length)
        .set("message", "Business users fetched");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = BusinessUserId(extractIdFromPath(req.requestURI));

      auto user = usecase.getBusinessUser(tenantId, id);
      if (user.isNull) {
        writeError(res, 404, "Business user not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("item", user.toJson)
        .set("message", "Business user retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = BusinessUserId(extractIdFromPath(req.requestURI));

      auto j = req.json;
      UpdateBusinessUserRequest r;
      r.tenantId = tenantId;
      r.businessUserId = id;
      r.firstName = j.getString("firstName");
      r.lastName = j.getString("lastName");
      r.email = j.getString("email");
      r.status = j.getString("status");
      r.roleIds = getStrings(j, "roleIds");

      auto result = usecase.updateBusinessUser(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "updated")
          .set("message", "Business user updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = BusinessUserId(extractIdFromPath(req.requestURI));

      auto result = usecase.deleteBusinessUser(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "deleted")
          .set("message", "Business user deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
