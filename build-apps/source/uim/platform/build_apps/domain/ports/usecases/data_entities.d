/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.ports.usecases.data_entities;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface IManageDataEntitiesUseCase { 
    
    DataEntity getDataEntity(TenantId tenantId, DataEntityId id);
    DataEntity[] listDataEntities(TenantId tenantId);
    DataEntity[] listDataEntities(TenantId tenantId, ApplicationId applicationId);
    CommandResult createDataEntity(DataEntityDTO dto);
    CommandResult updateDataEntity(DataEntityDTO dto);
    CommandResult deleteDataEntity(TenantId tenantId, DataEntityId id);
    
}
