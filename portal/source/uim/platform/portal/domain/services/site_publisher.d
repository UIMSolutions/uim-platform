module uim.platform.xyz.domain.services.site_publisher;

import domain.entities.site;
import domain.types;

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
