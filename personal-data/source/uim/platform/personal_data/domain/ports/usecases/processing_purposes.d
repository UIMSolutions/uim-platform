/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.usecases.processing_purposes;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface IManageProcessingPurposesUseCase { 

    UsecaseResult createProcessingPurpose(CreateProcessingPurposeRequest r);
    ProcessingPurpose getProcessingPurpose(TenantId tenantId, ProcessingPurposeId id);
    ProcessingPurpose[] listProcessingPurposes(TenantId tenantId);
    UsecaseResult updateProcessingPurpose(UpdateProcessingPurposeRequest r);
    UsecaseResult deleteProcessingPurpose(TenantId tenantId, ProcessingPurposeId id);

}
