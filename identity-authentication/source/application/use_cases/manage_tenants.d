module application.use_cases.manage_tenants;

import domain.entities.tenant;
import domain.types;
import domain.ports.tenant;
import application.dto;

import std.uuid;
import std.datetime.systime : Clock;

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
        auto tenant = Tenant(
            randomUUID().toString(),
            req.name,
            req.subdomain,
            req.defaultSsoProtocol,
            req.allowedAuthMethods,
            req.mfaEnforced,
            [],
            now,
            now
        );
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
