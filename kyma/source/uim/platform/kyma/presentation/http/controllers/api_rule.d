/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.api_rule;

// import uim.platform.kyma.application.usecases.manage.api_rules;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.api_rule;
// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.presentation.http
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ApiRuleController : ManageController {
  private ManageApiRulesUseCase usecase;

  this(ManageApiRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/api-rules", &handleCreate);
    router.get("/api/v1/api-rules", &handleList);
    router.get("/api/v1/api-rules/*", &handleGet);
    router.put("/api/v1/api-rules/*", &handleUpdate);
    router.delete_("/api/v1/api-rules/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    
    CreateApiRuleRequest r;
    r.namespaceId = data.getString("namespaceId");
    r.environmentId = data.getString("environmentId");
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.serviceName = data.getString("serviceName");
    r.servicePort = data.getInteger("servicePort");
    r.gateway = data.getString("gateway");
    r.host = data.getString("host");
    r.tlsEnabled = data.getBoolean("tlsEnabled", true);
    r.tlsSecretName = data.getString("tlsSecretName");
    r.corsEnabled = data.getBoolean("corsEnabled");
    r.corsAllowOrigins = data.getStrings("corsAllowOrigins");
    r.corsAllowMethods = data.getStrings("corsAllowMethods");
    r.corsAllowHeaders = data.getStrings("corsAllowHeaders");
    r.labels = data.jsonStrMap("labels");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    // Parse rules array
    r.rules = j.toRuleEntries;

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    res.writeJsonBody(resp, 201);
  } else
    writeError(res, 400, result.message);
}
 catch (Exception e) {
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

    ApiRule[] items;
    if (!nsId.isEmpty)
      items = usecase.listByNamespace(nsId);
    else if (!envId.isEmpty)
      items = usecase.listByEnvironment(envId);

    auto arr = items.map!(rule => rule.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length)
      .set("message", "API rules retrieved successfully");

    res.writeJsonBody(resp, 200);
  } catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = precheck.id;
  auto rule = usecase.getApiRule(tenantId, id);
  if (rule.isNull) {
    writeError(res, 404, "API rule not found");
    return;
  }
  res.writeJsonBody(rule.toJson, 200);
}
 catch (Exception e) {
  writeError(res, 500, "Internal server error");
}
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = precheck.id;
  auto data = precheck.data;
  UpdateApiRuleRequest r;
  r.description = data.getString("description");
  r.serviceName = data.getString("serviceName");
  r.servicePort = data.getInteger("servicePort");
  r.host = data.getString("host");
  r.tlsEnabled = data.getBoolean("tlsEnabled", true);
  r.tlsSecretName = data.getString("tlsSecretName");
  r.corsEnabled = data.getBoolean("corsEnabled");
  r.corsAllowOrigins = data.getStrings("corsAllowOrigins");
  r.corsAllowMethods = data.getStrings("corsAllowMethods");
  r.corsAllowHeaders = data.getStrings("corsAllowHeaders");
  r.labels = data.jsonStrMap("labels");
  r.rules = j.toRuleEntries;

  auto result = usecase.updateApiRule(tenantId, id, r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("API rule updated successfully", "Updated", 200, responseData);
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = precheck.id;
  auto result = usecase.deleteApiRule(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("API rule deleted successfully", "Deleted", 200, responseData);
}
}
