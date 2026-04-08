/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.ports.repositories.software_components;

import uim.platform.abap_enviroment.domain.entities.software_component;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - software component persistence.
interface SoftwareComponentRepository {

  bool existsById(SoftwareComponentId id);
  SoftwareComponent findById(SoftwareComponentId id);

  bool existsName(SystemInstanceId systemId, string name);
  SoftwareComponent findByName(SystemInstanceId systemId, string name);

  SoftwareComponent[] findBySystem(SystemInstanceId systemId);
  SoftwareComponent[] findByTenant(TenantId tenantId);

  void save(SoftwareComponent component);
  void update(SoftwareComponent component);
  void remove(SoftwareComponentId id);
}
