module uim.models.classes.attributes.helpers.functions;

import uim.models;

mixin(Version!"test_uim_models");

@safe:

bool isAttribute(Object obj) {
  if (obj is null) {
    return false;
  }
  return cast(IAttribute)obj !is null;
}