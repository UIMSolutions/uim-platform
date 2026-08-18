/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.usecases.global_accounts;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage global account lifecycle.
interface IManageGlobalAccountsUseCase { 

  UsecaseResult createAccount(CreateGlobalAccountRequest req);
  UsecaseResult updateAccount(UpdateGlobalAccountRequest req);
  UsecaseResult suspendAccount(TenantId tenantId, GlobalAccountId accountId);
  UsecaseResult reactivateAccount(TenantId tenantId,  GlobalAccountId accountId);
  bool existsAccount(TenantId tenantId, GlobalAccountId accountId);
  GlobalAccount getAccount(TenantId tenantId, GlobalAccountId accountId);
  GlobalAccount[] listAccounts(TenantId tenantId);
  GlobalAccount[] listAccounts(TenantId tenantId, string status);
  UsecaseResult deleteAccount(TenantId tenantId, GlobalAccountId accountId);

}
