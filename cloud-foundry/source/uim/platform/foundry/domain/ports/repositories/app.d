/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.app;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.application;

/// Port for persisting and querying applications.
interface IAppRepository {
  Application[] findBySpace(SpaceId spacetenantId, id tenantId);
  Application* findById(AppId tenantId, id tenantId);
  Application* findByName(SpaceId spacetenantId, id tenantId, string name);
  Application[] findByState(SpaceId spacetenantId, id tenantId, AppState state);
  Application[] findByTenant(TenantId tenantId);
  long countBySpace(SpaceId spacetenantId, id tenantId);
  void save(Application app);
  void update(Application app);
  void remove(AppId tenantId, id tenantId);
}
