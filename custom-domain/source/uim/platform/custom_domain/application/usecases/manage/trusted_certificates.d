/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.trusted_certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageTrustedCertificatesUseCase {
    private ITrustedCertificateRepository repo;

    this(ITrustedCertificateRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createCertificate(CreateTrustedCertificateRequest r) {
        if (r.trustedCertificateId.isEmpty)
            return UsecaseResult(false, "", "ID is required");
        if (r.certificatePem.length == 0)
            return UsecaseResult(false, "", "Certificate PEM is required");
        if (r.customDomainId.isEmpty)
            return UsecaseResult(false, "", "Custom domain ID is required");

        auto existing = repo.findById(r.tenantId, r.trustedCertificateId);
        if (!existing.isNull)
            return UsecaseResult(false, "", "Trusted certificate already exists");

        auto c = TrustedCertificate(r.tenantId, r.trustedCertificateId, r.createdBy);
        c.customDomainId = r.customDomainId;
        c.certificatePem = r.certificatePem;
        c.status = TrustedCertificateStatus.active;

        repo.save(c);
        return UsecaseResult(true, c.id.value, "");
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

    UsecaseResult deleteCertificate(TenantId tenantId, TrustedCertificateId id) {
        auto certificate = repo.findById(tenantId, id);
        if (certificate.isNull)
            return UsecaseResult(false, "", "Trusted certificate not found");

        repo.remove(certificate);
        return UsecaseResult(true, certificate.id.value, "");
    }
}

///
unittest {
    // auto repo = new TrustedCertificateRepository();
    // auto usecase = new ManageTrustedCertificatesUseCase(repo);
    // auto tenantId = TenantId("test-tenant");

    // // Test list
    // auto items = usecase.listCertificates(tenantId);
    // assert(items !is null);

}
