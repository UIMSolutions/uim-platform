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

    CommandResult createDomain(CreateCustomDomainRequest r) {
        auto err = DomainValidator.validateDomainName(r.domainName);
        if (err.length > 0)
            return CommandResult(false, "", err);

        if (r.customDomainId.isNull)
            return CommandResult(false, "", "Domain ID is required");

        if (repo.existsById(r.tenantId, r.customDomainId))
            return CommandResult(false, "", "Domain already exists");

        if (repo.existsByDomainName(r.tenantId, r.domainName))
            return CommandResult(false, "", "Domain name already registered");

        auto d = CustomDomain(r.tenantId);
        d.id = r.customDomainId;
        d.domainName = r.domainName;
        d.organizationId = r.organizationId;
        d.spaceId = r.spaceId;
        d.status = DomainStatus.pending;

        repo.save(d);
        return CommandResult(true, d.id.value, "");
    }

    CustomDomain getDomain(TenantId tenantId, CustomDomainId id) {
        return repo.find(tenantId, id);
    }

    CustomDomain[] listDomains(TenantId tenantId) {
        return repo.find(tenantId);
    }

    CommandResult updateDomain(UpdateCustomDomainRequest r) {
        auto domain = repo.find(r.tenantId, r.customDomainId);
        if (domain.isNull)
            return CommandResult(false, "", "Custom domain not found");

        domain.activeCertificateId = r.activeCertificateId;
        domain.tlsConfigurationId = r.tlsConfigurationId;
        domain.isShared = r.isShared;
        domain.sharedWithOrgs = r.sharedWithOrgs;
        domain.clientAuthEnabled = r.clientAuthEnabled;
        domain.updatedBy = r.updatedBy;

        
        domain.updatedAt = currentTimestamp;

        repo.update(domain);
        return CommandResult(true, domain.id.value, "");
    }

    CommandResult activateDomain(TenantId tenantId, CustomDomainId id) {
        auto domain = repo.find(tenantId, id);
        if (domain.isNull)
            return CommandResult(false, "", "Custom domain not found");
        domain.status = DomainStatus.active;

        
        domain.updatedAt = currentTimestamp;

        repo.update(domain);
        return CommandResult(true, id.value, "");
    }

    CommandResult deactivateDomain(TenantId tenantId, CustomDomainId id) {
        auto domain = repo.find(tenantId, id);
        if (domain.isNull)
            return CommandResult(false, "", "Custom domain not found");
        domain.status = DomainStatus.deactivated;

        
        domain.updatedAt = currentTimestamp;

        repo.update(domain);
        return CommandResult(true, id.value, "");
    }

    CommandResult deleteDomain(TenantId tenantId, CustomDomainId id) {
        auto domain = repo.find(tenantId, id);
        if (domain.isNull)
            return CommandResult(false, "", "Custom domain not found");

        repo.remove(domain);
        return CommandResult(true, domain.id.value, "");
    }
}
