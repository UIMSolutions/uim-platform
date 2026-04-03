/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.services.site_publisher;

import uim.platform.portal.domain.entities.site;
import uim.platform.portal.domain.types;

/// Domain service: validates whether a site is ready for publishing.
struct PublishValidationResult
{
  bool valid;
  string[] errors;
}

PublishValidationResult validateForPublish(const ref Site site)
{
  string[] errors;

  if (site.name.length == 0)
    errors ~= "Site must have a name";
  if (site.pageIds.length == 0)
    errors ~= "Site must have at least one page";
  if (site.status == SiteStatus.archived)
    errors ~= "Cannot publish an archived site";

  return PublishValidationResult(errors.length == 0, errors);
}
