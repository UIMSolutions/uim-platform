/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.architecture.infrastructure.persistence.repositories.technology_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class TechnologyBlockRepository : TenantRepository!(TechnologyBlock, TechnologyBlockId), ITechnologyBlockRepository {
     
    size_t countByStatus(TenantId tenantId, LifecycleStatus status) {
        return findByStatus(tenantId, status).length;
    }

    TechnologyBlock[] filterByStatus(TechnologyBlock[] blocks, LifecycleStatus status) {
        return blocks.filter!(block => block.status == status).array;
    }

    TechnologyBlock[] findByStatus(TenantId tenantId, LifecycleStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, LifecycleStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    
}
