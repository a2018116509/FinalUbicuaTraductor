namespace ApiProductor.Controllers
{
    using Microsoft.AspNetCore.Mvc;
    using System;
    using System.Threading.Tasks;
    using Azure.Messaging.ServiceBus;
    using ApiProductor.Models;
    using Newtonsoft.Json;

    [Route("api/[controller]")]
    [ApiController]
    public class TraductorController : ControllerBase
    {
        [HttpPost]
        public async Task<bool> EnviarAsync([FromBody] Traduccion traduccion)
        {
            string connectionString = "Endpoint=sb://queuetraductor.servicebus.windows.net/;SharedAccessKeyName=enviar;SharedAccessKey=2Awin9tlnHKtiP9GIKUGEg/IoM77nnHUnIiQOGcyLLY=;EntityPath=traducciones";
            string queueName = "traducciones";
            String mensaje = JsonConvert.SerializeObject(traduccion);
            await using (ServiceBusClient client = new ServiceBusClient(connectionString))
            {
                // create a sender for the queue 
                ServiceBusSender sender = client.CreateSender(queueName);

                // create a message that we can send
                ServiceBusMessage message = new ServiceBusMessage(mensaje);

                // send the message
                await sender.SendMessageAsync(message);
                Console.WriteLine($"Sent a single message to the queue: {queueName}");
            }

            return true;
        }
    }
}
