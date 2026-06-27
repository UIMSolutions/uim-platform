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
    bool existsTenant(TenantId tenantId);

    size_t countByTenant(TenantId tenantId);
    TEntity[] findByTenant(TenantId tenantId); // TODO, #4 size_t offset = 0, size_t limit = 100);
    void removeByTenant(TenantId tenantId);

    bool existsById(TenantId tenantId, TId id);
    TEntity findById(TenantId tenantId, TId id);

    void saveById(TenantId tenantId, TId id);
    void updateById(TenantId tenantId, TId id);
    void removeById(TenantId tenantId, TId id);

}
