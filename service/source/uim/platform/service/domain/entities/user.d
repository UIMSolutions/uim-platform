module uim.platform.service.domain.entities.user;

import uim.platform.service;
mixin(ShowModule!());

@safe:
struct User {
    mixin TenantEntity!UserId;

    string userName; // Unique login name
    string email;
    string displayName;
    string firstName;
    string lastName;
}
