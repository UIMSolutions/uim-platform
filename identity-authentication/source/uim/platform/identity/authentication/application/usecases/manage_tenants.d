/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.tenants;

// import uim.platform.identity_authentication.domain.entities.tenant;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.tenant;
// import uim.platform.identity_authentication.application.dto;
// 
// // import std.uuid;
// // import std.datetime.systime : Clock;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: tenant management.
class ManageTenantsUseCase
{
  private TenantRepository tenantRepo;

  this(TenantRepository tenantRepo)
  {
    this.tenantRepo = tenantRepo;
  }

  TenantResponse createTenant(CreateTenantRequest req)
  {
    auto existing = tenantRepo.findBySubdomain(req.subdomain);
    if (existing != Tenant.init)
      return TenantResponse("", "Subdomain already in use");

    auto now = Clock.currStdTime();
    auto tenant = Tenant(randomUUID().toString(), req.name, req.subdomain,
        req.defaultSsoProtocol, req.allowedAuthMethods, req.mfaEnforced, [], now, now);
    tenantRepo.save(tenant);
    return TenantResponse(tenant.id, "");
  }

  Tenant getTenant(TenantId id)
  {
    return tenantRepo.findById(id);
  }

  Tenant[] listTenants(uint offset = 0, uint limit = 100)
  {
    return tenantRepo.findAll(offset, limit);
  }

  string updateTenant(UpdateTenantRequest req)
  {
    auto tenant = tenantRepo.findById(req.tenantId);
    if (tenant == Tenant.init)
      return "Tenant not found";

    if (req.name.length > 0)
      tenant.name = req.name;
    if (req.allowedAuthMethods.length > 0)
      tenant.allowedAuthMethods = req.allowedAuthMethods;

    tenant.updatedAt = Clock.currStdTime();
    tenantRepo.update(tenant);
    return "";
  }
}
