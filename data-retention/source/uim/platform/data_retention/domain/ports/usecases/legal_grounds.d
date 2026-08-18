/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.ports.usecases.legal_grounds;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageLegalGroundsUseCase { 
    
    UsecaseResult createLegalGround(CreateLegalGroundRequest req);
    UsecaseResult createLegalGround(CreateLegalGroundRequest req);
    UsecaseResult updateLegalGround(UpdateLegalGroundRequest req);
    bool hasLegalGround(TenantId tenantId, LegalGroundId id);
    LegalGround getLegalGround(TenantId tenantId, LegalGroundId id);
    LegalGround[] listLegalGrounds(TenantId tenantId);
    UsecaseResult deleteLegalGround(TenantId tenantId, LegalGroundId id);

}
