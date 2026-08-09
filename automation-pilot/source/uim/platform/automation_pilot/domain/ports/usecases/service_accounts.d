/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.ports.usecases.service_accounts;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface IManageServiceAccountsUseCase { 
    
    ServiceAccount getServiceAccount(TenantId tenantId, ServiceAccountId id);
    ServiceAccount[] listServiceAccounts(TenantId tenantId);
    CommandResult createServiceAccount(ServiceAccountDTO dto);
    CommandResult updateServiceAccount(ServiceAccountDTO dto);
    CommandResult deleteServiceAccount(TenantId tenantId, ServiceAccountId id);

}
