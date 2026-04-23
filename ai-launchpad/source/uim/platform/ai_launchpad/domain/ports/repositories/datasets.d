/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.datasets;

// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.domain.entities.dataset : Dataset;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IDatasetRepository {
  bool existsById(DatasetId id, ConnectionId connectionId);
  Dataset findById(DatasetId id, ConnectionId connectionId);
  
  Dataset[] findByConnection(ConnectionId connectionId);
  Dataset[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId);
  Dataset[] findAll();

  void save(Dataset d);
  void remove(DatasetId id, ConnectionId connectionId);
}
