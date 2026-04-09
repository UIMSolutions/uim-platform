/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.private_keys;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManagePrivateKeysUseCase : UIMUseCase {
    private PrivateKeyRepository repo;

    this(PrivateKeyRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreatePrivateKeyRequest r) {
        if (r.id.isEmpty)
            return CommandResult(false, "", "ID is required");
        if (r.subject.length == 0)
            return CommandResult(false, "", "Subject is required");
        if (r.domains.length == 0)
            return CommandResult(false, "", "At least one domain is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Key already exists");

        PrivateKey k;
        k.id = r.id;
        k.tenantId = r.tenantId;
        k.subject = r.subject;
        k.domains = r.domains;
        k.keySize = r.keySize > 0 ? r.keySize : 2048;
        k.status = KeyStatus.active;
        k.createdBy = r.createdBy;

        import core.time : MonoTime;
        k.createdAt = MonoTime.currTime.ticks;

        repo.save(k);
        return CommandResult(true, k.id, "");
    }

    PrivateKey get_(PrivateKeyId id) {
        return repo.findById(id);
    }

    PrivateKey[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult remove(PrivateKeyId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Key not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
