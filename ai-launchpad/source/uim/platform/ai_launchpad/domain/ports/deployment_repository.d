/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.deployments;

import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.domain.entities.deployment : Deployment;

interface IDeploymentRepository {
  void save(Deployment d);
  Deployment findById(DeploymentId id, ConnectionId connectionId);
  Deployment[] findByConnection(ConnectionId connectionId);
  Deployment[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId);
  Deployment[] findByStatus(DeploymentStatus status, ConnectionId connectionId);
  Deployment[] findAll();
  void remove(DeploymentId id, ConnectionId connectionId);
}
