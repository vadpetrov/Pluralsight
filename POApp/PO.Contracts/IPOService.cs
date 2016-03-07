using PO.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using System.Threading.Tasks;

namespace PO.Contracts
{
    [ServiceContract]
    public interface IPOService
    {   
        [OperationContract]
        [WebInvoke(Method = "GET", ResponseFormat = WebMessageFormat.Json)]
        List<Product> GetProducts();
        
        [OperationContract()]
        List<Customer> GetCustomers();

        [OperationContract()]
        List<Order> GetOrders();

        [OperationContract]
        void SubmitOrder(Order order);
    }
    /*
    [ServiceContract]
    public interface IPOService1
    {
        [OperationContract]
        List<T> GetProducts<T>() where T : class;

        [OperationContract()]
        List<T> GetCustomers<T>() where T : class;

        [OperationContract]
        void SubmitOrder<T>(T order) where T : class;   
    }
    */
}
