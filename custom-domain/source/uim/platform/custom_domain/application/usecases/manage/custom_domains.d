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

    CommandResult create(CreateCustomDomainRequest r) {
        auto err = DomainValidator.validateDomainName(r.domainName);
        if (err.length > 0)
            return CommandResult(false, "", err);

        if (r.isNull)
            return CommandResult(false, "", "ID is required");

        auto existing = repo.findById(r.id);
        if (!existing.isNull)
            return CommandResult(false, "", "Custom domain already exists");

        auto byName = repo.findByDomainName(r.tenantId, r.domainName);
        if (byName.id.length > 0)
            return CommandResult(false, "", "Domain name already registered");

        CustomDomain d;
        d.id = r.id;
        d.tenantId = r.tenantId;
        d.domainName = r.domainName;
        d.organizationId = r.organizationId;
        d.spaceId = r.spaceId;
        d.status = DomainStatus.pending;
        d.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        d.createdAt = now;
        d.updatedAt = now;

        repo.save(d);
        return CommandResult(true, d.id, "");
    }

    CustomDomain getById(CustomDomainId id) {
        return repo.findById(id);
    }

    CustomDomain[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateCustomDomainRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Custom domain not found");

        existing.activeCertificateId = r.activeCertificateId;
        existing.tlsConfigurationId = r.tlsConfigurationId;
        existing.isShared = r.isShared;
        existing.sharedWithOrgs = r.sharedWithOrgs;
        existing.clientAuthEnabled = r.clientAuthEnabled;
        existing.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult activate(CustomDomainId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Custom domain not found");
        existing.status = DomainStatus.active;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult deactivate(CustomDomainId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Custom domain not found");
        existing.status = DomainStatus.deactivated;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(CustomDomainId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Custom domain not found");

        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
