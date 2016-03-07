using PO.Contracts;
using PO.Data;
using PO.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security;
using System.Security.Claims;
using System.Security.Permissions;
using System.ServiceModel;
using System.ServiceModel.Activation;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace PO.Services
{
    [AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.PerCall)]
    public class POService :IPOService, IDisposable
    {
        readonly PODbContext _repo = new PODbContext();
        

        public List<Product> GetProducts()
        {
            return _repo.Products.ToList();
        }

        //[PrincipalPermission(SecurityAction.Demand, Role = "builtin\\administrators")]
        [PrincipalPermission(SecurityAction.Demand, Role = "builtin\\users")]
        public List<Customer> GetCustomers()
        {
            
            var prinicipal = Thread.CurrentPrincipal;
            
            //if (!prinicipal.IsInRole("builtin\\administrators"))
            //    throw new SecurityException("Access Denied - POService - 1");

            
            /*
             if ClaimsPrincipal.Current.HasClaim() .......
             */ 

            
            return _repo.Customers.ToList();
        }

        public List<Order> GetOrders()
        {
            var result = _repo.Orders
                .Include("OrderItems")
                //.Where(o => o.Id == 13)
                .Take(10)
                .ToList();
            return result;
        }

        [OperationBehavior(TransactionScopeRequired=true)]
        public void SubmitOrder(Order order)
        {
            _repo.Orders.Add(order);

            order.OrderItems.ForEach(oi => _repo.OrderItems.Add(oi));

            _repo.SaveChanges();
        }

        public void Dispose()
        {
            _repo.Dispose();
        }
    }
}
