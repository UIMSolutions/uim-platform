/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.ports.usecases.legal_entities;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageLegalEntitiesUseCase { 
    
    CommandResult createLegalEntity(CreateLegalEntityRequest req);
    CommandResult updateLegalEntity(TenantId tenantId, LegalEntityId id, UpdateLegalEntityRequest req);
    bool hasLegalEntity(TenantId tenantId, LegalEntityId id);
    LegalEntity getLegalEntity(TenantId tenantId, LegalEntityId id);
    LegalEntity[] listLegalEntities(TenantId tenantId);
    CommandResult deleteLegalEntity(TenantId tenantId, LegalEntityId id);

}
