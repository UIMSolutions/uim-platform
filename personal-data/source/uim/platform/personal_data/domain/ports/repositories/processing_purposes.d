/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.processing_purposes;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface ProcessingPurposeRepository : ITenantRepository!(ProcessingPurpose, ProcessingPurposeId) {

    size_t countByLegalBasis(TenantId tenantId, LegalBasis basis);
    ProcessingPurpose[] findByLegalBasis(TenantId tenantId, LegalBasis basis);
    void removeByLegalBasis(TenantId tenantId, LegalBasis basis);

    size_t countByApplication(TenantId tenantId, RegisteredApplicationId applicationId);
    ProcessingPurpose[] findByApplication(TenantId tenantId, RegisteredApplicationId applicationId);
    void removeByApplication(TenantId tenantId, RegisteredApplicationId applicationId);
    
}
