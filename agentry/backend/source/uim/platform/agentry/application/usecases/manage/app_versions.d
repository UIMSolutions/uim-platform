/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.app_versions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageAppVersionsUseCase : IManageAppVersionsUseCase {
  protected IAppVersionRepository repo;
  protected IAppDefinitionRepository definitions;
  protected IAgentryEventPublisher events;

  /// definitions may be null (no referential / publishing checks).
  this(IAppVersionRepository repo, IAppDefinitionRepository definitions = null, IAgentryEventPublisher events = null) {
    this.repo = repo;
    this.definitions = definitions;
    this.events = events is null ? new NullEventPublisher : events;
  }

  AppVersion[] listAppVersions(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  AppVersion[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
    return repo.findByMobileApplication(tenantId, appId);
  }

  AppVersion[] listByStatus(TenantId tenantId, AppVersionStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  AppVersion getAppVersion(TenantId tenantId, AppVersionId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult createAppVersion(AppVersionDTO dto) {
    return guarded(() {
      if (!dto.versionId.isNull && repo.existsById(dto.tenantId, dto.versionId))
        return conflict("App version '" ~ dto.versionId.value ~ "' already exists");

      auto ver = newEntity!(AppVersion)(dto.tenantId, dto.versionId, dto.createdBy);
      ver.mobileApplicationId = dto.applicationId;
      ver.definitionId = dto.definitionId;
      ver.versionNumber = dto.versionNumber;
      ver.builtAt = nowStdTime();
      apply(ver, dto);

      auto errors = AgentryValidator.validate(ver);
      if (dto.status.length > 0 && dto.status != "pending")
        errors ~= "new versions start as pending — use publishAppVersion";
      if (errors.length)
        return invalid(errors);

      if (definitions !is null) {
        auto def = definitions.findById(dto.tenantId, ver.definitionId);
        if (def.isNull)
          return rejected("App definition '" ~ ver.definitionId.value ~ "' does not exist");
        if (def.applicationId != ver.mobileApplicationId)
          return rejected("App definition '" ~ def.id.value ~ "' belongs to another application");
      }
      if (repo.findByMobileApplication(dto.tenantId, ver.mobileApplicationId).any!(v => v.versionNumber == ver.versionNumber))
        return conflict("Version " ~ ver.versionNumber ~ " already exists for this application");

      repo.save(ver);
      return created(ver.id.value, "App version created");
    });
  }

  UsecaseResult updateAppVersion(AppVersionDTO dto) {
    return guarded(() {
      auto ver = repo.findById(dto.tenantId, dto.versionId);
      if (ver.isNull)
        return notFound("App version", dto.versionId.value);

      apply(ver, dto);
      string[] errors;
      AppVersionStatus status = ver.status;
      readEnum(dto.status, status, "status", errors);
      if (errors.length)
        return invalid(errors);
      if (status == AppVersionStatus.published && ver.status != AppVersionStatus.published)
        return publish(ver, dto.updatedBy);
      ensureTransition("AppVersion", ver.status, status);
      ver.status = status;

      touch(ver, dto.updatedBy);
      repo.update(ver);
      return succeeded(ver.id.value, "App version updated");
    });
  }

  UsecaseResult publishAppVersion(TenantId tenantId, AppVersionId id, UserId by) {
    return guarded(() {
      auto ver = repo.findById(tenantId, id);
      if (ver.isNull)
        return notFound("App version", id.value);
      return publish(ver, by);
    });
  }

  UsecaseResult withdrawAppVersion(TenantId tenantId, AppVersionId id, UserId by) {
    return guarded(() {
      auto ver = repo.findById(tenantId, id);
      if (ver.isNull)
        return notFound("App version", id.value);
      ensureTransition("AppVersion", ver.status, AppVersionStatus.withdrawn);
      ver.status = AppVersionStatus.withdrawn;
      touch(ver, by);
      repo.update(ver);
      events.publish(AgentryTopics.versionWithdrawn, Json.emptyObject
          .set("tenantId", tenantId.value).set("id", id.value).set("versionNumber", ver.versionNumber));
      return succeeded(ver.id.value, "App version withdrawn");
    });
  }

  UsecaseResult deleteAppVersion(TenantId tenantId, AppVersionId id) {
    auto ver = repo.findById(tenantId, id);
    if (ver.isNull)
      return notFound("App version", id.value);
    if (ver.status == AppVersionStatus.published)
      return rejected("Published versions cannot be deleted — withdraw it first", id.value);
    repo.remove(ver);
    return succeeded(ver.id.value, "App version deleted");
  }

  protected UsecaseResult publish(ref AppVersion ver, UserId by) {
    ensureTransition("AppVersion", ver.status, AppVersionStatus.published);
    if (definitions !is null) {
      auto def = definitions.findById(ver.tenantId, ver.definitionId);
      if (def.isNull || def.status != DefinitionStatus.published)
        throw new BusinessRuleException("App definition '" ~ ver.definitionId.value ~ "' must be published first");
    }
    if (ver.artifactUrl.length == 0)
      throw new BusinessRuleException("An artifactUrl is required to publish a version");
    ver.status = AppVersionStatus.published;
    ver.publishedAt = nowStdTime();
    touch(ver, by);
    repo.update(ver);
    events.publish(AgentryTopics.versionPublished, Json.emptyObject
        .set("tenantId", ver.tenantId.value).set("id", ver.id.value)
        .set("applicationId", ver.mobileApplicationId.value).set("versionNumber", ver.versionNumber)
        .set("mandatory", ver.isMandatoryUpdate));
    return succeeded(ver.id.value, "App version " ~ ver.versionNumber ~ " published");
  }

  protected void apply(ref AppVersion ver, const AppVersionDTO dto) {
    assignIf(ver.releaseNotes, dto.releaseNotes);
    assignIf(ver.artifactUrl, dto.artifactUrl);
    assignIf(ver.checksum, dto.checksum);
    assignIf(ver.minOsVersion, dto.minOsVersion);
    assignIf(ver.changeLog, dto.changeLog);
    ver.isMandatoryUpdate = dto.isMandatoryUpdate;
  }
}

///
unittest {
  mixin(ShowTest!("ManageAppVersionsUseCase"));

  auto t = TenantId("t1");
  auto app = MobileApplicationId("app-1");
  auto definitions = new AppDefinitionRepository();
  auto def = AppDefinition(t, AppDefinitionId("def-1"));
  def.applicationId = app;
  definitions.save(def);

  auto uc = new ManageAppVersionsUseCase(new AppVersionRepository(), definitions);
  AppVersionDTO dto;
  dto.tenantId = t;
  dto.applicationId = app;
  dto.definitionId = def.id;
  dto.versionNumber = "1.0.0";
  dto.artifactUrl = "https://cdn.example.com/app-1.0.0.ipa";
  auto r = uc.createAppVersion(dto);
  assert(r.isSuccess, r.message);
  auto id = AppVersionId(r.id);
  assert(uc.createAppVersion(dto).code == 409);

  assert(uc.publishAppVersion(t, id, UserId("u")).code == 422); // definition is a draft
  def.status = DefinitionStatus.published;
  definitions.update(def);
  assert(uc.publishAppVersion(t, id, UserId("u")).isSuccess);
  assert(uc.deleteAppVersion(t, id).code == 422);
  assert(uc.withdrawAppVersion(t, id, UserId("u")).isSuccess);
  assert(uc.publishAppVersion(t, id, UserId("u")).code == 422); // withdrawn is terminal
}
