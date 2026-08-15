module uim.platform.architecture.presentation.web.controllers.logout;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:
void handleLogout(HTTPServerRequest req, HTTPServerResponse res) {
    if (req.session) {
        logInfo("User '%s' logged out.", req.session.get!string("username", "unknown"));
        res.terminateSession();
    }
    res.redirect("/web/login");
}
