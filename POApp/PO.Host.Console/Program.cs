using PO.Contracts;
using PO.Services;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using System.Threading.Tasks;

namespace PO.Host.ConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                //using (var host = new WebServiceHost(typeof(POService)))
                using (var host = new ServiceHost(typeof(POService)))
                //using (var tl = new TextWriterTraceListenerCustomOutput(Console.Out))
                {
                    //Trace.Listeners.Remove("HostingTraceListener");
                    //Trace.Listeners.Add(tl);

                    host.Open();


                    //var myBinding = new BasicHttpBinding();

                    //var myEndpoint =
                    //new EndpointAddress(
                    //        new Uri("http://localhost:2112/"));

                    
                    //var cf = new ChannelFactory<IPOService>(myBinding,myEndpoint);
                    //var client = cf.CreateChannel();
                    //Object r = client.GetProducts();
                                      

                    Console.WriteLine("");
                    Console.WriteLine("Hit any key to exit.");
                    Console.ReadKey();

                    host.Close();
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
                throw ex;
            }
        }
    }

    class TextWriterTraceListenerCustomOutput : TextWriterTraceListener
    {
        public TextWriterTraceListenerCustomOutput(string fileName)
            : base(fileName)
        {
        }
        public TextWriterTraceListenerCustomOutput(TextWriter textWriter)
            : base(textWriter)
        {
        }

        public TextWriterTraceListenerCustomOutput(Stream stream)
            : base(stream)
        {

        }
        public TextWriterTraceListenerCustomOutput()
            : base()
        {
        }

        public override void Write(string message)
        {
            base.Write(string.Format("[{0}]:{1}", DateTime.Now, message));
        }

        public override void WriteLine(string message)
        {
            base.WriteLine(string.Format("{0}", message));
            //base.WriteLine(String.Format("[{0}]:{1}", DateTime.Now, message));
        }

        public override void TraceEvent(TraceEventCache eventCache, string source, TraceEventType eventType, int id, string message)
        {
            if (String.IsNullOrEmpty(message)) return;

            var messageItems = message.Split(',');

            if (!Array.Exists(messageItems, i => i.ToLower() == "request" || i.ToLower() == "response")) return;
            
            WriteLine(" ");
            WriteLine(new String('=', 30));
            WriteLine(string.Format("Process:{0} Thread:{1}", eventCache.ProcessId, eventCache.ThreadId));
            WriteLine(string.Format("Timestamp:{0}", eventCache.Timestamp));
            WriteLine(" ");
            foreach (var msgItem in messageItems)
            {
                var mi = msgItem.Split('=');

                if (mi.Length == 1)
                {
                    WriteLine(string.Format("{0}: {1}", "Type", mi[0].Trim()));
                }
                else
                {
                    WriteLine(string.Format("{0}: {1}", mi[0].Trim(), mi[1].Trim()));
                }
            }

            /*
            WriteLine(
                string.Format("{0}:{1}:{2}:{3}",
                source, eventType, id,
                message.Replace("\r", string.Empty).Replace("\n", string.Empty)));
            */
            //WriteLine(string.Format("{0}:{1}:{2}:{3}", source, eventType, Enum.GetName(typeof(TraceEventType), id), message.Replace("\r", string.Empty).Replace("\n", string.Empty)));
        }
    }
}
