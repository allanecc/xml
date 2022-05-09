@RestResource(urlMapping='/ws_xmltojson/*')
global with sharing class Xml {
    @HttpPost
    global static void getJsonData(String url){
        //String url = 'https://felav02.c.sat.gob.gt/NotificacionFEL-rest/rest/publico/descargaXml/V0lFUWhzcXVvSzYzaDBPdTZEZi96SFdaK2VoZnB1Vi80WXBpaW9kSHozNjhIeHViVlU0akRnd3lNZmtkempXaUZLNmNlM1hONjAydkNLcEpSRUVQbXc9PQ==';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

       DOM.Document doc = new DOM.Document();
        doc.load(res.getBody());
        Dom.XmlNode root = doc.getRootElement();
        String ns = 'http://www.sat.gob.gt/dte/fel/0.2.0'; 
             
        
        Dom.XmlNode items =root.getChildElement('SAT', ns).getChildElement('DTE', ns)
            .getChildElement('DatosEmision', ns).getChildElement('Items', ns);
        //System.debug();
        List<Dom.XmlNode> itemsChildren = items.getChildren();

        Items listaItems = new Items();
        for(Dom.XmlNode child: itemsChildren){
           // system.debug(child.getName()); 
           if(child.getName() == null){
                continue;
           }
           Item itemsIndividuales = new Item();
           itemsIndividuales.bienOServicio = child.getAttributeValue('BienOServicio', null);
           itemsIndividuales.numeroLinea = child.getAttributeValue('NumeroLinea', null);
           itemsIndividuales.cantidad = child.getChildElement('Cantidad', ns).getText();
           itemsIndividuales.unidadMedida = child.getChildElement('UnidadMedida', ns).getText();
           itemsIndividuales.descripcion = child.getChildElement('Descripcion', ns).getText();
           itemsIndividuales.precioUnitario = child.getChildElement('PrecioUnitario', ns).getText();
           itemsIndividuales.precio = child.getChildElement('Precio', ns).getText();
           itemsIndividuales.descuento = child.getChildElement('Descuento', ns).getText();           
           itemsIndividuales.total = child.getChildElement('Total', ns).getText();
            
          List<Dom.XmlNode> imps = child.getChildElement('Impuestos', ns).getChildren();

          //System.debug(imps);
          
            for(Dom.XmlNode imp: imps){
                if(imp.getName() != null){
                    Impuesto objImpuesto = new Impuesto();
                    objImpuesto.nombreCorto = imp.getChildElement('NombreCorto', ns).getText();
                    objImpuesto.montoImpuesto = imp.getChildElement('MontoImpuesto', ns).getText();
                    objImpuesto.montoGravable = imp.getChildElement('MontoGravable', ns).getText();
                    objImpuesto.codigoUnidadGravable = imp.getChildElement('CodigoUnidadGravable', ns).getText();
                 
                    itemsIndividuales.impuestos.add(objImpuesto);
                }
            }
          
                //System.debug(itemsIndividuales);
                listaItems.items.add(itemsIndividuales);
                
            }
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(listaItems));
            //return JSONGenerator(listaItems);  
        
    }   
    public with sharing class Impuesto {
        String nombreCorto;
        String codigoUnidadGravable;
        String montoGravable;
        String montoImpuesto;
    }
    public with sharing class Item {
        String bienOServicio;
        String numeroLinea;
        String cantidad;
        String unidadMedida;
        String descripcion;
        String precioUnitario;
        String precio;
        String descuento;
        List<Impuesto> impuestos;
        String total;
        public Item(){
            impuestos = new List<Impuesto>();
        }
    }
    public with sharing class Items {
        
        List<Item> items; 
        public Items(){
            items = new List<Item>();
        }
    }

}