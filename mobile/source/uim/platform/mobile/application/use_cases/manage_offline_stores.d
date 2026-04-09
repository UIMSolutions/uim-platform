/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.offline_stores;

import uim.platform.mobile.domain.ports.repositories.offline_stores;
import uim.platform.mobile.domain.entities.offline_store;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.domain.services.offline_sync_service;
import uim.platform.mobile.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

class ManageOfflineStoresUseCase : UIMUseCase {
    private OfflineStoreRepository repo;

    this(OfflineStoreRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateOfflineStoreRequest r) {
        if (!OfflineSyncService.validateStoreName(r.name))
            return CommandResult(false, "", "Invalid store name");
        OfflineStore store;
        store.id = randomUUID();
        store.tenantId = r.tenantId;
        store.appId = r.appId;
        store.name = r.name;
        store.description = r.description;
        store.storeType = r.storeType;
        store.encryptionEnabled = r.encryptionEnabled;
        store.maxSizeMb = r.maxSizeMb;
        store.syncPolicy = r.syncPolicy;
        store.conflictPolicy = r.conflictPolicy;
        store.status = OfflineStoreStatus.active;
        store.createdAt = currentTimestamp();
        store.updatedAt = store.createdAt;
        store.createdBy = r.createdBy;
        repo.save(store);
        return CommandResult(true, store.id, "");
    }

    CommandResult update(OfflineStoreId id, UpdateOfflineStoreRequest r) {
        auto store = repo.findById(id);
        if (store.id.isEmpty)
            return CommandResult(false, "", "Offline store not found");
        if (r.description.length > 0) store.description = r.description;
        if (r.syncPolicy.length > 0) store.syncPolicy = r.syncPolicy;
        if (r.conflictPolicy.length > 0) store.conflictPolicy = r.conflictPolicy;
        if (r.maxSizeMb > 0) store.maxSizeMb = r.maxSizeMb;
        store.encryptionEnabled = r.encryptionEnabled;
        store.updatedAt = currentTimestamp();
        store.modifiedBy = r.modifiedBy;
        repo.update(store);
        return CommandResult(true, store.id, "");
    }

    OfflineStore get_(OfflineStoreId id) {
        return repo.findById(id);
    }

    OfflineStore[] listByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    void remove(OfflineStoreId id) {
        repo.remove(id);
    }

    long countByApp(MobileAppId appId) {
        return repo.countByApp(appId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
