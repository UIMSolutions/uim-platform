/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.environment_instance;

import uim.platform.management.domain.entities.environment_instance;
import uim.platform.management.domain.types;

/// Port: outgoing — environment instance persistence.
interface EnvironmentInstanceRepository {
  EnvironmentInstance findById(EnvironmentInstanceId id);
  EnvironmentInstance[] findBySubaccount(SubaccountId subaccountId);
  EnvironmentInstance[] findByType(SubaccountId subaccountId, EnvironmentType envType);
  EnvironmentInstance[] findByStatus(SubaccountId subaccountId, EnvironmentStatus status);
  void save(EnvironmentInstance inst);
  void update(EnvironmentInstance inst);
  void remove(EnvironmentInstanceId id);
}
