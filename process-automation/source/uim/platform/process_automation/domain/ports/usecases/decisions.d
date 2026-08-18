/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.usecases.decisions;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface IManageDecisionsUseCase { 

    UsecaseResult createDecision(CreateDecisionRequest r);
    Decision getDecision(TenantId tenantId, DecisionId id);
    Decision[] listDecisions(TenantId tenantId);
    UsecaseResult updateDecision(UpdateDecisionRequest r);
    UsecaseResult deleteDecision(TenantId tenantId, DecisionId id);

}

