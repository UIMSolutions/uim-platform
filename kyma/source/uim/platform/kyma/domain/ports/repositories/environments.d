/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.environments;

import uim.platform.kyma.domain.entities.kyma_environment;
import uim.platform.kyma.domain.types;

/// Port: outgoing — Kyma environment persistence.
interface EnvironmentRepository {
  KymaEnvironment findById(KymaEnvironmentId id);
  KymaEnvironment[] findByTenant(TenantId tenantId);
  KymaEnvironment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  KymaEnvironment[] findByStatus(EnvironmentStatus status);
  void save(KymaEnvironment env);
  void update(KymaEnvironment env);
  void remove(KymaEnvironmentId id);
}
