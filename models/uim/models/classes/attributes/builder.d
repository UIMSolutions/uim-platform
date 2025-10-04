module uim.models.classes.attributes.builder;

import uim.models;
mixin(Version!"test_uim_models");

@safe:
static class DAttributeBuilder {
    // TODO
    public DAttribute build() {
        return new DAttribute(this);
    }
}
