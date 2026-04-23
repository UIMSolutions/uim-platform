/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.software_components;

// import uim.platform.abap_environment.domain.entities.software_component;
// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Port: outgoing - software component persistence.
interface SoftwareComponentRepository : ITenantRepository!(SoftwareComponent, SoftwareComponentId) {

  bool existsName(SystemInstanceId systemId, string name);
  SoftwareComponent findByName(SystemInstanceId systemId, string name);
  void removeByName(SystemInstanceId systemId, string name);

  size_t countBySystem(SystemInstanceId systemId);
  SoftwareComponent[] findBySystem(SystemInstanceId systemId);
  void removeBySystem(SystemInstanceId systemId);

}
