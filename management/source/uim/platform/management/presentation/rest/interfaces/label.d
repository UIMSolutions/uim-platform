module uim.platform.management.presentation.rest.interfaces.label;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface ILabelApi {
    // GET /rest/v1/labels
    Label[] getLabels();

    // GET /rest/v1/labels/:id
    Label getLabel(string id);
}