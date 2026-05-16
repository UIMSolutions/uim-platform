/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.offline_stores;
// import uim.platform.mobile.domain.ports.repositories.offline_stores;
// import uim.platform.mobile.domain.entities.offline_store;
// import uim.platform.mobile.domain.types;
// import uim.platform.mobile.domain.services.offline_sync_service;
// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

mixin(Showmodule!());

@safe:
class ManageOfflineStoresUseCase { // TODO: UIMUseCase {
    private OfflineStoreRepository repo;

    this(OfflineStoreRepository repo) {
        this.repo = repo;
    }

    CommandResult createOfflineStore(CreateOfflineStoreRequest r) {
        if (!OfflineSyncService.validateStoreName(r.name))
            return CommandResult(false, "", "Invalid store name");
        OfflineStore store;
        store.initEntity(r.tenantId, r.createdBy);

        store.appId = r.appId;
        store.name = r.name;
        store.description = r.description;
        store.storeType = r.storeType;
        store.encryptionEnabled = r.encryptionEnabled;
        store.maxSizeMb = r.maxSizeMb;
        store.syncPolicy = r.syncPolicy;
        store.conflictPolicy = r.conflictPolicy;
        store.status = OfflineStoreStatus.active;

        repo.save(store);
        return CommandResult(true, store.id.value, "");
    }

    CommandResult updateOfflineStore(UpdateOfflineStoreRequest r) {
        auto store = repo.findById(r.tenantId, r.id);
        if (store.isNull)
            return CommandResult(false, "", "Offline store not found");
        if (r.description.length > 0) store.description = r.description;
        if (r.syncPolicy.length > 0) store.syncPolicy = r.syncPolicy;
        if (r.conflictPolicy.length > 0) store.conflictPolicy = r.conflictPolicy;
        if (r.maxSizeMb > 0) store.maxSizeMb = r.maxSizeMb;
        store.encryptionEnabled = r.encryptionEnabled;
        store.updatedAt = currentTimestamp();
        store.updatedBy = r.updatedBy;
        repo.update(store);
        return CommandResult(true, store.id.value, "");
    }

    OfflineStore getOfflineStore(OfflineStoreId id) {
        return repo.findById(tenantId, id);
    }

    OfflineStore[] listOfflineStoresByApp(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    CommandResult deleteOfflineStore(TenantId tenantId, OfflineStoreId id) {
        auto store = repo.findById(tenantId, id);
        if (store.isNull)
            return CommandResult(false, "", "Offline store not found");
            
        repo.remove(store);
        return CommandResult(true, store.id.value, "");
    }

    size_t countOfflineStoresByApp(TenantId tenantId, MobileAppId appId) {
        return repo.countByApp(tenantId, appId);
    }

}
