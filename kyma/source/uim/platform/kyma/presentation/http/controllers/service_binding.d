/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.service_binding;


// import vibe.http.router;
// import vibe.data.json;


// import uim.platform.kyma.application.usecases.manage.service_bindings;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.service_binding;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ServiceBindingController : PlatformController {
  private ManageServiceBindingsUseCase usecase;

  this(ManageServiceBindingsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/service-bindings", &handleCreate);
    router.get("/api/v1/service-bindings", &handleList);
    router.get("/api/v1/service-bindings/*", &handleGet);
    router.put("/api/v1/service-bindings/*", &handleUpdate);
    router.delete_("/api/v1/service-bindings/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateServiceBindingRequest r;
      r.tenantId = tenantId;
      r.serviceInstanceId = j.getString("serviceInstanceId");
      r.namespaceId = j.getString("namespaceId");
      r.environmentId = j.getString("environmentId");
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.secretName = j.getString("secretName");
      r.secretNamespace = j.getString("secretNamespace");
      r.parametersJson = j.getString("parameters");
      r.labels = jsonStrMap(j, "labels");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto nsId = NamespaceId(req.params.get("namespaceId"));
      auto instId = ServiceInstanceId(req.params.get("serviceInstanceId"));

      ServiceBinding[] items;
      if (!instId.isEmpty)
        items = usecase.listServiceBindings(tenantId, instId);
      else if (!nsId.isEmpty)
        items = usecase.listServiceBindings(tenantId, nsId);

      auto arr = items.map!(b => b.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length);
          
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto b = usecase.getBinding(ServiceBindingId(tenantId, id));
      if (b.isNull) {
        writeError(res, 404, "Service binding not found");
        return;
      }
      res.writeJsonBody(b.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ServiceBindingId(tenantId, extractIdFromPath(req.requestURI));
      auto j = req.json;
      UpdateServiceBindingRequest r;
      r.tenantId = tenantId;  
      r.serviceBindingId = id;
      r.description = j.getString("description");
      r.secretName = j.getString("secretName");
      r.parametersJson = j.getString("parameters");
      r.labels = jsonStrMap(j, "labels");

      auto result = usecase.updateBinding(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ServiceBindingId(tenantId, extractIdFromPath(req.requestURI));

      auto result = usecase.deleteBinding(tenantId, id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
