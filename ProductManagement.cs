using System;
using System.Collections.Generic;
using System.Globalization;

namespace ProductManagement
{
    public class Product
    {
        public string Name { get; set; }
        public decimal Price { get; set; }

        public Product(string name, decimal price)
        {
            Name = name;
            Price = price;
        }
    }

    internal class Program
    {
        private static readonly List<Product> productList = new List<Product>();

        static void Main(string[] args)
        {
            bool exit = false;

            while (!exit)
            {
                Console.WriteLine("\n===== QUẢN LÝ SẢN PHẨM =====");
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
                        Console.WriteLine($"Tổng giá trị sản phẩm: {CalculateTotalValue():N0}");
                        break;
                    case "4":
                        exit = true;
                        Console.WriteLine("Thoát chương trình.");
                        break;
                    default:
                        Console.WriteLine("Lựa chọn không hợp lệ. Vui lòng chọn từ 1 đến 4.");
                        break;
                }
            }
        }

        private static void AddProduct()
        {
            string name = ReadProductName();
            decimal price = ReadProductPrice();

            Product product = new Product(name, price);
            productList.Add(product);

            Console.WriteLine($"Đã thêm sản phẩm: {product.Name} - Giá: {product.Price:N0}");
        }

        private static string ReadProductName()
        {
            while (true)
            {
                Console.Write("Nhập tên sản phẩm: ");
                string name = Console.ReadLine();

                if (!string.IsNullOrWhiteSpace(name))
                {
                    return name.Trim();
                }

                Console.WriteLine("Tên sản phẩm không được để trống.");
            }
        }

        private static decimal ReadProductPrice()
        {
            while (true)
            {
                Console.Write("Nhập giá sản phẩm: ");
                string input = Console.ReadLine();

                if (decimal.TryParse(input, NumberStyles.Number, CultureInfo.InvariantCulture, out decimal price) && price > 0)
                {
                    return price;
                }

                Console.WriteLine("Giá sản phẩm không hợp lệ. Vui lòng nhập số lớn hơn 0.");
            }
        }

        private static void ListProducts()
        {
            Console.WriteLine("\nDanh sách sản phẩm:");

            if (productList.Count == 0)
            {
                Console.WriteLine("Không có sản phẩm nào.");
                return;
            }

            int index = 1;
            foreach (Product product in productList)
            {
                Console.WriteLine($"{index}. Tên sản phẩm: {product.Name}, Giá: {product.Price:N0}");
                index++;
            }
        }

        private static decimal CalculateTotalValue()
        {
            decimal total = 0;

            foreach (Product product in productList)
            {
                total += product.Price;
            }

            return total;
        }
    }
}