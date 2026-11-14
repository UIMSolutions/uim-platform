/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.application.usecases.manage_applications;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Use case: applications. Names are unique per tenant; deleting an
/// application cascades to its APIs, policies and their assignments.
class ManageApplicationsUseCase : IManageApplications {
  protected IApplicationRepository applications;
  protected IApplicationApiRepository apis;
  protected IPolicyRepository policies;
  protected IAssignmentRepository assignments;

  this(IApplicationRepository applications, IApplicationApiRepository apis, IPolicyRepository policies,
    IAssignmentRepository assignments) {
    this.applications = applications;
    this.apis = apis;
    this.policies = policies;
    this.assignments = assignments;
  }

  ManagedApplication createApplication(CreateApplicationRequest r) {
    ManagedApplication app;
    app.name = r.name.strip;
    app.organizationId = r.organizationId.strip.length > 0 ? r.organizationId.strip : "global";
    app.description = r.description;
    app.validate();
    if (!applications.findByName(r.tenantId, app.name).isNull)
      throw AuthorizationException.conflict("Application '" ~ app.name ~ "' already exists");
    stampCreated(app, r.tenantId, r.actor);
    applications.save(app);
    return app;
  }

  ManagedApplication updateApplication(UpdateApplicationRequest r) {
    auto app = getApplication(r.tenantId, r.id);
    if (r.fields.has("name") && r.name.strip != app.name) {
      if (!applications.findByName(r.tenantId, r.name.strip).isNull)
        throw AuthorizationException.conflict("Application '" ~ r.name.strip ~ "' already exists");
      app.name = r.name.strip;
    }
    if (r.fields.has("organizationId"))
      app.organizationId = r.organizationId.strip.length > 0 ? r.organizationId.strip : "global";
    if (r.fields.has("description"))
      app.description = r.description;
    app.validate();
    stampUpdated(app, r.actor);
    applications.save(app);
    return app;
  }

  ManagedApplication getApplication(TenantId tenantId, ManagedApplicationId id) {
    return required(applications.findById(tenantId, id), "Application '" ~ id.value ~ "'");
  }

  ManagedApplication resolveApplication(TenantId tenantId, string idOrName) {
    auto key = idOrName.strip;
    if (key.length == 0)
      throw AuthorizationException.invalid("application (id or name) is required");
    auto app = applications.findById(tenantId, ManagedApplicationId(key));
    if (app.isNull)
      app = applications.findByName(tenantId, key);
    return required(app, "Application '" ~ key ~ "'");
  }

  ManagedApplication[] listApplications(TenantId tenantId) {
    return applications.findAll(tenantId);
  }

  void deleteApplication(TenantId tenantId, ManagedApplicationId id) {
    auto app = getApplication(tenantId, id);
    foreach (p; policies.findByApplication(tenantId, app.id)) {
      foreach (a; assignments.findByPolicy(tenantId, p.id))
        assignments.removeById(tenantId, a.id);
      policies.removeById(tenantId, p.id);
    }
    foreach (api; apis.findByApplication(tenantId, app.id))
      apis.removeById(tenantId, api.id);
    applications.removeById(tenantId, app.id);
  }
}
