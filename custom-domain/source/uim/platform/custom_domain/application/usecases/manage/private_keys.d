/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.application.usecases.manage.private_keys;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class ManagePrivateKeysUseCase { // TODO: UIMUseCase {
    private PrivateKeyRepository repo;

    this(PrivateKeyRepository repo) {
        this.repo = repo;
    }

    CommandResult createPrivateKey(CreatePrivateKeyRequest r) {
        if (r.isNull)
            return CommandResult(false, "", "ID is required");
        if (r.subject.length == 0)
            return CommandResult(false, "", "Subject is required");
        if (r.domains.length == 0)
            return CommandResult(false, "", "At least one domain is required");

        auto existing = repo.findById(r.id);
        if (!existing.isNull)
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
        auto now = MonoTime.currTime.ticks;
        k.createdAt = now;
        k.updatedAt = now;

        repo.save(k);
        return CommandResult(true, k.id.value, "");
    }

    PrivateKey getPrivateKey(TenantId tenantId, PrivateKeyId id) {
        return repo.findById(tenantId, id);
    }

    PrivateKey[] listPrivateKeys(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult deletePrivateKey(TenantId tenantId, PrivateKeyId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Key not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
