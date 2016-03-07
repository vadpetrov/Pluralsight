using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ServiceModel;
using OP.Clients.WPFApp.POServices;
using System.Collections.ObjectModel;
using PO.Entities;
using System.ServiceModel.Channels;

namespace OP.Clients.WPFApp
{
    class POProxy : ClientBase<IPOService>, IPOService
    {

        public POProxy(){}
        public POProxy(string endpointName): base(endpointName) {}
        public POProxy(Binding binding, string address): base(binding,new EndpointAddress(address)){}


        public ObservableCollection<Product> GetProducts()
        {
            return Channel.GetProducts();
        }

        public Task<ObservableCollection<Product>> GetProductsAsync()
        {
            return Channel.GetProductsAsync();
        }

        public ObservableCollection<Customer> GetCustomers()
        {
            return Channel.GetCustomers();
        }

        public Task<ObservableCollection<Customer>> GetCustomersAsync()
        {
            return Channel.GetCustomersAsync();
        }

        public ObservableCollection<Order> GetOrders()
        {
            return Channel.GetOrders();
        }

        public Task<ObservableCollection<Order>> GetOrdersAsync()
        {
            return Channel.GetOrdersAsync();
        }

        public void SubmitOrder(Order order)
        {
            Channel.SubmitOrder(order);
        }

        public Task SubmitOrderAsync(Order order)
        {
            return Channel.SubmitOrderAsync(order);
        }
    }
}
