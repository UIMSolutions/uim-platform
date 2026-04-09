/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.trusted_certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageTrustedCertificatesUseCase : UIMUseCase {
    private TrustedCertificateRepository repo;

    this(TrustedCertificateRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateTrustedCertificateRequest r) {
        if (r.id.isEmpty)
            return CommandResult(false, "", "ID is required");
        if (r.certificatePem.length == 0)
            return CommandResult(false, "", "Certificate PEM is required");
        if (r.customDomainid.isEmpty)
            return CommandResult(false, "", "Custom domain ID is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Trusted certificate already exists");

        TrustedCertificate c;
        c.id = r.id;
        c.tenantId = r.tenantId;
        c.customDomainId = r.customDomainId;
        c.certificatePem = r.certificatePem;
        c.status = TrustedCertificateStatus.active;
        c.createdBy = r.createdBy;

        import core.time : MonoTime;
        c.createdAt = MonoTime.currTime.ticks;

        repo.save(c);
        return CommandResult(true, c.id, "");
    }

    TrustedCertificate get_(TrustedCertificateId id) {
        return repo.findById(id);
    }

    TrustedCertificate[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    TrustedCertificate[] listByDomain(CustomDomainId domainId) {
        return repo.findByDomain(domainId);
    }

    CommandResult remove(TrustedCertificateId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Trusted certificate not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
