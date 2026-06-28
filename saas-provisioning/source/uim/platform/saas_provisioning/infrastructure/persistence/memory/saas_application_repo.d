/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.infrastructure.persistence.memory.saas_application_repo;

import uim.platform.saas_provisioning;

// mixin(ShowModule!());

@safe:

/// In-memory implementation of SaasApplicationRepository.
class MemorySaasApplicationRepository
    : TenantRepository!(SaasApplication, SaasApplicationId),
      SaasApplicationRepository
{
    SaasApplication findByAppName(TenantId tenantId, string appName) {
        foreach (app; find(tenantId)) {
            if (app.appName == appName) return app;
        }
        return new SaasApplication();
    }
}
