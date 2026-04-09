/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.external_content_providers;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.external_content_provider;

interface ExternalContentProviderRepository {
  ExternalContentProvider[] findByTenant(TenantId tenantId);
  ExternalContentProvider* findById(ExternalContentProviderId tenantId, id tenantId);
  ExternalContentProvider[] findByStatus(ProviderStatus status, TenantId tenantId);
  void save(ExternalContentProvider provider);
  void update(ExternalContentProvider provider);
  void remove(ExternalContentProviderId tenantId, id tenantId);
}
