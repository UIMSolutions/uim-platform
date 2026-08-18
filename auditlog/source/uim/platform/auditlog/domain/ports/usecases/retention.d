/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.ports.usecases.retention;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

interface IManageRetentionUseCase { 

  UsecaseResult createPolicy(CreateRetentionPolicyRequest req);
  bool existsPolicy(TenantId tenantId, RetentionPolicyId policyId);
  RetentionPolicy getPolicy(TenantId tenantId, RetentionPolicyId policyId);
  RetentionPolicy[] listPolicies(TenantId tenantId);
  UsecaseResult updatePolicy(UpdateRetentionPolicyRequest req);
  UsecaseResult deletePolicy(TenantId tenantId, RetentionPolicyId policyId);

}
