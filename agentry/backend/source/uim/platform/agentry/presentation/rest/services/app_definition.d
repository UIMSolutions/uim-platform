/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.rest.services.app_definition;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Implementation of IAppDefinitionApi on top of the driving port.
class AppDefinitionService : IAppDefinitionApi {
  private IManageAppDefinitionsUseCase usecase;

  this(IManageAppDefinitionsUseCase usecase) {
    this.usecase = usecase;
  }

  Json[] getAppDefinitions(RequestIdentity identity) {
    return usecase.listDefinitions(identity.tenantId).map!(d => d.toJson).array;
  }

  Json getAppDefinition(string _id, RequestIdentity identity) {
    return require(identity.tenantId, _id).toJson;
  }

  Json createAppDefinition(Json request, RequestIdentity identity) {
    AppDefinitionDTO dto;
    read(dto, request);
    dto.tenantId = identity.tenantId;
    dto.createdBy = identity.userId;
    return respond(usecase.createDefinition(dto));
  }

  Json updateAppDefinition(string _id, Json request, RequestIdentity identity) {
    auto dto = AppDefinitionDTO.fromEntity(require(identity.tenantId, _id));
    read(dto, request);
    dto.definitionId = AppDefinitionId(_id);
    dto.tenantId = identity.tenantId;
    dto.updatedBy = identity.userId;
    return respond(usecase.updateDefinition(dto));
  }

  Json publishAppDefinition(string _id, RequestIdentity identity) {
    return respond(usecase.publishDefinition(identity.tenantId, AppDefinitionId(_id), identity.userId));
  }

  void deleteAppDefinition(string _id, RequestIdentity identity) {
    respond(usecase.deleteDefinition(identity.tenantId, AppDefinitionId(_id)));
  }

  private AppDefinition require(TenantId tenantId, string id) {
    auto def = usecase.getDefinition(tenantId, AppDefinitionId(id));
    if (def.isNull)
      throw new HTTPStatusException(HTTPStatus.notFound, "App definition '" ~ id ~ "' not found");
    return def;
  }

  private static void read(ref AppDefinitionDTO dto, Json request) {
    try
      readPayload(dto, request);
    catch (PayloadException e)
      throw new HTTPStatusException(HTTPStatus.badRequest, e.msg);
  }

  private static Json respond(UsecaseResult result) {
    if (!result.isSuccess)
      throw new HTTPStatusException(cast(HTTPStatus) httpStatusOf(result), result.message);
    return Json.emptyObject.set("id", result.id).set("message", result.message);
  }
}
