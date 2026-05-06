/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.deployments;

// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.domain.entities.deployment : Deployment;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IDeploymentRepository {
  bool existsById(ConnectionId connectionId, DeploymentId id);
  Deployment findById(ConnectionId connectionId, DeploymentId id);
  
  Deployment[] findByConnection(ConnectionId connectionId);
  Deployment[] findByScenario(ConnectionId connectionId, ScenarioId scenarioId);
  Deployment[] findByStatus(ConnectionId connectionId, DeploymentStatus status);
  Deployment[] findAll();

  void save(Deployment d);
  void remove(ConnectionId connectionId, DeploymentId id);
}
