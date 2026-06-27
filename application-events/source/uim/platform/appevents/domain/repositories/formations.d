/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.repositories.formations;

import uim.platform.service;
import uim.platform.appevents.domain.entities.formation;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.formation_status;

@safe:

interface FormationRepository : ITentRepository!(Formation, FormationId) {
    Formation[] findByStatus(TenantId tenantId, FormationStatus status);
    Formation[] findByGlobalAccount(TenantId tenantId, string globalAccountId);
    bool nameExists(TenantId tenantId, string name);
}
