/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.repositories.data_entities;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryDataEntityRepository : TenantRepository!(DataEntity, DataEntityId), DataEntityRepository {

    size_t countByApplication(TenantId tenantId, ApplicationId applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }

    DataEntity[] filterByApplication(DataEntity[] entities, ApplicationId applicationId) {
        return entities.filter!(e => e.applicationId == applicationId).array;
    }
    DataEntity[] findByApplication(TenantId tenantId, ApplicationId applicationId) {
        return filterByApplication(findByTenant(tenantId), applicationId);
    }

    void removeByApplication(TenantId tenantId, ApplicationId applicationId) {
        findByApplication(tenantId, applicationId).each!(e => remove(e));
    }

}
