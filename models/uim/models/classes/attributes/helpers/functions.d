module uim.models.classes.attributes.helpers.functions;

mixin(Version!"test_uim_models");

import uim.models;
@safe:

bool isAttribute(Object obj) {
  if (obj is null) {
    return false;
  }
  return cast(IAttribute)obj !is null;
}