/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.consent_purposes;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageConsentPurposesUseCase { 
  
  UsecaseResult createPurpose(CreateConsentPurposeRequest req);
  ConsentPurpose getPurpose(TenantId tenantId, ConsentPurposeId id);
  ConsentPurpose[] listPurposes(TenantId tenantId);
  ConsentPurpose[] listByController(TenantId tenantId, DataControllerId controllerId);
  UsecaseResult updatePurpose(UpdateConsentPurposeRequest req);
  UsecaseResult deletePurpose(TenantId tenantId, ConsentPurposeId id);
  
}
