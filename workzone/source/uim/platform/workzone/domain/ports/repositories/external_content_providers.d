/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.external_content_providers;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.external_content_provider;

interface ExternalContentProviderRepository : ITenantRepository!(ExternalContentProvider, ExternalContentProviderId) {

  size_t countByStatus(TenantId tenantId, ProviderStatus status);
  ExternalContentProvider[] findByStatus(TenantId tenantId, ProviderStatus status);
  void removeByStatus(TenantId tenantId, ProviderStatus status);

}
