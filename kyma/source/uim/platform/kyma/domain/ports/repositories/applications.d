/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.applications;

import uim.platform.kyma.domain.entities.application;
import uim.platform.kyma.domain.types;

/// Port: outgoing — external application connectivity persistence.
interface ApplicationRepository
{
  Application findById(ApplicationId id);
  Application findByName(KymaEnvironmentId envId, string name);
  Application[] findByEnvironment(KymaEnvironmentId envId);
  Application[] findByStatus(AppConnectivityStatus status);
  Application[] findByTenant(TenantId tenantId);
  void save(Application app);
  void update(Application app);
  void remove(ApplicationId id);
}
