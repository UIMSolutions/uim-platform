/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.global_account_repository;

import uim.platform.management.domain.entities.global_account;
import uim.platform.management.domain.types;

/// Port: outgoing — global account persistence.
interface GlobalAccountRepository
{
  GlobalAccount findById(GlobalAccountId id);
  GlobalAccount[] findByStatus(GlobalAccountStatus status);
  GlobalAccount[] findAll();
  void save(GlobalAccount account);
  void update(GlobalAccount account);
  void remove(GlobalAccountId id);
}
