/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.mobile_applications;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageMobileApplicationsUseCase : IManageMobileApplicationsUseCase {
  protected IMobileApplicationRepository repo;
  protected IAgentryEventPublisher events;

  this(IMobileApplicationRepository repo, IAgentryEventPublisher events = null) {
    this.repo = repo;
    this.events = events is null ? new NullEventPublisher : events;
  }

  MobileApplication[] listMobileApplications(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  MobileApplication[] listByStatus(TenantId tenantId, AppStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  MobileApplication[] listByPlatform(TenantId tenantId, AppPlatform platform) {
    return repo.findByPlatform(tenantId, platform);
  }

  MobileApplication getMobileApplication(TenantId tenantId, MobileApplicationId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult createMobileApplication(MobileApplicationDTO dto) {
    return guarded(() {
      if (!dto.applicationId.isNull && repo.existsById(dto.tenantId, dto.applicationId))
        return conflict("Mobile application '" ~ dto.applicationId.value ~ "' already exists");

      auto app = newEntity!(MobileApplication)(dto.tenantId, dto.applicationId, dto.createdBy);
      string[] errors;
      apply(app, dto, errors);
      AppStatus status = AppStatus.draft;
      if (readEnum(dto.status, status, "status", errors))
        ensureTransition("MobileApplication", AppStatus.draft, status);
      app.status = status;
      errors ~= AgentryValidator.validate(app);
      if (errors.length)
        return invalid(errors);

      if (repo.findByTenant(dto.tenantId).any!(a => a.packageName == app.packageName))
        return conflict("Package name '" ~ app.packageName ~ "' is already registered");

      repo.save(app);
      return created(app.id.value, "Mobile application created");
    });
  }

  UsecaseResult updateMobileApplication(MobileApplicationDTO dto) {
    return guarded(() {
      auto app = repo.findById(dto.tenantId, dto.applicationId);
      if (app.isNull)
        return notFound("Mobile application", dto.applicationId.value);

      string[] errors;
      apply(app, dto, errors);
      AppStatus status = app.status;
      if (readEnum(dto.status, status, "status", errors))
        ensureTransition("MobileApplication", app.status, status);
      app.status = status;
      errors ~= AgentryValidator.validate(app);
      if (errors.length)
        return invalid(errors);

      touch(app, dto.updatedBy);
      repo.update(app);
      return succeeded(app.id.value, "Mobile application updated");
    });
  }

  UsecaseResult setMobileApplicationStatus(TenantId tenantId, MobileApplicationId id, AppStatus status, UserId by) {
    return guarded(() {
      auto app = repo.findById(tenantId, id);
      if (app.isNull)
        return notFound("Mobile application", id.value);
      ensureTransition("MobileApplication", app.status, status);
      auto previous = app.status;
      app.status = status;
      touch(app, by);
      repo.update(app);
      events.publish(AgentryTopics.applicationStatusChanged, Json.emptyObject
          .set("tenantId", tenantId.value).set("id", id.value)
          .set("from", enumValue(previous)).set("to", enumValue(status)));
      return succeeded(app.id.value, "Mobile application is now " ~ enumValue(status));
    });
  }

  UsecaseResult deleteMobileApplication(TenantId tenantId, MobileApplicationId id) {
    auto app = repo.findById(tenantId, id);
    if (app.isNull)
      return notFound("Mobile application", id.value);
    repo.remove(app);
    return succeeded(app.id.value, "Mobile application deleted");
  }

  /// Copy the editable fields (strings only if supplied).
  protected void apply(ref MobileApplication app, const MobileApplicationDTO dto, ref string[] errors) {
    assignIf(app.name, dto.name);
    assignIf(app.description, dto.description);
    assignIf(app.iconUrl, dto.iconUrl);
    assignIf(app.category, dto.category);
    assignIf(app.vendor, dto.vendor);
    assignIf(app.contactEmail, dto.contactEmail);
    assignIf(app.backendSystemId, dto.backendSystemId);
    assignIf(app.minOsVersion, dto.minOsVersion);
    assignIf(app.packageName, dto.packageName);
    app.offlineCapable = dto.offlineCapable;
    app.pushNotificationsEnabled = dto.pushNotificationsEnabled;
    readEnum(dto.platform, app.platform, "platform", errors);
  }
}

///
unittest {
  mixin(ShowTest!("ManageMobileApplicationsUseCase"));

  auto uc = new ManageMobileApplicationsUseCase(new MobileApplicationRepository());
  auto t = TenantId("t1");

  MobileApplicationDTO dto;
  dto.tenantId = t;
  dto.name = "Work Manager";
  dto.packageName = "com.example.workmanager";
  dto.platform = "ios";
  auto r = uc.createMobileApplication(dto);
  assert(r.isSuccess, r.message);
  auto id = MobileApplicationId(r.id);
  assert(uc.getMobileApplication(t, id).platform == AppPlatform.ios);

  assert(uc.createMobileApplication(dto).code == 409); // duplicate package

  dto.packageName = "invalid";
  assert(uc.createMobileApplication(dto).code == 400);

  assert(uc.setMobileApplicationStatus(t, id, AppStatus.active, UserId("u")).isSuccess);
  assert(uc.setMobileApplicationStatus(t, id, AppStatus.draft, UserId("u")).code == 422);
  assert(uc.deleteMobileApplication(t, id).isSuccess);
  assert(uc.deleteMobileApplication(t, id).code == 404);
}
