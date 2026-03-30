
using System;
using System.Collections.Generic;

namespace ProductManagement
{
    class Program
    {
        // Class Product để quản lý thông tin sản phẩm
        public class Product
        {
            public string Name { get; set; }
            public double Price { get; set; }

            public Product(string name, double price)
            {
                Name = name;
                Price = price;
            }
        }

        // Danh sách sản phẩm
        private static List<Product> productList = new List<Product>();

        static void Main(string[] args)
        {
            bool exit = false;

            while (!exit)
            {
                Console.WriteLine("1. Thêm sản phẩm mới");
                Console.WriteLine("2. Liệt kê sản phẩm");
                Console.WriteLine("3. Tính tổng giá trị sản phẩm");
                Console.WriteLine("4. Thoát");

                Console.Write("Chọn một chức năng: ");
                string choice = Console.ReadLine();

                switch (choice)
                {
                    case "1":
                        AddProduct();
                        break;
                    case "2":
                        ListProducts();
                        break;
                    case "3":
                        Console.WriteLine("Tổng giá trị sản phẩm: " + CalculateTotalValue());
                        break;
                    case "4":
                        exit = true;
                        break;
                    default:
                        Console.WriteLine("Lựa chọn không hợp lệ!");
                        break;
                }
            }
        }

        // Chức năng thêm sản phẩm mới
        public static void AddProduct()
        {
            Console.Write("Nhập tên sản phẩm: ");
            string name = Console.ReadLine()?.Trim();
            if (string.IsNullOrEmpty(name))
            {
                Console.WriteLine("Tên sẩn phẩm không được để trống");
                return;
            }

            Console.Write("Nhập giá sản phẩm: ");
            double price;
            while(!double.TryParse(Console.ReadLine(),out price) || price <=0)
            {
                Console.WriteLine();
                Console.Write("Giá trị không hợp lệ. Vui lòng nhập lại giá sản phẩm lớn hơn 0: ");
            }  

            Product product = new Product(name, price);
            productList.Add(product);

            Console.WriteLine("Đã thêm sản phẩm: " + name);
        }

        // Chức năng liệt kê sản phẩm
        public static void ListProducts()
        {
            Console.WriteLine("Danh sách sản phẩm:");

            if (productList.Count == 0)
            {
                Console.WriteLine("Không có sản phẩm nào.");
            }
            else
            {
                foreach (Product product in productList)
                {
                    Console.WriteLine("Tên sản phẩm: " + product.Name + ", Giá: " + product.Price);
                }
            }
        }

        // Chức năng tính tổng giá trị sản phẩm
        public static double CalculateTotalValue()
        {
            double total = 0;

            foreach (Product product in productList)
            {
                total += product.Price;  // Lỗi logic có thể phát sinh khi giá trị không hợp lệ
            }

            return total;
        }
    }
}

