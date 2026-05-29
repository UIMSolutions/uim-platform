/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.presentation.http.proxy_system;




// import uim.platform.identity.provisioning.application.usecases.manage.proxy_systems;
// import uim.platform.identity.provisioning.application.dto;
// import uim.platform.identity.provisioning.domain.entities.proxy_system;
// import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning;

mixin(ShowModule!());

@safe:
class ProxySystemController : ManageController {
  private ManageProxySystemsUseCase usecase;

  this(ManageProxySystemsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/proxy-systems", &handleCreate);
    router.get("/api/v1/proxy-systems", &handleList);
    router.get("/api/v1/proxy-systems/*", &handleGet);
    router.put("/api/v1/proxy-systems/*", &handleUpdate);
    router.delete_("/api/v1/proxy-systems/*", &handleDelete);
    router.post("/api/v1/proxy-systems/activate/*", &handleActivate);
    router.post("/api/v1/proxy-systems/deactivate/*", &handleDeactivate);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateProxySystemRequest();
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.systemType = parseSystemType(data.getString("systemType"));
      r.connectionConfig = data.getString("connectionConfig");
      r.sourceSystemId = data.getString("sourceSystemId");
      r.targetSystemId = data.getString("targetSystemId");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createProxySystem(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto items = usecase.listProxySystems(tenantId);

      auto arr = items.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto sys = usecase.getProxySystem(tenantId, id);
      if (sys.isNull) {
        writeError(res, 404, "Proxy system not found");
        return;
      }
      res.writeJsonBody(sys.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = UpdateProxySystemRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.connectionConfig = data.getString("connectionConfig");

      auto result = usecase.updateProxySystem(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.message == "Proxy system not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.activateSystem(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "active");

        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.message == "Proxy system not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.deactivateSystem(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "inactive");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.deleteProxySystem(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeSystem(const ProxySystem s) {
    return Json.emptyObject
      .set("id", s.id)
      .set("tenantId", s.tenantId)
      .set("name", s.name)
      .set("description", s.description)
      .set("systemType", s.systemType.to!string)
      .set("status", s.status.to!string)
      .set("connectionConfig", s.connectionConfig)
      .set("sourceSystemId", s.sourceSystemId)
      .set("targetSystemId", s.targetSystemId)
      .set("createdBy", s.createdBy)
      .set("createdAt", s.createdAt)
      .set("updatedAt", s.updatedAt);
  }
}
