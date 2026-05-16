/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.domain_mappings;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageDomainMappingsUseCase { // TODO: UIMUseCase {
    private DomainMappingRepository repo;

    this(DomainMappingRepository repo) {
        this.repo = repo;
    }

    CommandResult createDomainMapping(CreateDomainMappingRequest r) {
        if (r.customDomainId.isEmpty)
            return CommandResult(false, "", "Custom domain ID is required");
        if (r.standardRoute.length == 0)
            return CommandResult(false, "", "Standard route is required");
        if (r.customRoute.length == 0)
            return CommandResult(false, "", "Custom route is required");

        auto existing = repo.findById(r.id);
        if (!existing.isNull)
            return CommandResult(false, "", "Domain mapping already exists");

        auto byRoute = repo.findByCustomRoute(r.tenantId, r.customRoute);
        if (byRoute.id.length > 0)
            return CommandResult(false, "", "Custom route already mapped");

        DomainMapping m;
        m.id = r.id;
        m.tenantId = r.tenantId;
        m.customDomainId = r.customDomainId;
        m.standardRoute = r.standardRoute;
        m.customRoute = r.customRoute;
        m.status = MappingStatus.active;
        m.applicationName = r.applicationName;
        m.organizationId = r.organizationId;
        m.spaceId = r.spaceId;
        m.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = currentTimestamp;
        m.createdAt = now;
        m.updatedAt = now;

        repo.save(m);
        return CommandResult(true, m.id.value, "");
    }

    DomainMapping getDomainMappingById(TenantId tenantId, DomainMappingId id) {
        return repo.findById(tenantId, id);
    }

    DomainMapping[] listDomainMappings(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DomainMapping[] listDomainMappings(TenantId tenantId, CustomDomainId domainId) {
        return repo.findByDomain(tenantId, domainId);
    }

    CommandResult deleteDomainMapping(TenantId tenantId, DomainMappingId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Domain mapping not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
