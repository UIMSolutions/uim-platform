/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.usecases.retention_policies;
// import uim.platform.logging.domain.entities.retention_policy;
// import uim.platform.logging.domain.ports.repositories.retention_policys;
// import uim.platform.logging.domain.services.retention_evaluator;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface IManageRetentionPoliciesUseCase { 
  
  CommandResult createRetentionPolicy(CreateRetentionPolicyRequest req);

  CommandResult updateRetentionPolicy(UpdateRetentionPolicyRequest req);

  RetentionPolicy getRetentionPolicy(TenantId tenantId, RetentionPolicyId id);

  RetentionPolicy[] listRetentionPolicies(TenantId tenantId);

  CommandResult deleteRetentionPolicy(TenantId tenantId, RetentionPolicyId policyId);

}
