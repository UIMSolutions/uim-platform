module uim.platform.architecture.presentation.web.controllers.architecture;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:
void handleArchitecture(HTTPServerRequest req, HTTPServerResponse res) {
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

    res.render!("architecture.dt", username, lang, translations);
}

class ArchitectureController {
    @path("/web/architecture")
    void index(HTTPServerRequest req, HTTPServerResponse res) {
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

        res.render!("architecture.dt", username, lang, translations);
    }

    @path("/web/architecture/:id")
    void getBlock(HTTPServerRequest req, HTTPServerResponse res, string _id) {
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

        auto block = ArchitectureBlock();
        res.render!("architecture_detail.dt", username, lang, translations, block);
    }
}
