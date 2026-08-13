/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.offline_stores;
// import uim.platform.mobile.domain.ports.repositories.offline_stores;
// import uim.platform.mobile.domain.entities.offline_store;

// import uim.platform.mobile.domain.services.offline_sync_service;
// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface IManageOfflineStoresUseCase { 
    
    CommandResult createOfflineStore(CreateOfflineStoreRequest r);

    CommandResult updateOfflineStore(UpdateOfflineStoreRequest r);

    OfflineStore getOfflineStore(TenantId tenantId, OfflineStoreId id);

    OfflineStore[] listOfflineStores(TenantId tenantId);

    OfflineStore[] listOfflineStores(TenantId tenantId, MobileAppId appId);

    CommandResult deleteOfflineStore(TenantId tenantId, OfflineStoreId id);

    size_t countOfflineStoresByApp(TenantId tenantId, MobileAppId appId);

}
