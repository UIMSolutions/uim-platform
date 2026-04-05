/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.page_templates;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.page_template;

interface PageTemplateRepository {
  PageTemplate[] findByTenant(TenantId tenantId);
  PageTemplate* findById(PageTemplateId id, TenantId tenantId);
  PageTemplate* findDefault(TenantId tenantId);
  PageTemplate[] findPublic();
  void save(PageTemplate template_);
  void update(PageTemplate template_);
  void remove(PageTemplateId id, TenantId tenantId);
}
