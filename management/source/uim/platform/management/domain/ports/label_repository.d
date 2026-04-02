module domain.ports.label_repository;

import uim.platform.management.domain.entities.label;
import uim.platform.management.domain.types;

/// Port: outgoing — label/tag persistence.
interface LabelRepository
{
    Label findById(LabelId id);
    Label[] findByResource(LabeledResourceType resourceType, string resourceId);
    Label[] findByKey(LabeledResourceType resourceType, string key);
    Label[] findByKeyValue(LabeledResourceType resourceType, string key, string value);
    void save(Label lbl);
    void update(Label lbl);
    void remove(LabelId id);
    void removeByResource(LabeledResourceType resourceType, string resourceId);
}
