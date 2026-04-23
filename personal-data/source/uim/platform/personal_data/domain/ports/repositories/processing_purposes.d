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

    size_t countByLegalBasis(LegalBasis basis);
    ProcessingPurpose[] findByLegalBasis(LegalBasis basis);
    void removeByLegalBasis(LegalBasis basis);

    size_t countByApplication(RegisteredApplicationId applicationId);
    ProcessingPurpose[] findByApplication(RegisteredApplicationId applicationId);
    void removeByApplication(RegisteredApplicationId applicationId);
    
}
