module uim.platform.architecture.presentation.web.controllers.architecture;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:
class ArchitectureController {
    auto usecase = new ManageArchitectureBlocksUseCase(new ArchitectureBlockRepository());

    this(ArchitectureBlockRepository repo) {
        this.usecase = new ManageArchitectureBlocksUseCase(repo);
    }

    @path("/web/architecture")
    @method(HTTPMethod.GET)
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
        ArchitectureBlock[] blocks = usecase.listBlocks(
            TenantId(req.session.get!string("tenant", "default")));

        res.render!("architecture.dt", username, lang, translations, blocks);
    }

    @path("/web/architecture/view/:id")
    @method(HTTPMethod.GET)
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
        auto mode = "readonly";

        auto block = usecase.getBlock(TenantId(req.session.get!string("tenant", "default")), ArchitectureBlockId(
                _id));
        res.render!("architecture_view.dt", username, lang, translations, block, mode);
    }

    @path("/web/architecture/create")
    @method(HTTPMethod.GET)
    void showCreate(HTTPServerRequest req, HTTPServerResponse res) {
        if (!req.session || !req.session.get!bool("isLoggedIn", false)) {
            res.redirect("/web/login");
            return;
        }

        auto block = ArchitectureBlock(TenantId(req.session.get!string("tenant", "default")));
        block.id = "id", generateId();
        block.title = "New Architecture Block";
        block.description = req.form.get("description", "Description of the new architecture block.");

        string username = req.session.get!string("username", "User");
        string lang = req.session.get!string("lang", "de");
        string lang2 = req.query.get("lang", "en");
        if (lang != lang2) {
            req.session.set("lang", lang2);
            lang = lang2;
        }
        auto translations = getTranslations(lang);
        auto mode = "editable";

        res.render!("architecture_create.dt", username, lang, translations, block, mode);
    }

    @path("/web/architecture/create")
    @method(HTTPMethod.POST)
    void create(HTTPServerRequest req, HTTPServerResponse res) {
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

        auto block = ArchitectureBlock(TenantId(req.session.get!string("tenant", "default")));
        block.id = ArchitectureBlockId(req.form.get("id", generateId()));
        block.title = req.form.get("title", "New Architecture Block");
        block.owner = req.form.get("owner", "");
        block.description = req.form.get("description", "Description of the new architecture block.");

        auto request = CreateArchitectureBlockRequest();
        request.tenantId = block.tenantId;
        request.blockId = block.id;
        request.title = block.title;
        request.description = block.description;
        request.owner = block.owner;
        usecase.createBlock(request);

        res.redirect("/web/architecture");
    }

    @path("/web/architecture/edit/:id")
    @method(HTTPMethod.GET)
    void showEdit(HTTPServerRequest req, HTTPServerResponse res, string _id) {
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
        auto mode = "editable";

        auto block = ArchitectureBlock();
        res.render!("architecture_edit.dt", username, lang, translations, block, mode);
    }

    @path("/web/architecture/edit")
    @method(HTTPMethod.POST)
    void updateEdit(HTTPServerRequest req, HTTPServerResponse res, string _id) {
        if (!req.session || !req.session.get!bool("isLoggedIn", false)) {
            res.redirect("/web/login");
            return;
        }

        string username = req.session.get!string("username", "User");
        auto block = ArchitectureBlock(TenantId(req.session.get!string("tenant", "default")));
        block.id = ArchitectureBlockId(req.form.get("id", generateId()));
        block.title = req.form.get("title", "New Architecture Block");
        block.description = req.form.get("description", "Description of the new architecture block.");

        auto request = UpdateArchitectureBlockRequest();
        request.tenantId = block.tenantId;
        request.blockId = block.id;
        request.title = block.title;
        request.description = block.description;
        usecase.updateBlock(request);

        res.redirect("/web/architecture/view?id=" ~ block.id.toString());
    }

    @path("/web/architecture/update")
    @method(HTTPMethod.POST)
    void updateBlock(HTTPServerRequest req, HTTPServerResponse res) {
        if (!req.session || !req.session.get!bool("isLoggedIn", false)) {
            res.redirect("/web/login");
            return;
        }

        string id = req.form.get("id");
        string title = req.form.get("title");
        string description = req.form.get("description");

        auto block = ArchitectureBlock();
        block.id = ArchitectureBlockId(id);
        block.title = title;
        block.description = description;

        auto request = UpdateArchitectureBlockRequest();
        request.tenantId = block.tenantId;
        request.blockId = block.id;
        request.title = block.title;
        request.description = block.description;
        usecase.updateBlock(request);

        res.redirect("/web/architecture/");
    }

    @path("/web/architecture/delete/:id")
    @method(HTTPMethod.GET)
    void showDelete(HTTPServerRequest req, HTTPServerResponse res, string _id) {
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
        auto mode = "readonly";

        auto block = ArchitectureBlock();
        res.render!("architecture_delete.dt", username, lang, translations, block, mode);
    }

    @path("/web/architecture/delete")
    @method(HTTPMethod.POST)
    void deleteBlock(HTTPServerRequest req, HTTPServerResponse res, string _id) {
        if (!req.session || !req.session.get!bool("isLoggedIn", false)) {
            res.redirect("/web/login");
            return;
        }

        auto block = ArchitectureBlock(TenantId(req.session.get!string("tenant", "default")));
        block.id = ArchitectureBlockId(req.form.get("id", generateId()));
        usecase.deleteBlock(block.tenantId, block.id);

        res.redirect("/web/architecture/");
    }

    @path("/web/architecture/duplicate/:id")
    @method(HTTPMethod.GET)
    void showDuplicate(HTTPServerRequest req, HTTPServerResponse res, string _id) {
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
        auto mode = "editable";

        auto block = usecase.getBlock(TenantId(req.session.get!string("tenant", "default")), ArchitectureBlockId(_id));    
        block.id = ArchitectureBlockId(generateId());
        block.title = "New Architecture Block";
        block.description = req.form.get("description", "Description of the new architecture block.");

        res.render!("architecture_create.dt", username, lang, translations, block, mode);
    }
}
