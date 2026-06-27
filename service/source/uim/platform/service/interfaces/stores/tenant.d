/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.interfaces.stores.tenant;

import uim.platform.service;

// mixin(ShowModule!());

@safe:
interface ITenantStore(TEntity, TId) : IEntityStore!(TEntity) {
    bool exists(TenantId tenantId);

    size_t countAll(TenantId tenantId);
    bool isEmpty(TenantId tenantId);
    TEntity[] findAll(TenantId tenantId); // TODO, #4 size_t offset = 0, size_t limit = 100);
    void removeAll(TenantId tenantId);

    bool existsId(TenantId tenantId, TId id);
    TEntity findId(TenantId tenantId, TId id);

    void saveId(TenantId tenantId, TId id);
    void updateId(TenantId tenantId, TId id);
    void removeId(TenantId tenantId, TId id);

}
