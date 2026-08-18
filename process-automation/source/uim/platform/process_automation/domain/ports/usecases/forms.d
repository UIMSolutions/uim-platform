/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.usecases.forms;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface IManageFormsUseCase { 

    UsecaseResult createForm(CreateFormRequest r);
    Form getForm(TenantId tenantId, FormId id);
    Form[] listForms(TenantId tenantId);
    UsecaseResult updateForm(UpdateFormRequest r);
    UsecaseResult deleteForm(TenantId tenantId, FormId id);

}
