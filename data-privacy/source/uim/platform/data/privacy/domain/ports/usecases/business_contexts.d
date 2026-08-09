/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.business_contexts;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageBusinessContextsUseCase { 

  CommandResult createContext(CreateBusinessContextRequest req);
  BusinessContext getContext(TenantId tenantId, BusinessContextId id);
  BusinessContext[] listContexts(TenantId tenantId);
  BusinessContext[] listByStatus(TenantId tenantId, BusinessContextStatus status);
  CommandResult updateContext(UpdateBusinessContextRequest req);
  CommandResult activateContext(ActivateBusinessContextRequest req);
  CommandResult deleteContext(TenantId tenantId, BusinessContextId id);
  
}
