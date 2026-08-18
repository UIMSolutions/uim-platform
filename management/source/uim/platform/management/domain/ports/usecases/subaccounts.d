/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.usecases.subaccounts;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage subaccount lifecycle within global accounts.
interface IManageSubaccountsUseCase { 

  UsecaseResult createSubaccount(CreateSubaccountRequest req);
  UsecaseResult updateSubaccount(UpdateSubaccountRequest req);
  UsecaseResult moveSubaccount(TenantId tenantId, SubaccountId id, MoveSubaccountRequest req);
  UsecaseResult suspendSubaccount(TenantId tenantId, SubaccountId id);
  UsecaseResult reactivateSubaccount(TenantId tenantId, SubaccountId id);
  Subaccount getSubaccount(TenantId tenantId, SubaccountId id);
  Subaccount[] listSubaccounts(TenantId tenantId, GlobalAccountId gaId);
  Subaccount[] listSubaccounts(TenantId tenantId, DirectoryId dirId);
  Subaccount[] listSubaccounts(TenantId tenantId, GlobalAccountId gaId, string region);
  UsecaseResult deleteSubaccount(TenantId tenantId, SubaccountId id);

}
