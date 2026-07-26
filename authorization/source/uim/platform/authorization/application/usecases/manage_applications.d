module uim.platform.authorization.application.usecases.manage_applications;

import std.uuid : randomUUID;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class ManageApplicationsUseCase {
  private AuthorizationRepository repo;

  this(AuthorizationRepository repo) {
    this.repo = repo;
  }

  UseCaseResult createApplication(CreateApplicationRequest req) {
    if (req.name.isEmpty) {
      return UseCaseResult(false, "", "Application name is required");
    }

    if (repo.applicationNameExists(req.tenantId, req.name)) {
      return UseCaseResult(false, "", "Application name already exists");
    }

    ManagedApplication app;
    app.id = randomUUID().toString();
    app.tenantId = req.tenantId;
    app.name = req.name;
    app.organizationId = req.organizationId.length ? req.organizationId : "global";
    app.description = req.description;
    app.createdAt = currentTimestamp();
    app.updatedAt = app.createdAt;

    repo.saveApplication(app);
    return UseCaseResult(true, app.id, "");
  }

  UseCaseResult updateApplication(UpdateApplicationRequest req) {
    auto app = repo.findApplicationById(req.tenantId, req.applicationId);
    if (app.id.isEmpty) {
      return UseCaseResult(false, "", "Application not found");
    }

    if (req.name.length) app.name = req.name;
    if (req.organizationId.length) app.organizationId = req.organizationId;
    if (req.description.length) app.description = req.description;
    app.updatedAt = currentTimestamp();

    repo.saveApplication(app);
    return UseCaseResult(true, app.id, "");
  }

  UseCaseResult deleteApplication(string tenantId, string applicationId) {
    auto app = repo.findApplicationById(tenantId, applicationId);
    if (app.id.isEmpty) {
      return UseCaseResult(false, "", "Application not found");
    }

    repo.deleteApplication(tenantId, applicationId);
    return UseCaseResult(true, applicationId, "");
  }

  ManagedApplication[] listApplications(string tenantId) {
    return repo.listApplications(tenantId);
  }

  ManagedApplication getApplication(string tenantId, string applicationId) {
    return repo.findApplicationById(tenantId, applicationId);
  }

  UseCaseResult createApplicationApi(CreateApplicationApiRequest req) {
    if (req.applicationId.isEmpty || req.name.isEmpty || req.endpoint.isEmpty) {
      return UseCaseResult(false, "", "applicationId, name and endpoint are required");
    }

    auto app = repo.findApplicationById(req.tenantId, req.applicationId);
    if (app.id.isEmpty) {
      return UseCaseResult(false, "", "Application not found");
    }

    ApplicationApi api;
    api.id = randomUUID().toString();
    api.tenantId = req.tenantId;
    api.applicationId = req.applicationId;
    api.name = req.name;
    api.endpoint = req.endpoint;
    api.operations = req.operations.dup;
    api.createdAt = currentTimestamp();
    api.updatedAt = api.createdAt;

    repo.saveApplicationApi(api);
    return UseCaseResult(true, api.id, "");
  }

  UseCaseResult updateApplicationApi(UpdateApplicationApiRequest req) {
    auto api = repo.findApplicationApiById(req.tenantId, req.apiId);
    if (api.id.isEmpty) {
      return UseCaseResult(false, "", "Application API not found");
    }

    if (req.name.length) api.name = req.name;
    if (req.endpoint.length) api.endpoint = req.endpoint;
    if (req.operations.length) api.operations = req.operations.dup;
    api.updatedAt = currentTimestamp();

    repo.saveApplicationApi(api);
    return UseCaseResult(true, api.id, "");
  }

  UseCaseResult deleteApplicationApi(string tenantId, string apiId) {
    auto api = repo.findApplicationApiById(tenantId, apiId);
    if (api.id.isEmpty) {
      return UseCaseResult(false, "", "Application API not found");
    }

    repo.deleteApplicationApi(tenantId, apiId);
    return UseCaseResult(true, apiId, "");
  }

  ApplicationApi[] listApplicationApis(string tenantId) {
    return repo.listApplicationApis(tenantId);
  }

  ApplicationApi getApplicationApi(string tenantId, string apiId) {
    return repo.findApplicationApiById(tenantId, apiId);
  }
}
