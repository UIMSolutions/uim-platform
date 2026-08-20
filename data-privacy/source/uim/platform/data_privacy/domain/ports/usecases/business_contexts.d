/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.business_contexts;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageBusinessContextsUseCase { 

  UsecaseResult createContext(CreateBusinessContextRequest req);
  BusinessContext getContext(TenantId tenantId, BusinessContextId id);
  BusinessContext[] listContexts(TenantId tenantId);
  BusinessContext[] listByStatus(TenantId tenantId, BusinessContextStatus status);
  UsecaseResult updateContext(UpdateBusinessContextRequest req);
  UsecaseResult activateContext(ActivateBusinessContextRequest req);
  UsecaseResult deleteContext(TenantId tenantId, BusinessContextId id);
  
}
