/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.content_providers;

import uim.platform.content_agent.domain.entities.content_provider;
import uim.platform.content_agent.domain.types;

/// Port: outgoing - content provider persistence.
interface ContentProviderRepository {
  ContentProvider findById(ContentProviderId id);
  ContentProvider[] findByTenant(TenantId tenantId);
  ContentProvider findByName(TenantId tenantId, string name);
  ContentProvider[] findByStatus(TenantId tenantId, ProviderStatus status);
  void save(ContentProvider provider);
  void update(ContentProvider provider);
  void remove(ContentProviderId id);
}
