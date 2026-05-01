/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.certificates;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManageCertificatesUseCase { // TODO: UIMUseCase {
    private CertificateRepository repo;

    this(CertificateRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateCertificateRequest r) {
        if (r.isNull)
            return CommandResult(false, "", "ID is required");
        if (r.keyId.isEmpty)
            return CommandResult(false, "", "Key ID is required");

        auto existing = repo.findById(r.id);
        if (!existing.isNull)
            return CommandResult(false, "", "Certificate already exists");

        Certificate c;
        c.id = r.id;
        c.tenantId = r.tenantId;
        c.keyId = r.keyId;
        c.status = CertificateStatus.pending;
        c.createdBy = r.createdBy;

        import core.time : MonoTime;
        c.createdAt = MonoTime.currTime.ticks;

        repo.save(c);
        return CommandResult(true, c.id, "");
    }

    CommandResult uploadChain(UploadCertificateChainRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Certificate not found");
        if (r.certificatePem.length == 0)
            return CommandResult(false, "", "Certificate PEM is required");

        existing.certificatePem = r.certificatePem;
        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult activate(ActivateCertificateRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Certificate not found");

        existing.status = CertificateStatus.active;
        existing.activatedDomains = r.domains;

        import core.time : MonoTime;
        existing.activatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult deactivate(CertificateId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Certificate not found");

        existing.status = CertificateStatus.deactivated;
        repo.update(existing);
        return CommandResult(true, id.toString, "");
    }

    Certificate getById(CertificateId id) {
        return repo.findById(id);
    }

    Certificate[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Certificate[] listByKey(PrivateKeyId keyId) {
        return repo.findByKey(keyId);
    }

    Certificate[] listExpiring(TenantId tenantId, long beforeTimestamp) {
        return repo.findExpiring(tenantId, beforeTimestamp);
    }

    CommandResult remove(CertificateId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Certificate not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
