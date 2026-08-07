/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.usecases.get_account_overview;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: generate a dashboard overview for a global account.
interface IGetAccountOverviewUseCase { 

  AccountOverview getOverview(TenantId tenantId, GlobalAccountId globalAccountId);

}
