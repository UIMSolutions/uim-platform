/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.usecases.overview;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
interface IGetOverviewUseCase { 

  OverviewSummary getSummary(TenantId tenantId);

}
