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
