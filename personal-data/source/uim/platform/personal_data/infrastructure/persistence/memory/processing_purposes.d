/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.processing_purposes;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

class MemoryProcessingPurposeRepository : TenantRepository!(ProcessingPurpose, ProcessingPurposeId), ProcessingPurposeRepository {

    size_t countByLegalBasis(TenantId tenantId, LegalBasis basis) {
        return findByLegalBasis(tenantId, basis).length;
    }
    ProcessingPurpose[] filterByLegalBasis(ProcessingPurpose[] purposes, LegalBasis basis) {
        return purposes.filter!(v => v.legalBasis == basis).array;
    }
    ProcessingPurpose[] findByLegalBasis(TenantId tenantId, LegalBasis basis) {
        return filterByLegalBasis(find(tenantId), basis);
    }
    void removeByLegalBasis(TenantId tenantId, LegalBasis basis) {
        findByLegalBasis(tenantId, basis).each!(v => remove(v.id));
    }

    size_t countByApplication(TenantId tenantId, RegisteredApplicationId applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }
    ProcessingPurpose[] filterByApplication(ProcessingPurpose[] purposes, RegisteredApplicationId applicationId) {
        return purposes.filter!(v => v.applicationIds.canFind(applicationId)).array;
    }
    ProcessingPurpose[] findByApplication(TenantId tenantId, RegisteredApplicationId applicationId) {
        return filterByApplication(find(tenantId), applicationId);
    }
    void removeByApplication(TenantId tenantId, RegisteredApplicationId applicationId) {
        findByApplication(applicationId).each!(v => remove(v.id));
    }

}
