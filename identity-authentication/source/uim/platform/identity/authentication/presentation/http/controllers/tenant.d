/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.controllers.tenant;

// import uim.platform.identity.authentication.application.usecases.manage.tenants;
// import uim.platform.identity.authentication.application.dto;
// import uim.platform.identity.authentication.domain.entities.tenant;
// import uim.platform.identity.authentication.domain.types;

import uim.platform.identity.authentication;

// mixin(ShowModule!());
@safe:
/// HTTP controller for tenant management.
class TenantController : ManageHttpController {
  private ManageTenantsUseCase useCase;

  this(ManageTenantsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/tenants", &handleCreate);
    router.get("/api/v1/tenants", &handleList);
    router.get("/api/v1/tenants/*", &handleGet);
    router.put("/api/v1/tenants/*", &handleUpdate);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto createReq = CreateTenantRequest(data.getString("name"),
        data.getString("subdomain"), SsoProtocol.oidc, [AuthMethod.form], false);

      auto result = useCase.createTenant(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["tenantId"] = Json(result.tenantId);
        res.writeJsonBody(response, 201);
      } else {
        response["error"] = Json(result.message);
        res.writeJsonBody(response, 409);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto tenants = useCase.listTenants();
      auto response = Json.emptyObject;
      response["totalResults"] = Json(tenants.length);
      response["resources"] = toJsonArray(tenants);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      // import std.string : lastIndexOf;

      auto path = req.requestURI;
      auto idx = path.lastIndexOf('/');
      TenantId tenantId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto tenant = useCase.getTenant(tenantId);
      if (tenant == Tenant.init) {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("Tenant not found");
        res.writeJsonBody(errRes, 404);
        return;
      }

      res.writeJsonBody(toJsonValue(tenant), 200);
    } catch (Exception e) {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      // import std.string : lastIndexOf;

      auto path = req.requestURI;
      auto idx = path.lastIndexOf('/');
      TenantId tenantId = idx >= 0 ? path[idx + 1 .. $] : "";

      auto data = precheck.data;
      auto updateReq = UpdateTenantRequest(tenantId, data.getString("name"), []);

      auto error = useCase.updateTenant(updateReq);
      if (error.length > 0) {
        auto errRes = Json.emptyObject
          .set("error", error);

        res.writeJsonBody(errRes, 404);
      } else {
        auto resp = Json.emptyObject
          .set("status", "updated");

        res.writeJsonBody(resp, 200);
      }
    } catch (Exception e) {
      auto errRes = Json.emptyObject
        .set("error", "Internal server error");

      res.writeJsonBody(errRes, 500);
    }
  }
}
