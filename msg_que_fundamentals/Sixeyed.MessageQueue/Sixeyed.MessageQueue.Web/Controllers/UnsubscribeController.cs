using Newtonsoft.Json;
using Sixeyed.MessageQueue.Integration.Workflows;
using Sixeyed.MessageQueue.Messages.Commands;
using System;
using System.IO;
using System.Text;
using System.Web.Mvc;
using msmq = System.Messaging;

namespace Sixeyed.MessageQueue.Web.Controllers
{
    public class UnsubscribeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Submit(string emailAddress)
        {
            //var workflow = new UnsubscribeWorkflow(emailAddress);
            //workflow.Run();


            //fire and forget pattern
            var unsubscribeCommmand = new UnsubscribeCommand
            {
                EmailAddress = emailAddress
            };
            /*
            using (var queue = new msmq.MessageQueue(".\\private$\\sixeyed.messagequeue.unsubscribe"))             
            {
                //default message type = XML
                //var message = new msmq.Message(unsubscribeCommmand);

                //Json format = smaller message size                
                var jsonBody = JsonConvert.SerializeObject(unsubscribeCommmand);
                var message = new msmq.Message();
                message.BodyStream = new MemoryStream(Encoding.Default.GetBytes(jsonBody));

                queue.Send(message);
            }
            */

            using (var queue = new msmq.MessageQueue(".\\private$\\sixeyed.messagequeue.unsubscribe-tx"))
            {
                //default message type = XML
                //var message = new msmq.Message(unsubscribeCommmand);

                //Json format = smaller message size                
                var jsonBody = JsonConvert.SerializeObject(unsubscribeCommmand);
                var message = new msmq.Message();
                message.BodyStream = new MemoryStream(Encoding.Default.GetBytes(jsonBody));

                var tx = new msmq.MessageQueueTransaction();
               
                    tx.Begin();
                    queue.Send(message,tx);
                    tx.Commit();
               
            }

            return View("Confirmation");
        }
	}
}