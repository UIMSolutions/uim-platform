/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.trusted_certificates;

import uim.platform.custom_domain;

// mixin(ShowModule!());

@safe:

class ManageTrustedCertificatesUseCase { // TODO: UIMUseCase {
    private TrustedCertificateRepository repo;

    this(TrustedCertificateRepository repo) {
        this.repo = repo;
    }

    CommandResult createCertificate(CreateTrustedCertificateRequest r) {
        if (r.trustedCertificateId.isEmpty)
            return CommandResult(false, "", "ID is required");
        if (r.certificatePem.length == 0)
            return CommandResult(false, "", "Certificate PEM is required");
        if (r.customDomainId.isEmpty)
            return CommandResult(false, "", "Custom domain ID is required");

        auto existing = repo.findById(r.tenantId, r.trustedCertificateId);
        if (!existing.isNull)
            return CommandResult(false, "", "Trusted certificate already exists");

        TrustedCertificate c;
        c.initEntity(r.tenantId, r.createdBy);

        c.id = r.trustedCertificateId;
        c.customDomainId = r.customDomainId;
        c.certificatePem = r.certificatePem;
        c.status = TrustedCertificateStatus.active;

        repo.save(c);
        return CommandResult(true, c.id.value, "");
    }

    TrustedCertificate getCertificate(TenantId tenantId, TrustedCertificateId id) {
        return repo.findById(tenantId, id);
    }

    TrustedCertificate[] listCertificates(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    TrustedCertificate[] listCertificates(TenantId tenantId, CustomDomainId domainId) {
        return repo.findByCustomDomain(tenantId, domainId);
    }

    CommandResult deleteCertificate(TenantId tenantId, TrustedCertificateId id) {
        auto certificate = repo.findById(tenantId, id);
        if (certificate.isNull)
            return CommandResult(false, "", "Trusted certificate not found");

        repo.remove(certificate);
        return CommandResult(true, certificate.id.value, "");
    }
}
