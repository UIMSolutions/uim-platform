/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.custom_domains;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageCustomDomainsUseCase { // TODO: UIMUseCase {
    private CustomDomainRepository repo;

    this(CustomDomainRepository repo) {
        this.repo = repo;
    }

    CommandResult createCustomDomain(CreateCustomDomainRequest r) {
        auto err = DomainValidator.validateDomainName(r.domainName);
        if (err.length > 0)
            return CommandResult(false, "", err);

        if (r.customDomainId.isEmpty)
            return CommandResult(false, "", "Certificate ID is required");

        auto existing = repo.findById(r.tenantId, r.customDomainId);
        if (!existing.isNull)
            return CommandResult(false, "", "Custom domain already exists");

        auto byName = repo.findByDomainName(r.tenantId, r.domainName);
        if (byName.id.length > 0)
            return CommandResult(false, "", "Domain name already registered");

        CustomDomain d;
        d.initEntity(r.tenantId, r.createdBy);

        d.id = r.customDomainId;
        d.domainName = r.domainName;
        d.organizationId = r.organizationId;
        d.spaceId = r.spaceId;
        d.status = DomainStatus.pending;

        repo.save(d);
        return CommandResult(true, d.id.value, "");
    }

    CustomDomain getCustomDomain(TenantId tenantId, CustomDomainId id) {
        return repo.findById(tenantId, id);
    }

    CustomDomain[] listCustomDomains(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateCustomDomain(UpdateCustomDomainRequest r) {
        auto domain = repo.findById(r.tenantId, r.customDomainId);
        if (domain.isNull)
            return CommandResult(false, "", "Custom domain not found");

        domain.activeCertificateId = r.activeCertificateId;
        domain.tlsConfigurationId = r.tlsConfigurationId;
        domain.isShared = r.isShared;
        domain.sharedWithOrgs = r.sharedWithOrgs;
        domain.clientAuthEnabled = r.clientAuthEnabled;
        domain.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        domain.updatedAt = currentTimestamp;

        repo.update(domain);
        return CommandResult(true, domain.id.value, "");
    }

    CommandResult activateCustomDomain(TenantId tenantId, CustomDomainId id) {
        auto domain = repo.findById(tenantId, id);
        if (domain.isNull)
            return CommandResult(false, "", "Custom domain not found");
        domain.status = DomainStatus.active;

        import core.time : MonoTime;
        domain.updatedAt = currentTimestamp;

        repo.update(domain);
        return CommandResult(true, id.value, "");
    }

    CommandResult deactivateCustomDomain(TenantId tenantId, CustomDomainId id) {
        auto domain = repo.findById(tenantId, id);
        if (domain.isNull)
            return CommandResult(false, "", "Custom domain not found");
        domain.status = DomainStatus.deactivated;

        import core.time : MonoTime;
        domain.updatedAt = currentTimestamp;

        repo.update(domain);
        return CommandResult(true, id.value, "");
    }

    CommandResult deleteCustomDomain(TenantId tenantId, CustomDomainId id) {
        auto domain = repo.findById(tenantId, id);
        if (domain.isNull)
            return CommandResult(false, "", "Custom domain not found");

        repo.remove(domain);
        return CommandResult(true, domain.id.value, "");
    }
}
