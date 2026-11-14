/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.applications;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Application (service provider / OAuth client) registration. Client secrets
/// are generated here, returned once and only stored as a fingerprint.
class ManageApplicationsUseCase : IManageApplicationsUseCase {
  protected IApplicationRepository repo;
  protected ISecretService secrets;
  protected IPolicyRepository policies;
  protected IIdentityEventPublisher events;

  this(IApplicationRepository repo, ISecretService secrets, IPolicyRepository policies = null,
      IIdentityEventPublisher events = null) {
    this.repo = repo;
    this.secrets = secrets;
    this.policies = policies;
    this.events = events is null ? new NullEventPublisher : events;
  }

  Application[] listApplications(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Application getApplication(TenantId tenantId, ApplicationId id) {
    return repo.findById(tenantId, id);
  }

  Application getByClientId(TenantId tenantId, string clientId) {
    return repo.findByClient(tenantId, clientId);
  }

  UsecaseResult createApplication(ApplicationDTO dto) {
    return guarded(() {
      if (!dto.applicationId.isNull && repo.existsById(dto.tenantId, dto.applicationId))
        return conflict("Application '" ~ dto.applicationId.value ~ "' already exists");
      auto app = newEntity!Application(dto.tenantId, dto.applicationId, dto.createdBy);
      string[] errors;
      apply(app, dto, errors);
      errors ~= IdentityValidator.validate(app);
      if (errors.length)
        return invalid(errors);

      app.clientId = "sb-" ~ generateId;
      auto secret = secrets.randomSecret();
      app.clientSecretHash = secrets.fingerprint(secret);
      repo.save(app);
      return created(app.id.value, "Application registered — store the client secret now, it is not shown again",
        Json.emptyObject.set("clientId", app.clientId).set("clientSecret", secret));
    });
  }

  UsecaseResult updateApplication(ApplicationDTO dto) {
    return guarded(() {
      auto app = repo.findById(dto.tenantId, dto.applicationId);
      if (app.isNull)
        return notFound("Application", dto.applicationId.value);
      string[] errors;
      apply(app, dto, errors);
      errors ~= IdentityValidator.validate(app);
      if (errors.length)
        return invalid(errors);
      touch(app, dto.updatedBy);
      repo.update(app);
      return succeeded(app.id.value, "Application updated");
    });
  }

  UsecaseResult rotateClientSecret(TenantId tenantId, ApplicationId id, UserId by) {
    auto app = repo.findById(tenantId, id);
    if (app.isNull)
      return notFound("Application", id.value);
    auto secret = secrets.randomSecret();
    app.clientSecretHash = secrets.fingerprint(secret);
    touch(app, by);
    repo.update(app);
    events.publish(IdentityTopics.clientSecretRotated, Json.emptyObject
        .set("tenantId", tenantId.value).set("applicationId", id.value).set("clientId", app.clientId));
    return succeeded(app.id.value, "Client secret rotated — store it now, it is not shown again", 200,
      Json.emptyObject.set("clientId", app.clientId).set("clientSecret", secret));
  }

  UsecaseResult deleteApplication(TenantId tenantId, ApplicationId id) {
    auto app = repo.findById(tenantId, id);
    if (app.isNull)
      return notFound("Application", id.value);
    if (policies !is null)
      foreach (p; policies.findByTenant(tenantId))
        if (p.applicationIds.canFind(id.value)) {
          p.applicationIds = p.applicationIds.filter!(a => a != id.value).array;
          policies.update(p);
        }
    repo.remove(app);
    return succeeded(id.value, "Application deleted");
  }

  protected void apply(ref Application app, const ApplicationDTO dto, ref string[] errors) {
    assignIf(app.name, dto.name.strip);
    app.description = dto.description;
    readEnum(dto.protocol, app.protocol, "protocol", errors);
    app.redirectUris = cleanList(dto.redirectUris);
    app.allowedScopes = cleanList(dto.allowedScopes);
    app.samlEntityId = dto.samlEntityId;
    app.samlAcsUrl = dto.samlAcsUrl;
    app.samlMetadataUrl = dto.samlMetadataUrl;
    app.active = dto.active;
  }
}

///
unittest {
  mixin(ShowTest!("ManageApplicationsUseCase"));

  auto secrets = new Sha256SecretService();
  auto uc = new ManageApplicationsUseCase(new ApplicationRepository(), secrets);
  auto t = TenantId("t1");

  ApplicationDTO dto;
  dto.tenantId = t;
  dto.name = "Portal";
  dto.redirectUris = ["https://portal.example.com/callback", " "];
  dto.allowedScopes = ["openid", "openid", "profile"];
  auto r = uc.createApplication(dto);
  assert(r.isSuccess, r.message);
  auto app = uc.getApplication(t, ApplicationId(r.id));
  assert(app.redirectUris.length == 1 && app.allowedScopes == ["openid", "profile"]);
  auto secret = r.data["clientSecret"].get!string;
  assert(secrets.matches(secret, app.clientSecretHash));
  assert("clientSecretHash" !in app.toJson);

  auto rotated = uc.rotateClientSecret(t, app.id, UserId("admin"));
  assert(rotated.isSuccess);
  app = uc.getApplication(t, app.id);
  assert(!secrets.matches(secret, app.clientSecretHash));
  assert(secrets.matches(rotated.data["clientSecret"].get!string, app.clientSecretHash));

  dto.redirectUris = ["ftp://nope"];
  assert(uc.createApplication(dto).code == 400);
  dto.redirectUris = null;
  dto.protocol = "kerberos";
  assert(uc.createApplication(dto).code == 400);
}
