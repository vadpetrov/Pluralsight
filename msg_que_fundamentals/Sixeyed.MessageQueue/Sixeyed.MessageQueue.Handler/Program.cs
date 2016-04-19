using Newtonsoft.Json;
using Sixeyed.MessageQueue.Integration.Workflows;
using Sixeyed.MessageQueue.Messages.Commands;
using System;
using System.IO;
using msmq = System.Messaging;

namespace Sixeyed.MessageQueue.Handler
{
    class Program
    {
        static void Main(string[] args)
        {
            /*
            using (var queue = new msmq.MessageQueue(".\\private$\\sixeyed.messagequeue.unsubscribe")) 
            {
                while (true)
                {
                    Console.WriteLine("Listening");
                    var message = queue.Receive();
                    var bodyReader = new StreamReader(message.BodyStream);
                    var jsonBody = bodyReader.ReadToEnd();
                    var unsubscribeCommand = JsonConvert.DeserializeObject<UnsubscribeCommand>(jsonBody);
                    var workflow = new UnsubscribeWorkflow(unsubscribeCommand.EmailAddress);
                    Console.WriteLine("Starting unsubscribe for {0} - {1}", unsubscribeCommand.EmailAddress, System.DateTime.Now);
                    workflow.Run();
                    Console.WriteLine("Unsubscribe complete for {0} - {1}", unsubscribeCommand.EmailAddress, System.DateTime.Now);
                }
            }
            */
            using (var queue = new msmq.MessageQueue(".\\private$\\sixeyed.messagequeue.unsubscribe-tx"))
            {
                while (true)
                {
                    Console.WriteLine("Listening");

                    using (var tx = new msmq.MessageQueueTransaction())
                    {
                        tx.Begin();
                        var message = queue.Receive(tx);
                        var bodyReader = new StreamReader(message.BodyStream);
                        var jsonBody = bodyReader.ReadToEnd();
                        var unsubscribeCommand = JsonConvert.DeserializeObject<UnsubscribeCommand>(jsonBody);
                        var workflow = new UnsubscribeWorkflow(unsubscribeCommand.EmailAddress);
                        Console.WriteLine("Starting unsubscribe for {0} - {1}", unsubscribeCommand.EmailAddress, System.DateTime.Now);
                        workflow.Run();
                        Console.WriteLine("Unsubscribe complete for {0} - {1}", unsubscribeCommand.EmailAddress, System.DateTime.Now);
                        tx.Commit();
                    }
                }
            }
        }
    }
}
