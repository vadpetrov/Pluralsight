using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Xml.Linq;
using TheWorld.Models;
using TheWorld.ViewModels;

namespace TheWorld.Factories
{
    public static class FactoryExtensions
    {
        public static Trip Create(this IModelFactory factory, TripViewModel model)
        {
            var trip = new Trip
            {
                Id = model.Id,
                Name = model.Name,
                UserName = "sys",
                Created = model.Created,
                Stops = new List<Stop>()
            };
            return trip;
        }
        public static TripViewModel Create(this IModelFactory factory, Trip model)
        {
            var trip = new TripViewModel
            {
                Id = model.Id,
                Name = model.Name,
                Created = model.Created                
            };
            return trip;
        }

        public static Stop Create(this IModelFactory factory, StopViewModel model)
        {
            var stop = new Stop
            {
                Id = model.Id,
                Name = model.Name,
                Arrival = model.Arrival,
                Longitude = model.Longitude,
                Latitude = model.Latitude                
            };
            return stop;
        }
        public static StopViewModel Create(this IModelFactory factory, Stop model)
        {
            var stop = new StopViewModel
            {
                Id = model.Id,
                Name = model.Name,
                Arrival = model.Arrival,
                Longitude = model.Longitude,
                Latitude = model.Latitude                
            };
            return stop;
        }

        public static XDocument ToXml(this IModelFactory factory, TripViewModel trip)
        {
            var oDoc = new XDocument();
            var oRoot = new XElement("root");
            oRoot.SetAttributeValue("id", trip.Id);
            oRoot.SetAttributeValue("name", trip.Name);

            var tableStops = new XElement("table", new XAttribute("id", "stops"));

            foreach (var stop in trip.Stops)
            {
                var oRow = new XElement("row");

                oRow.Add(new XElement("item", new XAttribute("id", "id"), new XAttribute("value", stop.Id)),
                    new XElement("item", new XAttribute("id", "name"), new XAttribute("value", stop.Name)),
                    new XElement("item", new XAttribute("id", "arrival"), new XAttribute("value", stop.Arrival.ToString("MM/dd/yyyy"))));
                    
                tableStops.Add(oRow);
            }

            oRoot.Add(tableStops);
            oDoc.Add(oRoot);
            return oDoc;
        }
        private static XElement CreateXElement(string id, string value)
        {
            return new XElement(id, value);
        }
    }
}
