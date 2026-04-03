/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.push_template_repository;

import uim.platform.mobile.domain.entities.push_template;
import uim.platform.mobile.domain.types;

/// Port: outgoing — push template persistence.
interface PushTemplateRepository
{
  PushTemplate findById(PushTemplateId id);
  PushTemplate[] findByApp(MobileAppId appId);
  void save(PushTemplate template_);
  void update(PushTemplate template_);
  void remove(PushTemplateId id);
}
