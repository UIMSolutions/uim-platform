/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.models;

// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.domain.entities.model : Model;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IModelRepository {
  bool existsById(ModelId id, ConnectionId connectionId);
  Model findById(ModelId id, ConnectionId connectionId);
  
  Model[] findByConnection(ConnectionId connectionId);
  Model[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId);
  Model[] findAll();

  void save(Model m);
  void remove(ModelId id, ConnectionId connectionId);
}
