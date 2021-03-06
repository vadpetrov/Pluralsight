﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace OP.Clients.WPFApp.POServices {
    
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ServiceModel.ServiceContractAttribute(ConfigurationName="POServices.IPOService")]
    public interface IPOService {
        
        [System.ServiceModel.OperationContractAttribute(Action="http://tempuri.org/IPOService/GetProducts", ReplyAction="http://tempuri.org/IPOService/GetProductsResponse")]
        System.Collections.ObjectModel.ObservableCollection<PO.Entities.Product> GetProducts();
        
        [System.ServiceModel.OperationContractAttribute(Action="http://tempuri.org/IPOService/GetProducts", ReplyAction="http://tempuri.org/IPOService/GetProductsResponse")]
        System.Threading.Tasks.Task<System.Collections.ObjectModel.ObservableCollection<PO.Entities.Product>> GetProductsAsync();
        
        [System.ServiceModel.OperationContractAttribute(Action="http://tempuri.org/IPOService/GetCustomers", ReplyAction="http://tempuri.org/IPOService/GetCustomersResponse")]
        System.Collections.ObjectModel.ObservableCollection<PO.Entities.Customer> GetCustomers();
        
        [System.ServiceModel.OperationContractAttribute(Action="http://tempuri.org/IPOService/GetCustomers", ReplyAction="http://tempuri.org/IPOService/GetCustomersResponse")]
        System.Threading.Tasks.Task<System.Collections.ObjectModel.ObservableCollection<PO.Entities.Customer>> GetCustomersAsync();
        
        [System.ServiceModel.OperationContractAttribute(Action="http://tempuri.org/IPOService/GetOrders", ReplyAction="http://tempuri.org/IPOService/GetOrdersResponse")]
        System.Collections.ObjectModel.ObservableCollection<PO.Entities.Order> GetOrders();
        
        [System.ServiceModel.OperationContractAttribute(Action="http://tempuri.org/IPOService/GetOrders", ReplyAction="http://tempuri.org/IPOService/GetOrdersResponse")]
        System.Threading.Tasks.Task<System.Collections.ObjectModel.ObservableCollection<PO.Entities.Order>> GetOrdersAsync();
        
        [System.ServiceModel.OperationContractAttribute(Action="http://tempuri.org/IPOService/SubmitOrder", ReplyAction="http://tempuri.org/IPOService/SubmitOrderResponse")]
        void SubmitOrder(PO.Entities.Order order);
        
        [System.ServiceModel.OperationContractAttribute(Action="http://tempuri.org/IPOService/SubmitOrder", ReplyAction="http://tempuri.org/IPOService/SubmitOrderResponse")]
        System.Threading.Tasks.Task SubmitOrderAsync(PO.Entities.Order order);
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public interface IPOServiceChannel : OP.Clients.WPFApp.POServices.IPOService, System.ServiceModel.IClientChannel {
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public partial class POServiceClient : System.ServiceModel.ClientBase<OP.Clients.WPFApp.POServices.IPOService>, OP.Clients.WPFApp.POServices.IPOService {
        
        public POServiceClient() {
        }
        
        public POServiceClient(string endpointConfigurationName) : 
                base(endpointConfigurationName) {
        }
        
        public POServiceClient(string endpointConfigurationName, string remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public POServiceClient(string endpointConfigurationName, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public POServiceClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(binding, remoteAddress) {
        }
        
        public System.Collections.ObjectModel.ObservableCollection<PO.Entities.Product> GetProducts() {
            return base.Channel.GetProducts();
        }
        
        public System.Threading.Tasks.Task<System.Collections.ObjectModel.ObservableCollection<PO.Entities.Product>> GetProductsAsync() {
            return base.Channel.GetProductsAsync();
        }
        
        public System.Collections.ObjectModel.ObservableCollection<PO.Entities.Customer> GetCustomers() {
            return base.Channel.GetCustomers();
        }
        
        public System.Threading.Tasks.Task<System.Collections.ObjectModel.ObservableCollection<PO.Entities.Customer>> GetCustomersAsync() {
            return base.Channel.GetCustomersAsync();
        }
        
        public System.Collections.ObjectModel.ObservableCollection<PO.Entities.Order> GetOrders() {
            return base.Channel.GetOrders();
        }
        
        public System.Threading.Tasks.Task<System.Collections.ObjectModel.ObservableCollection<PO.Entities.Order>> GetOrdersAsync() {
            return base.Channel.GetOrdersAsync();
        }
        
        public void SubmitOrder(PO.Entities.Order order) {
            base.Channel.SubmitOrder(order);
        }
        
        public System.Threading.Tasks.Task SubmitOrderAsync(PO.Entities.Order order) {
            return base.Channel.SubmitOrderAsync(order);
        }
    }
}
