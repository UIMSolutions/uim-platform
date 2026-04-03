module uim.platform.xyz.domain.ports.push_template_repository;

import domain.entities.push_template;
import domain.types;

/// Port: outgoing — push template persistence.
interface PushTemplateRepository
{
    PushTemplate findById(PushTemplateId id);
    PushTemplate[] findByApp(MobileAppId appId);
    void save(PushTemplate template_);
    void update(PushTemplate template_);
    void remove(PushTemplateId id);
}
