namespace fncConsumidor
{
    using fncConsumidor.Models;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Extensions.Logging;
    using Newtonsoft.Json;
    using System;

    public static class Function1
    {
        [FunctionName("Function1")]
        public static async System.Threading.Tasks.Task RunAsync(
            [ServiceBusTrigger(
                "traducciones", 
                Connection = "MyConn"
                )]string myQueueItem,
            [CosmosDB(
                    databaseName:"dbTranslate",
                    collectionName:"Traducciones",
                    ConnectionStringSetting = "strCosmos"
                    )]IAsyncCollector<object> datos,
            ILogger log)
        {
            try
            {
                log.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
                var data = JsonConvert.DeserializeObject<Traduccion>(myQueueItem);
                await datos.AddAsync(data);
            }
            catch (Exception ex)
            {
                log.LogError($"No fue posible insertar datos: {ex.Message}");
            }

        }
    }
}
