/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.configurations;

import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.domain.entities.configuration : Configuration;

interface IConfigurationRepository {
  bool existsById(ConfigurationId id, ConnectionId connectionId);
  Configuration findById(ConfigurationId id, ConnectionId connectionId);

  Configuration[] findByConnection(ConnectionId connectionId);
  Configuration[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId);
  Configuration[] findAll();

  void save(Configuration c);
  void remove(ConfigurationId id, ConnectionId connectionId);
}
