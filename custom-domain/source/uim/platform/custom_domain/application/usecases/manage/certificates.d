/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageCertificatesUseCase {
    private ICertificateRepository repo;

    this(ICertificateRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createCertificate(CreateCertificateRequest r) {
        if (r.certificateId.isEmpty)
            return UsecaseResult(false, "", "ID is required");
        if (r.keyId.isEmpty)
            return UsecaseResult(false, "", "Key ID is required");

        auto existing = repo.findById(r.tenantId, r.certificateId);
        if (!existing.isNull)
            return UsecaseResult(false, "", "Certificate already exists");

        Certificate c;
        c.id = r.certificateId;
        c.tenantId = r.tenantId;
        // TODO: c.keyId = r.keyId;
        c.status = CertificateStatus.pending;
        c.createdBy = r.createdBy;

        
        c.createdAt = currentTimestamp;

        repo.save(c);
        return UsecaseResult(true, c.id.value, "");
    }

    UsecaseResult uploadCertificateChain(UploadCertificateChainRequest r) {
        auto existing = repo.findById(r.tenantId, r.certificateId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Certificate not found");
        if (r.certificatePem.length == 0)
            return UsecaseResult(false, "", "Certificate PEM is required");

        existing.certificatePem = r.certificatePem;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult activateCertificate(ActivateCertificateRequest r) {
        auto existing = repo.findById(r.tenantId, r.certificateId);
         if (existing.isNull)
            return UsecaseResult(false, "", "Certificate not found");
        if (existing.certificatePem.length == 0)
            return UsecaseResult(false, "", "Certificate PEM is required");
        if (existing.isNull)
            return UsecaseResult(false, "", "Certificate not found");

        existing.status = CertificateStatus.active;
        existing.activatedDomains = r.domains;

        
        existing.activatedAt = currentTimestamp;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deactivateCertificate(TenantId tenantId, CertificateId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "Certificate not found");

        existing.status = CertificateStatus.deactivated;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    Certificate getCertificate(TenantId tenantId, CertificateId id) {
        return repo.findById(tenantId, id);
    }

    Certificate[] listCertificates(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Certificate[] listCertificates(TenantId tenantId, PrivateKeyId keyId) {
        return repo.findByKey(tenantId, keyId);
    }

    Certificate[] listExpiringCertificates(TenantId tenantId, long beforeTimestamp) {
        return repo.findExpiring(tenantId, beforeTimestamp);
    }

    UsecaseResult deleteCertificate(TenantId tenantId, CertificateId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return UsecaseResult(false, "", "Certificate not found");

        repo.remove(entity);
        return UsecaseResult(true, entity.id.value, "");
    }
}

///
unittest {
    // auto repo = new CertificateRepository();
    // auto usecase = new ManageCertificatesUseCase(repo);
    // auto tenantId = TenantId("test-tenant");

    // // Test list
    // auto items = usecase.listCertificates(tenantId);
    // assert(items !is null);

}
