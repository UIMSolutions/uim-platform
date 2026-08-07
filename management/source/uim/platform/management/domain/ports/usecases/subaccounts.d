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

  CommandResult createSubaccount(CreateSubaccountRequest req);
  CommandResult updateSubaccount(UpdateSubaccountRequest req);
  CommandResult moveSubaccount(TenantId tenantId, SubaccountId id, MoveSubaccountRequest req);
  CommandResult suspendSubaccount(TenantId tenantId, SubaccountId id);
  CommandResult reactivateSubaccount(TenantId tenantId, SubaccountId id);
  Subaccount getSubaccount(TenantId tenantId, SubaccountId id);
  Subaccount[] listSubaccounts(TenantId tenantId, GlobalAccountId gaId);
  Subaccount[] listSubaccounts(TenantId tenantId, DirectoryId dirId);
  Subaccount[] listSubaccounts(TenantId tenantId, GlobalAccountId gaId, string region);
  CommandResult deleteSubaccount(TenantId tenantId, SubaccountId id);

}
