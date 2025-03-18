-- Create user for Fabric SQL
CREATE USER [sp-fabric-sql-statereader] FOR LOGIN [sp-fabric-sql-statereader];
GRANT CONTROL TO [sp-fabric-sql-statereader];

-- Create Customers Table
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Create Products Table
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Create Orders Table
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

-- Create Order Details Table
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);


-- Insert Customers
INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES 
    ('John', 'Doe', 'johndoe@example.com', '123-456-7890'),
    ('Jane', 'Smith', 'janesmith@example.com', '987-654-3210'),
    ('Alice', 'Brown', 'alicebrown@example.com', '555-111-2222'),
    ('Bob', 'Johnson', 'bobJohnson@example.com', '555-222-3333');

-- Insert Products
INSERT INTO Products (ProductName, Price, StockQuantity)
VALUES 
    ('Laptop', 999.99, 10),
    ('Smartphone', 699.99, 20),
    ('Tablet', 299.99, 30);

-- Insert Orders
INSERT INTO Orders (CustomerID, TotalAmount)
VALUES 
    (1, 1699.98),  -- John Doe orders a Laptop & Smartphone
    (2, 299.99),   -- Jane Smith orders a Tablet
    (3, 999.99);   -- Alice Brown orders a Laptop

-- Insert Order Details
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price)
VALUES 
    (1, 1, 1, 999.99),  -- John Doe buys 1 Laptop
    (1, 2, 1, 699.99),  -- John Doe buys 1 Smartphone
    (2, 3, 1, 299.99),  -- Jane Smith buys 1 Tablet
    (3, 1, 1, 999.99);  -- Alice Brown buys 1 Laptop
