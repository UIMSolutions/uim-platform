/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.custom_domains;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageCustomDomainsUseCase : UIMUseCase {
    private CustomDomainRepository repo;

    this(CustomDomainRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateCustomDomainRequest r) {
        auto err = DomainValidator.validateDomainName(r.domainName);
        if (err.length > 0)
            return CommandResult(false, "", err);

        if (r.id.isEmpty)
            return CommandResult(false, "", "ID is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
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
        d.modifiedAt = now;

        repo.save(d);
        return CommandResult(true, d.id, "");
    }

    CustomDomain get_(CustomDomainId id) {
        return repo.findById(id);
    }

    CustomDomain[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateCustomDomainRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Custom domain not found");

        existing.activeCertificateId = r.activeCertificateId;
        existing.tlsConfigurationId = r.tlsConfigurationId;
        existing.isShared = r.isShared;
        existing.sharedWithOrgs = r.sharedWithOrgs;
        existing.clientAuthEnabled = r.clientAuthEnabled;
        existing.modifiedBy = r.modifiedBy;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult activate(CustomDomainId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Custom domain not found");
        existing.status = DomainStatus.active;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, id.toString, "");
    }

    CommandResult deactivate(CustomDomainId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Custom domain not found");
        existing.status = DomainStatus.deactivated;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, id.toString, "");
    }

    CommandResult remove(CustomDomainId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Custom domain not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
