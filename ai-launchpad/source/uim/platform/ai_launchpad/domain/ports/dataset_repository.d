/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.dataset_repository;

import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.domain.entities.dataset : Dataset;

interface IDatasetRepository {
  void save(Dataset d);
  Dataset findById(DatasetId id, ConnectionId connectionId);
  Dataset[] findByConnection(ConnectionId connectionId);
  Dataset[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId);
  Dataset[] findAll();
  void remove(DatasetId id, ConnectionId connectionId);
}
