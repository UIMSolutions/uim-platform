/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.domain.ports.repositories.saas_applications;

import uim.platform.saas_provisioning;

// mixin(ShowModule!());

@safe:

/// Port: persistence contract for the SaasApplication aggregate root.
interface SaasApplicationRepository : ITenantRepository!(SaasApplication, SaasApplicationId) {
    /// Find an application by its unique technical name within a provider tenant.
    SaasApplication findByAppName(TenantId tenantId, string appName);
}
