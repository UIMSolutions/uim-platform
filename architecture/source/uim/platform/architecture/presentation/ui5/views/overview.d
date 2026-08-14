module uim.platform.architecture.presentation.ui5.views.overview;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class OverviewUi5View {
    string renderOverview(string tenantId) {
        auto tenant = escapeJs(tenantId);
        auto html = appender!string();
        html ~= pageStart("Architecture UI5 Hub");
        html ~= "<script>";
        html ~= "sap.ui.getCore().attachInit(function(){";
        html ~= "var app=new sap.m.App();";
        html ~= "var page=new sap.m.Page({title:'Building Blocks'});";
        html ~= "page.addContent(new sap.m.ObjectStatus({title:'Tenant',text:'" ~ tenant ~ "'}));";
        html ~= "var list=new sap.m.List({inset:true});";
        html ~= navItem("Architecture", "/ui5/architecture/architecture?tenantId=" ~ tenant);
        html ~= navItem("Solution", "/ui5/architecture/solution?tenantId=" ~ tenant);
        html ~= navItem("Data", "/ui5/architecture/data?tenantId=" ~ tenant);
        html ~= navItem("Business", "/ui5/architecture/business?tenantId=" ~ tenant);
        html ~= navItem("Technology", "/ui5/architecture/technology?tenantId=" ~ tenant);
        html ~= "page.addContent(list);app.addPage(page);app.placeAt('content');";
        html ~= "});</script></body></html>";
        return html.data;
    }

    string renderOverview(Ui5BuildingBlockPageModel model) {
        auto html = appender!string();
        auto tenant = escapeJs(model.tenantId);
        html ~= pageStart(model.title);
        html ~= "<script>";
        html ~= "sap.ui.getCore().attachInit(function(){";
        html ~= "var data={title:'" ~ escapeJs(model.title) ~ "',subtitle:'" ~ escapeJs(model.subtitle) ~ "',tenant:'" ~ tenant ~ "',blockType:'" ~ escapeJs(model.blockType) ~ "',items:[";
        foreach (idx, item; model.items) {
            if (idx > 0)
                html ~= ",";
            html ~= "{";
            html ~= "id:'" ~ escapeJs(item.id) ~ "',";
            html ~= "name:'" ~ escapeJs(item.name) ~ "',";
            html ~= "description:'" ~ escapeJs(item.description) ~ "',";
            html ~= "owner:'" ~ escapeJs(item.owner) ~ "',";
            html ~= "status:'" ~ escapeJs(item.status) ~ "',";
            html ~= "lifecycle:'" ~ escapeJs(item.lifecycle) ~ "',";
            html ~= "versionLabel:'" ~ escapeJs(item.versionLabel) ~ "',";
            html ~= "tags:'" ~ escapeJs(item.tags) ~ "'";
            html ~= "}";
        }
        html ~= "]};";
        html ~= "var app=new sap.m.App();";
        html ~= "var page=new sap.m.Page({title:data.title,showNavButton:true,navButtonPress:function(){window.location='/ui5/architecture?tenantId='+encodeURIComponent(data.tenant);}});";
        html ~= "page.addContent(new sap.m.Text({text:data.subtitle}));";
        html ~= "page.addContent(new sap.m.Toolbar({content:[new sap.m.ToolbarSpacer(),new sap.m.Button({text:'Create',type:'Emphasized',icon:'sap-icon://add',press:function(){openCreateDialog();}})]}));";
        html ~= "var table=new sap.m.Table({growing:true,columns:[new sap.m.Column({header:new sap.m.Label({text:'ID'})}),new sap.m.Column({header:new sap.m.Label({text:'Name'})}),new sap.m.Column({header:new sap.m.Label({text:'Status'})}),new sap.m.Column({header:new sap.m.Label({text:'Owner'})})]});";
        html ~= "var m=new sap.ui.model.json.JSONModel(data);table.setModel(m);";
        html ~= "table.bindItems('/items',new sap.m.ColumnListItem({type:'Navigation',press:function(e){var c=e.getSource().getBindingContext();var id=c.getProperty('id');window.location='/ui5/architecture/'+data.blockType+'/'+encodeURIComponent(id)+'?tenantId='+encodeURIComponent(data.tenant);},cells:[new sap.m.ObjectIdentifier({title:'{id}'}),new sap.m.Text({text:'{name}'}),new sap.m.ObjectStatus({text:'{status}'}),new sap.m.Text({text:'{owner}'})]}));";
        html ~= "page.addContent(table);";
        html ~= "function openCreateDialog(){";
        html ~= "var nameInput=new sap.m.Input({placeholder:'Name (required)'});";
        html ~= "var descInput=new sap.m.TextArea({rows:3,placeholder:'Description'});";
        html ~= "var ownerInput=new sap.m.Input({placeholder:'Owner'});";
        html ~= "var lifecycleInput=new sap.m.Input({placeholder:'Lifecycle'});";
        html ~= "var statusInput=new sap.m.Input({placeholder:'Status'});";
        html ~= "var versionInput=new sap.m.Input({placeholder:'Version'});";
        html ~= "var tagsInput=new sap.m.Input({placeholder:'Tags, comma-separated'});";
        html ~= "var dialog=new sap.m.Dialog({title:'Create '+data.blockType+' block',contentWidth:'34rem',content:[new sap.ui.layout.form.SimpleForm({editable:true,layout:'ResponsiveGridLayout',content:[new sap.m.Label({text:'Name'}),nameInput,new sap.m.Label({text:'Description'}),descInput,new sap.m.Label({text:'Owner'}),ownerInput,new sap.m.Label({text:'Lifecycle'}),lifecycleInput,new sap.m.Label({text:'Status'}),statusInput,new sap.m.Label({text:'Version'}),versionInput,new sap.m.Label({text:'Tags'}),tagsInput]})],beginButton:new sap.m.Button({text:'Create',type:'Emphasized',press:function(){var payload={name:nameInput.getValue(),description:descInput.getValue(),owner:ownerInput.getValue(),lifecycleState:lifecycleInput.getValue(),status:statusInput.getValue(),versionLabel:versionInput.getValue(),tags:tagsInput.getValue()};if(!payload.name){sap.m.MessageToast.show('Name is required');return;}var url='/ui5/architecture/'+data.blockType+'/create?tenantId='+encodeURIComponent(data.tenant);fetch(url,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(payload)}).then(function(r){return r.json();}).then(function(result){if(result && result.success){sap.m.MessageToast.show('Created successfully');window.location.reload();}else{sap.m.MessageToast.show((result && result.message) || 'Create failed');}}).catch(function(){sap.m.MessageToast.show('Create failed');});dialog.close();}}),endButton:new sap.m.Button({text:'Cancel',press:function(){dialog.close();}}),afterClose:function(){dialog.destroy();}});";
        html ~= "dialog.open();";
        html ~= "}";
        html ~= "app.addPage(page);app.placeAt('content');";
        html ~= "});</script></body></html>";
        return html.data;
    }

   
}
