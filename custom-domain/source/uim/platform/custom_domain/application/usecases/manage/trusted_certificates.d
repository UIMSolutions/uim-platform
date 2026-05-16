/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.trusted_certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageTrustedCertificatesUseCase { // TODO: UIMUseCase {
    private TrustedCertificateRepository repo;

    this(TrustedCertificateRepository repo) {
        this.repo = repo;
    }

    CommandResult createTrustedCertificate(CreateTrustedCertificateRequest r) {
        if (r.isNull)
            return CommandResult(false, "", "ID is required");
        if (r.certificatePem.length == 0)
            return CommandResult(false, "", "Certificate PEM is required");
        if (r.customDomainId.isEmpty)
            return CommandResult(false, "", "Custom domain ID is required");

        auto existing = repo.findById(r.id);
        if (!existing.isNull)
            return CommandResult(false, "", "Trusted certificate already exists");

        TrustedCertificate c;
        c.id = r.id;
        c.tenantId = r.tenantId;
        c.customDomainId = r.customDomainId;
        c.certificatePem = r.certificatePem;
        c.status = TrustedCertificateStatus.active;
        c.createdBy = r.createdBy;

        import core.time : MonoTime;
        c.createdAt = currentTimestamp;
        c.updatedAt = currentTimestamp;
        repo.save(c);
        return CommandResult(true, c.id.value, "");
    }

    TrustedCertificate getTrustedCertificateById(TenantId tenantId, TrustedCertificateId id) {
        return repo.findById(tenantId, id);
    }

    TrustedCertificate[] listTrustedCertificates(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    TrustedCertificate[] listTrustedCertificatesByDomain(TenantId tenantId, CustomDomainId domainId) {
        return repo.findByDomain(tenantId, domainId);
    }

    CommandResult deleteTrustedCertificate(TenantId tenantId, TrustedCertificateId id) {
        auto certificate = repo.findById(tenantId, id);
        if (certificate.isNull)
            return CommandResult(false, "", "Trusted certificate not found");

        repo.remove(certificate);
        return CommandResult(true, certificate.id.value, "");
    }
}
