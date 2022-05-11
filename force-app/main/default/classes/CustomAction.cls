public with sharing class CustomAction {
  @InvocableMethod
  public static List <Results> execute (List<String> request) {

    //Consultar la Oportunidad

    List<Opportunity> op = [SELECT id, Porcentaje_Comision__c FROM 	Opportunity WHERE Id IN :request   WITH SECURITY_ENFORCED LIMIT 1];

    List<Poliza__c> polizas = [SELECT id, Oportunidad__c FROM 	Poliza__c WHERE Oportunidad__c IN :op WITH SECURITY_ENFORCED];

    List<Cobros__c> cobros =[SELECT id, Poliza__c FROM Cobros__c WHERE Poliza__c IN :polizas WITH SECURITY_ENFORCED];
    List<Pago_Aplicado__c> pagosAplicados =[SELECT id, No_Cobro__c, Comision_Compania__c FROM Pago_Aplicado__c WHERE No_Cobro__c IN :cobros WITH SECURITY_ENFORCED];
    for (Pago_Aplicado__c pagoA : pagosAplicados) {
        pagoA.Comision_Compania__c = op[0].Porcentaje_Comision__c;
    }

    if (!Schema.sObjectType.Pago_Aplicado__c.fields.Comision_Compania__c.isUpdateable()) {
      return null;
    }
    update pagosAplicados;

    String outputMember = 'Se ha modificado '+ pagosAplicados.size()+ ' registros';

    //Create a Results object to hold the return values
    Results response = new Results();

    //Add the return values to the Results object
    response.outputMember = outputMember;

    //Wrap the Results object in a List container 
    //(an extra step added to allow this interface to also support bulkification)
    List<Results> responseWrapper= new List<Results>();
    responseWrapper.add(response);
    return responseWrapper;    
}


  public class Results {
    @InvocableVariable(label='Records for Output' description='yourDescription' required=true)
    public String outputMember;
  }
}
