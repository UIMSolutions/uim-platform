/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.providers;

import uim.platform.portal.domain.entities.content_provider;
import uim.platform.portal.domain.types;

/// Port: outgoing — content provider persistence.
interface ProviderRepository {
  ContentProvider findById(ProviderId id);
  ContentProvider[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
  void save(ContentProvider provider);
  void update(ContentProvider provider);
  void remove(ProviderId id);
}
