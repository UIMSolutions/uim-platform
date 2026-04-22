/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.applications;

// import uim.platform.kyma.domain.entities.application;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Port: outgoing — external application connectivity persistence.
interface ApplicationRepository : ITenantRepository!(Application, ApplicationId) {

  bool existsByName(KymaEnvironmentId envId, string name);
  Application findByName(KymaEnvironmentId envId, string name);
  void removeByName(KymaEnvironmentId envId, string name);

  size_t countByEnvironment(KymaEnvironmentId envId);
  Application[] findByEnvironment(KymaEnvironmentId envId);
  void removeByEnvironment(KymaEnvironmentId envId);

  size_t countByStatus(AppConnectivityStatus status);
  Application[] findByStatus(AppConnectivityStatus status);
  void removeByStatus(AppConnectivityStatus status);

}
