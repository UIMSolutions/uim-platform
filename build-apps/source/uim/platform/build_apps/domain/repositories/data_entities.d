/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.data_entities;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface DataEntityRepository {
    bool existsById(DataEntityId id);
    DataEntity findById(DataEntityId id);

    DataEntity[] findAll();
    DataEntity[] findByTenant(TenantId tenantId);
    DataEntity[] findByApplication(ApplicationId applicationId);

    void save(DataEntity entity);
    void update(DataEntity entity);
    void remove(DataEntityId id);
}
