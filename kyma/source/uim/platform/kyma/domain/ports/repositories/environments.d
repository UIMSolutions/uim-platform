/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.environments;

// import uim.platform.kyma.domain.entities.kyma_environment;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Port: outgoing — Kyma environment persistence.
interface EnvironmentRepository : ITenantRepository!(KymaEnvironment, KymaEnvironmentId) {

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  KymaEnvironment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId);

  size_t countByStatus(EnvironmentStatus status);
  KymaEnvironment[] findByStatus(EnvironmentStatus status);
  void removeByStatus(EnvironmentStatus status);
  
}
