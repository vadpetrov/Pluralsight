using PO.Entities;
using OP.Clients.WPFApp.POServices;
using Prism.Commands;
using Prism.Mvvm;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Diagnostics;


namespace OP.Clients.WPFApp
{
    public class MainWindowViewModel : BindableBase
    {

        public DelegateCommand SubmitOrderCommand { get; private set; }
        public DelegateCommand<Product> AddOrderItemCommand { get; private set; }

        private ObservableCollection<Product> _Products;
        private ObservableCollection<Customer> _Customers;
        private ObservableCollection<OrderItemModel> _Items = new ObservableCollection<OrderItemModel>();
        private Order _CurrentOrder = new Order();

        public MainWindowViewModel()
        {
            _CurrentOrder.OrderDate = DateTime.Now;
            _CurrentOrder.OrderStatusId = 1;
            SubmitOrderCommand = new DelegateCommand(OnSubmitOrder);
            AddOrderItemCommand = new DelegateCommand<Product>(OnAddItem);
            if (!DesignerProperties.GetIsInDesignMode(new DependencyObject()))
            {
                LoadProductsAndCustomers();
            }
        }

        public ObservableCollection<Product> Products
        {
            get { return _Products; }
            set { SetProperty(ref _Products, value); }
        }

        public ObservableCollection<Customer> Customers
        {
            get { return _Customers; }
            set { SetProperty(ref _Customers, value); }
        }

        public ObservableCollection<OrderItemModel> Items
        {
            get { return _Items; }
            set { SetProperty(ref _Items, value); }
        }

        public Order CurrentOrder
        {
            get { return _CurrentOrder; }
            set { SetProperty(ref _CurrentOrder, value); }
        }

        private void OnAddItem(Product product)
        {
            var existingOrderItem = _CurrentOrder.OrderItems.Where(oi => oi.ProductId == product.Id).FirstOrDefault();
            var existingOrderItemModel = _Items.Where(i => i.ProductId == product.Id).FirstOrDefault();
            if (existingOrderItem != null && existingOrderItemModel != null)
            {
                existingOrderItem.Quantity++;
                existingOrderItemModel.Quantity++;
                existingOrderItem.TotalPrice = existingOrderItem.UnitPrice * existingOrderItem.Quantity;
                existingOrderItemModel.TotalPrice = existingOrderItem.TotalPrice;
            }
            else
            {
                var orderItem = new OrderItem { ProductId = product.Id, Quantity = 1, UnitPrice = 9.99m, TotalPrice = 9.99m };
                _CurrentOrder.OrderItems.Add(orderItem);
                Items.Add(new OrderItemModel { ProductId = product.Id, ProductName = product.Name, Quantity = orderItem.Quantity, TotalPrice = orderItem.TotalPrice });
            }
        }

        private void LoadProductsAndCustomers1()
        {
            var proxy = new POServiceClient("NetTcpBinding_IPOService");

            Products = proxy.GetProducts();
            Customers = proxy.GetCustomers();

            proxy.Close();
            /*
            

            proxy.ClientCredentials.Windows.ClientCredential.UserName = "WIN81VM\\test";
            proxy.ClientCredentials.Windows.ClientCredential.Password = "test";
            
            try
            {
                Products = proxy.GetProducts();
                Customers = proxy.GetCustomers();

            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed to load server data. " + ex.Message);
            }
            finally
            {
                proxy.Close();
            }
            */
        }

        private async void LoadProductsAndCustomers()
        {
            //var proxy = new POServiceClient("NetTcpBinding_IPOService");
            var proxy = new POProxy("NetTcpBinding_IPOService");

            try
            {                
                Products = await proxy.GetProductsAsync();
                Customers = await proxy.GetCustomersAsync();
                proxy.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed to load server data. " + ex.Message);
            }
            finally
            {
                proxy.Close();
            }
            
            /*
            var proxy = new POServiceClient("NetTcpBinding_IPOService");

            proxy.ClientCredentials.Windows.ClientCredential.UserName = "WIN81VM\\test";
            proxy.ClientCredentials.Windows.ClientCredential.Password = "test";
            
            try
            {
                Products = proxy.GetProducts();
                Customers = proxy.GetCustomers();

            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed to load server data. " + ex.Message);
            }
            finally
            {
                proxy.Close();
            }
            */
        }

        private void OnSubmitOrder()
        {
            if (_CurrentOrder.CustomerId != Guid.Empty && _CurrentOrder.OrderItems.Count > 0)
            {
                var proxy = new POServiceClient("NetTcpBinding_IPOService");

                try
                {
                    proxy.SubmitOrder(_CurrentOrder);
                    CurrentOrder = new Order();
                    CurrentOrder.OrderDate = DateTime.Now;
                    CurrentOrder.OrderStatusId = 1;
                    Items = new ObservableCollection<OrderItemModel>();
                }
                catch (Exception ex)
                {
                    Debug.WriteLine(ex);
                    MessageBox.Show("Error saving order, please try again later.");                    
                }
                finally
                {
                    proxy.Close();
                }
            }
            else
            {
                MessageBox.Show("You must select a customer and add order items to submit an order");
            }
        }
    }
}
