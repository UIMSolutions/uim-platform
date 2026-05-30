/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.function_;



// import uim.platform.kyma.application.usecases.manage.functions;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.serverless_function;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class FunctionController : ManageController {
  private ManageFunctionsUseCase usecase;

  this(ManageFunctionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/functions", &handleCreate);
    router.get("/api/v1/functions", &handleList);
    router.get("/api/v1/functions/*", &handleGet);
    router.put("/api/v1/functions/*", &handleUpdate);
    router.delete_("/api/v1/functions/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateFunctionRequest r;
      r.namespaceId = data.getString("namespaceId");
      r.environmentId = data.getString("environmentId");
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.runtime = data.getString("runtime");
      r.sourceCode = data.getString("sourceCode");
      r.handler = data.getString("handler");
      r.dependencies = data.getString("dependencies");
      r.scalingType = data.getString("scalingType");
      r.minReplicas = data.getInteger("minReplicas");
      r.maxReplicas = data.getInteger("maxReplicas");
      r.cpuRequest = data.getString("cpuRequest");
      r.cpuLimit = data.getString("cpuLimit");
      r.memoryRequest = data.getString("memoryRequest");
      r.memoryLimit = data.getString("memoryLimit");
      r.envVars = data.jsonStrMap("envVars");
      r.labels = data.jsonStrMap("labels");
      r.timeoutSeconds = data.getInteger("timeoutSeconds");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
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
      auto nsId = req.params.get("namespaceId");
      auto envId = req.params.get("environmentId");

      ServerlessFunction[] items;
      if (!nsId.isEmpty)
        items = usecase.listByNamespace(NamespaceId(nsId));
      else if (!envId.isEmpty)
        items = usecase.listByEnvironment(KymaEnvironmentId(envId));

      auto arr = items.map!(fn => fn.toJson).array.toJson;

      auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("", 0, responseData);
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      if (!usecase.hasFunction(ServerlessFunctionId(tenantId, id))) {
        writeError(res, 404, "Function not found");
        return;
      }
      auto fn = usecase.getFunction(ServerlessFunctionId(tenantId, id));
      res.writeJsonBody(fn.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      UpdateFunctionRequest r;
      r.description = data.getString("description");
      r.sourceCode = data.getString("sourceCode");
      r.handler = data.getString("handler");
      r.dependencies = data.getString("dependencies");
      r.scalingType = data.getString("scalingType");
      r.minReplicas = data.getInteger("minReplicas");
      r.maxReplicas = data.getInteger("maxReplicas");
      r.cpuRequest = data.getString("cpuRequest");
      r.cpuLimit = data.getString("cpuLimit");
      r.memoryRequest = data.getString("memoryRequest");
      r.memoryLimit = data.getString("memoryLimit");
      r.envVars = data.jsonStrMap("envVars");
      r.labels = data.jsonStrMap("labels");
      r.timeoutSeconds = data.getInteger("timeoutSeconds");

      auto result = usecase.updateFunction(ServerlessFunctionId(tenantId, id), r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.deleteFunction(ServerlessFunctionId(tenantId, id));
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
