/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.application.usecases.manage_application_apis;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Use case: APIs of applications (names unique per application).
class ManageApplicationApisUseCase : IManageApplicationApis {
  protected IApplicationApiRepository apis;
  protected IApplicationRepository applications;

  this(IApplicationApiRepository apis, IApplicationRepository applications) {
    this.apis = apis;
    this.applications = applications;
  }

  ApplicationApi createApi(CreateApplicationApiRequest r) {
    ApplicationApi api;
    api.applicationId = r.applicationId;
    api.name = r.name.strip;
    api.endpoint = r.endpoint.strip;
    api.operations = normalized(r.operations);
    api.validate();
    required(applications.findById(r.tenantId, api.applicationId), "Application '" ~ api.applicationId.value ~ "'");
    if (!apis.findByName(r.tenantId, api.applicationId, api.name).isNull)
      throw AuthorizationException.conflict("API '" ~ api.name ~ "' already exists in this application");
    stampCreated(api, r.tenantId, r.actor);
    apis.save(api);
    return api;
  }

  ApplicationApi updateApi(UpdateApplicationApiRequest r) {
    auto api = getApi(r.tenantId, r.id);
    if (r.fields.has("name") && r.name.strip != api.name) {
      if (!apis.findByName(r.tenantId, api.applicationId, r.name.strip).isNull)
        throw AuthorizationException.conflict("API '" ~ r.name.strip ~ "' already exists in this application");
      api.name = r.name.strip;
    }
    if (r.fields.has("endpoint"))
      api.endpoint = r.endpoint.strip;
    if (r.fields.has("operations"))
      api.operations = normalized(r.operations);
    api.validate();
    stampUpdated(api, r.actor);
    apis.save(api);
    return api;
  }

  ApplicationApi getApi(TenantId tenantId, ApplicationApiId id) {
    return required(apis.findById(tenantId, id), "Application API '" ~ id.value ~ "'");
  }

  ApplicationApi[] listApis(TenantId tenantId) {
    return apis.findAll(tenantId);
  }

  ApplicationApi[] listApis(TenantId tenantId, ManagedApplicationId applicationId) {
    return apis.findByApplication(tenantId, applicationId);
  }

  void deleteApi(TenantId tenantId, ApplicationApiId id) {
    getApi(tenantId, id);
    apis.removeById(tenantId, id);
  }

  protected static string[] normalized(string[] operations) {
    string[] result;
    foreach (o; operations.map!(o => o.strip).filter!(o => o.length > 0))
      if (!result.canFind(o))
        result ~= o;
    return result;
  }
}
