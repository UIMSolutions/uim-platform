/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.anonymization_config;
// import uim.platform.data.privacy.application.usecases.manage.anonymization_configs;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.anonymization_config;
import uim.platform.data.privacy;
mixin(ShowModule!());

@safe:
class AnonymizationConfigController : ManageHttpController {
  private ManageAnonymizationConfigsUseCase usecase;

  this(ManageAnonymizationConfigsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/anonymization-configs", &handleCreate);
    router.get("/api/v1/anonymization-configs", &handleList);
    router.get("/api/v1/anonymization-configs/*", &handleGet);
    router.put("/api/v1/anonymization-configs/*", &handleUpdate);
    router.post("/api/v1/anonymization-configs/*/activate", &handleActivate);
    router.delete_("/api/v1/anonymization-configs/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateAnonymizationConfigRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.isReversible = data.getBoolean("isReversible", false);
    r.targetSystems = data.getStrings("targetSystems");

    auto result = usecase.createConfig(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Anonymization config created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listConfigs(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Anonymization config list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AnonymizationConfigId(precheck.id);

    auto entry = usecase.getConfig(tenantId, id);
    if (entry.isNull)
      return errorResponse("Anonymization config not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Anonymization config retrieved successfully", 200, responseData);

  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UpdateAnonymizationConfigRequest r;
    r.configId = AnonymizationConfigId(precheck.id);
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.isReversible = data.getBoolean("isReversible", false);
    r.targetSystems = data.getArray("targetSystems").map!(c => c.to!string).array;

    auto result = usecase.updateConfig(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Anonymization config updated successfully", 200, responseData);
  }

  protected Json activateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AnonymizationConfigId(precheck.id);

    auto result = usecase.activateConfig(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Anonymization config activated successfully", 200, responseData);
  }

  mixin(HandleTemplate!("handleActivate", "activateHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AnonymizationConfigId(precheck.id);

    auto result = usecase.deleteConfig(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Anonymization config deleted successfully", 200, responseData);
  }
}
