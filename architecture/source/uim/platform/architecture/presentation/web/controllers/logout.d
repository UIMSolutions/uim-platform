/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
