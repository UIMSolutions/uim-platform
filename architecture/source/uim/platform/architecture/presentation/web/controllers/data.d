module uim.platform.architecture.presentation.web.controllers.data;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:
void handleData(HTTPServerRequest req, HTTPServerResponse res) {
    if (!req.session || !req.session.get!bool("isLoggedIn", false)) {
        res.redirect("/web/login");
        return;
    }

    string username = req.session.get!string("username", "User");
    string lang = req.session.get!string("lang", "de");
    string lang2 = req.query.get("lang", "en");
    if (lang != lang2) {
        req.session.set("lang", lang2);
        lang = lang2;
    }
    auto translations = getTranslations(lang);


    res.render!("data.dt", username, lang, translations);
}