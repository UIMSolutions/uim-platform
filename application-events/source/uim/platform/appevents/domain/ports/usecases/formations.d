/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.ports.usecases.formations;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

interface IManageFormationsUseCase {

    Formation getFormation(TenantId tenantId, FormationId id);
    Formation[] listFormations(TenantId tenantId);
    UsecaseResult createFormation(FormationDTO dto);
    UsecaseResult updateFormation(FormationDTO dto);
    UsecaseResult deleteFormation(TenantId tenantId, FormationId id);

}
