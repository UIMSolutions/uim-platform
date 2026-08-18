/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.ports.usecases.conditions;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

interface IManageConditionsUseCase {

  UsecaseResult createCondition(CreateConditionRequest r);

  UsecaseResult updateCondition(UpdateConditionRequest r);

  Condition getCondition(TenantId tenantId, ConditionId id);

  Condition[] listConditions(TenantId tenantId);

  Condition[] listByPatient(TenantId tenantId, string patientRef);

  UsecaseResult deleteCondition(TenantId tenantId, ConditionId id);
  
}
