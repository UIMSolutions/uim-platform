/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.data_entities;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface DataEntityRepository : ITenantRepository!(DataEntity, DataEntityId) {

    size_t countByApplication(ApplicationId applicationId);
    DataEntity[] findByApplication(ApplicationId applicationId);
    void removeByApplication(ApplicationId applicationId);

}
