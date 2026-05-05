/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.processing_purposes;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryProcessingPurposeRepository : TenantRepository!(ProcessingPurpose, ProcessingPurposeId), ProcessingPurposeRepository {

    size_t countByLegalBasis(LegalBasis basis) {
        return findByLegalBasis(basis).length;
    }
    ProcessingPurpose[] filterByLegalBasis(ProcessingPurpose[] purposes, LegalBasis basis, size_t offset = 0, size_t limit = 0) {
        return (limit == 0)
            ? purposes.filter!(v => v.legalBasis == basis).skip(offset).array
            : purposes.filter!(v => v.legalBasis == basis).skip(offset).take(limit).array;
    }
    ProcessingPurpose[] findByLegalBasis(LegalBasis basis) {
        return findAll.filter!(v => v.legalBasis == basis).array;
    }
    void removeByLegalBasis(LegalBasis basis) {
        findByLegalBasis(basis).each!(v => remove(v.id));
    }

    size_t countByApplication(RegisteredApplicationId applicationId) {
        return findByApplication(applicationId).length;
    }
    ProcessingPurpose[] filterByApplication(ProcessingPurpose[] purposes, RegisteredApplicationId applicationId, size_t offset = 0, size_t limit = 0) {
        return (limit == 0)
            ? purposes.filter!(v => v.applicationIds.canFind(applicationId)).skip(offset).array
            : purposes.filter!(v => v.applicationIds.canFind(applicationId)).skip(offset).take(limit).array;
    }
    ProcessingPurpose[] findByApplication(RegisteredApplicationId applicationId) {
        return findAll.filter!(v => v.applicationIds.canFind(applicationId)).array;
    }
    void removeByApplication(RegisteredApplicationId applicationId) {
        findByApplication(applicationId).each!(v => remove(v.id));
    }

}
