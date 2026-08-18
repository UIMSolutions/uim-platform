/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.usecases.entitlements;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage service plan entitlements and quota assignments.
interface IManageEntitlementsUseCase {

  UsecaseResult assignEntitlement(AssignEntitlementRequest request);
  UsecaseResult updateEntitlementQuota(UpdateEntitlementQuotaRequest request);
  UsecaseResult revokeEntitlement(TenantId tenantId, EntitlementId id);
  Entitlement getEntitlement(TenantId tenantId, EntitlementId id);
  Entitlement[] listEntitlements(TenantId tenantId, GlobalAccountId gaId);
  Entitlement[] listEntitlements(TenantId tenantId, SubaccountId subId);
  Entitlement[] listEntitlements(TenantId tenantId, DirectoryId dirId);
  UsecaseResult deleteEntitlement(TenantId tenantId, EntitlementId id);

}
