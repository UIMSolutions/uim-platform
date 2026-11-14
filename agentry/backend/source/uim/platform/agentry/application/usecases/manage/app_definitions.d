/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.app_definitions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageAppDefinitionsUseCase : IManageAppDefinitionsUseCase {
  protected IAppDefinitionRepository repo;
  protected IMobileApplicationRepository applications;
  protected IAgentryEventPublisher events;

  /// applications may be null (no referential check).
  this(IAppDefinitionRepository repo, IMobileApplicationRepository applications = null,
      IAgentryEventPublisher events = null) {
    this.repo = repo;
    this.applications = applications;
    this.events = events is null ? new NullEventPublisher : events;
  }

  AppDefinition[] listDefinitions(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  AppDefinition[] listDefinitions(TenantId tenantId, MobileApplicationId appId) {
    return repo.findByMobileApplication(tenantId, appId);
  }

  AppDefinition[] listByStatus(TenantId tenantId, DefinitionStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  AppDefinition getDefinition(TenantId tenantId, AppDefinitionId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult createDefinition(AppDefinitionDTO dto) {
    return guarded(() {
      if (!dto.definitionId.isNull && repo.existsById(dto.tenantId, dto.definitionId))
        return conflict("App definition '" ~ dto.definitionId.value ~ "' already exists");

      auto def = newEntity!(AppDefinition)(dto.tenantId, dto.definitionId, dto.createdBy);
      def.applicationId = dto.applicationId;
      def.definitionFormat = "json";
      def.authoredBy = dto.authoredBy.isNull ? dto.createdBy : dto.authoredBy;
      apply(def, dto);

      auto errors = AgentryValidator.validate(def);
      if (dto.status.length > 0 && dto.status != "draft")
        errors ~= "new definitions start as draft — use publishDefinition";
      if (errors.length)
        return invalid(errors);
      if (applications !is null && !applications.existsById(dto.tenantId, def.applicationId))
        return rejected("Mobile application '" ~ def.applicationId.value ~ "' does not exist");

      recordValidation(def);
      repo.save(def);
      return created(def.id.value, "App definition created");
    });
  }

  UsecaseResult updateDefinition(AppDefinitionDTO dto) {
    return guarded(() {
      auto def = repo.findById(dto.tenantId, dto.definitionId);
      if (def.isNull)
        return notFound("App definition", dto.definitionId.value);

      bool contentChanged = (dto.definitionContent.length > 0 && dto.definitionContent != def.definitionContent)
        || (dto.definitionFormat.length > 0 && dto.definitionFormat != def.definitionFormat);
      if (contentChanged && def.status != DefinitionStatus.draft)
        return rejected("Only draft definitions can change their metadata — archive and reopen it first");

      apply(def, dto);
      string[] errors;
      DefinitionStatus status = def.status;
      readEnum(dto.status, status, "status", errors);
      errors ~= AgentryValidator.validate(def);
      if (errors.length)
        return invalid(errors);
      if (status == DefinitionStatus.published && def.status != DefinitionStatus.published)
        return publish(def, dto.updatedBy);
      ensureTransition("AppDefinition", def.status, status);
      def.status = status;

      recordValidation(def);
      touch(def, dto.updatedBy);
      repo.update(def);
      return succeeded(def.id.value, "App definition updated");
    });
  }

  UsecaseResult validateDefinition(TenantId tenantId, AppDefinitionId id) {
    auto def = repo.findById(tenantId, id);
    if (def.isNull)
      return notFound("App definition", id.value);
    auto errors = recordValidation(def);
    def.update();
    repo.update(def);
    auto list = Json.emptyArray;
    foreach (e; errors)
      list ~= Json(e);
    return succeeded(def.id.value, errors.length ? "Validation failed" : "Validation passed", 200,
      Json.emptyObject.set("validationPassed", errors.length == 0).set("errors", list));
  }

  UsecaseResult publishDefinition(TenantId tenantId, AppDefinitionId id, UserId by) {
    return guarded(() {
      auto def = repo.findById(tenantId, id);
      if (def.isNull)
        return notFound("App definition", id.value);
      return publish(def, by);
    });
  }

  UsecaseResult archiveDefinition(TenantId tenantId, AppDefinitionId id, UserId by) {
    return guarded(() {
      auto def = repo.findById(tenantId, id);
      if (def.isNull)
        return notFound("App definition", id.value);
      ensureTransition("AppDefinition", def.status, DefinitionStatus.archived);
      def.status = DefinitionStatus.archived;
      touch(def, by);
      repo.update(def);
      return succeeded(def.id.value, "App definition archived");
    });
  }

  UsecaseResult deleteDefinition(TenantId tenantId, AppDefinitionId id) {
    auto def = repo.findById(tenantId, id);
    if (def.isNull)
      return notFound("App definition", id.value);
    if (def.status == DefinitionStatus.published)
      return rejected("Published definitions cannot be deleted — archive it first", id.value);
    repo.remove(def);
    return succeeded(def.id.value, "App definition deleted");
  }

  protected UsecaseResult publish(ref AppDefinition def, UserId by) {
    ensureTransition("AppDefinition", def.status, DefinitionStatus.published);
    auto errors = recordValidation(def);
    if (errors.length) {
      repo.update(def);
      return rejected("Definition does not validate: " ~ errors.join("; "), def.id.value);
    }
    def.status = DefinitionStatus.published;
    def.publishedAt = nowStdTime();
    touch(def, by);
    repo.update(def);
    events.publish(AgentryTopics.definitionPublished, Json.emptyObject
        .set("tenantId", def.tenantId.value).set("id", def.id.value)
        .set("applicationId", def.applicationId.value).set("schemaVersion", def.schemaVersion));
    return succeeded(def.id.value, "App definition published");
  }

  protected string[] recordValidation(ref AppDefinition def) {
    auto errors = AgentryValidator.validateContent(def);
    def.validationPassed = errors.length == 0;
    def.validationErrors = errors.join("; ");
    return errors;
  }

  protected void apply(ref AppDefinition def, const AppDefinitionDTO dto) {
    if (!dto.applicationId.isNull)
      def.applicationId = dto.applicationId;
    assignIf(def.name, dto.name);
    assignIf(def.description, dto.description);
    assignIf(def.definitionContent, dto.definitionContent);
    assignIf(def.definitionFormat, dto.definitionFormat);
    assignIf(def.schemaVersion, dto.schemaVersion);
    assignIf(def.targetPlatform, dto.targetPlatform);
    assignIf(def.businessObjectModel, dto.businessObjectModel);
  }
}

///
unittest {
  mixin(ShowTest!("ManageAppDefinitionsUseCase"));

  auto uc = new ManageAppDefinitionsUseCase(new AppDefinitionRepository());
  auto t = TenantId("t1");

  AppDefinitionDTO dto;
  dto.tenantId = t;
  dto.applicationId = MobileApplicationId("app-1");
  dto.name = "Work Orders";
  dto.definitionFormat = "json";
  dto.definitionContent = "{broken";
  auto r = uc.createDefinition(dto);
  assert(r.isSuccess, r.message);
  auto id = AppDefinitionId(r.id);
  assert(!uc.getDefinition(t, id).validationPassed);

  assert(uc.publishDefinition(t, id, UserId("u")).code == 422); // does not validate

  dto.definitionId = id;
  dto.definitionContent = `{"screens": [{"name": "WorkOrderList"}]}`;
  assert(uc.updateDefinition(dto).isSuccess);
  assert(uc.publishDefinition(t, id, UserId("u")).isSuccess);
  assert(uc.getDefinition(t, id).status == DefinitionStatus.published);
  assert(uc.getDefinition(t, id).publishedAt > 0);

  assert(uc.updateDefinition(dto).isSuccess); // unchanged content is fine
  dto.definitionContent = `{"screens": []}`;
  assert(uc.updateDefinition(dto).code == 422); // published content is immutable
  assert(uc.deleteDefinition(t, id).code == 422);
  assert(uc.archiveDefinition(t, id, UserId("u")).isSuccess);
  assert(uc.deleteDefinition(t, id).isSuccess);
}
