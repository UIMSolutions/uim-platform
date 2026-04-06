/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.processing_purposes;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface ProcessingPurposeRepository {
    ProcessingPurpose findById(ProcessingPurposeId id);
    ProcessingPurpose[] findByTenant(TenantId tenantId);
    ProcessingPurpose[] findByLegalBasis(LegalBasis basis);
    ProcessingPurpose[] findByApplication(RegisteredApplicationId applicationId);
    void save(ProcessingPurpose entity);
    void update(ProcessingPurpose entity);
    void remove(ProcessingPurposeId id);
}
