using Microsoft.Owin.Hosting;
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;

namespace NewWebAPI
{
    public class Program
    {
        static void Main()
        {
            string baseAddress = "http://localhost:9000/";

            var so = new StartOptions(baseAddress);
            var tl = new TextWriterTraceListenerCustomOutput(Console.Out);

            
            // Start OWIN host 
            using (var srv = WebApp.Start<Startup>(options:so))
            {
                //var traceListener = Trace.Listeners.OfType<TextWriterTraceListener>().FirstOrDefault();
                //traceListener.TraceOutputOptions = TraceOptions.None;

                Trace.Listeners.Remove("HostingTraceListener");
                Trace.Listeners.Add(tl);
                //Trace.Listeners.OfType<HostingTraceListener>

                // Create HttpCient and make a request to api/values 
                //HttpClient client = new HttpClient();

                //var response = client.GetAsync(baseAddress + "/api/rc/restaurants").Result;


                //Console.WriteLine(response);
                //Console.WriteLine(response.Content.ReadAsStringAsync().Result);
                Console.WriteLine();
                Console.WriteLine("Press ENTER to stop the server and close app...");
                Console.ReadLine();
            }            
        }
    }
    class TextWriterTraceListenerCustomOutput : TextWriterTraceListener
    {
        public TextWriterTraceListenerCustomOutput(string fileName) : base(fileName)
        {
        }
        public TextWriterTraceListenerCustomOutput(TextWriter textWriter) : base(textWriter)
        {
        }

        public TextWriterTraceListenerCustomOutput(Stream stream) : base(stream)
        {

        }
        public TextWriterTraceListenerCustomOutput() : base()
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
            //base.TraceEvent(eventCache, source, eventType, id, message);

            if (String.IsNullOrEmpty(message)) return;

            var messageItems = message.Split(',');

            if (!Array.Exists(messageItems, i => i.ToLower() == "request" || i.ToLower() == "response"))return;


            //if (messageItems.Any(i => i == "Request") == false) return;


            WriteLine(" ");
            WriteLine(new String('=',30));
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
                    WriteLine(string.Format("{0}: {1}",mi[0].Trim(), mi[1].Trim()));
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