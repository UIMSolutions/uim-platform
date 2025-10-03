module uim.models.classes.attributes.builder;

mixin(Version!"test_uim_models");

import uim.models;
@safe:
static class DAttributeBuilder {
    // TODO
    public DAttribute build() {
        return new DAttribute(this);
    }
}
