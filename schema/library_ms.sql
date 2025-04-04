create database library_ms;
use library_ms;

-- Library Management System Schema (Normalized to 3NF)

-- 1. Authors Table
CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Biography TEXT
);

-- 2. Publishers Table
CREATE TABLE Publishers (
    PublisherID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE,
    Address VARCHAR(255),
    ContactInfo VARCHAR(255)
);

-- 3. Categories Table
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

-- 4. Books Table
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    ISBN VARCHAR(13) NOT NULL UNIQUE,
    Title VARCHAR(255) NOT NULL,
    PublisherID INT,
    PublicationYear YEAR,
    TotalCopies INT NOT NULL DEFAULT 1,
    AvailableCopies INT NOT NULL DEFAULT 1,
    ShelfLocation VARCHAR(50),
    CONSTRAINT fk_books_publisher FOREIGN KEY (PublisherID)
        REFERENCES Publishers(PublisherID)
);

-- 5. BookAuthors Table (Many-to-Many Relationship)
CREATE TABLE BookAuthors (
    BookID INT NOT NULL,
    AuthorID INT NOT NULL,
    PRIMARY KEY (BookID, AuthorID),
    CONSTRAINT fk_bookauthors_book FOREIGN KEY (BookID)
        REFERENCES Books(BookID),
    CONSTRAINT fk_bookauthors_author FOREIGN KEY (AuthorID)
        REFERENCES Authors(AuthorID)
);

-- 6. BookCategories Table (Many-to-Many Relationship)
CREATE TABLE BookCategories (
    BookID INT NOT NULL,
    CategoryID INT NOT NULL,
    PRIMARY KEY (BookID, CategoryID),
    CONSTRAINT fk_bookcategories_book FOREIGN KEY (BookID)
        REFERENCES Books(BookID),
    CONSTRAINT fk_bookcategories_category FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID)
);

-- 7. Members Table
CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    LibraryCardNumber VARCHAR(50) NOT NULL UNIQUE,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    Email VARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(20),
    RegistrationDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ExpiryDate TIMESTAMP,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    PasswordHash VARCHAR(255),   -- Security: store hashed password
    PasswordSalt VARCHAR(100)    -- Security: unique salt per member
);

-- 8. Users Table (Librarians/Staff)
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,  -- Security: store hashed password
    PasswordSalt VARCHAR(100) NOT NULL, -- Security: unique salt per user
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Role VARCHAR(50) NOT NULL,          -- e.g., 'Admin', 'Librarian', etc.
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    LastLogin TIMESTAMP NULL
);

-- 9. Loans Table called since this is library institutions the users is called the borrower
CREATE TABLE Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    LoanDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DueDate TIMESTAMP NOT NULL,
    ReturnDate TIMESTAMP,  -- NULL indicates the book is still checked out
    IssuedByUserID INT,    -- Librarian issuing the loan
    ReceivedByUserID INT,  -- Librarian processing the return
    CONSTRAINT fk_loans_book FOREIGN KEY (BookID)
        REFERENCES Books(BookID),
    CONSTRAINT fk_loans_member FOREIGN KEY (MemberID)
        REFERENCES Members(MemberID),
    CONSTRAINT fk_loans_issuedby FOREIGN KEY (IssuedByUserID)
        REFERENCES Users(UserID),
    CONSTRAINT fk_loans_receivedby FOREIGN KEY (ReceivedByUserID)
        REFERENCES Users(UserID),
    CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate)
);

-- 10. Fines Table (Optional for tracking overdue fines)
CREATE TABLE Fines (
    FineID INT AUTO_INCREMENT PRIMARY KEY,
    LoanID INT NOT NULL UNIQUE,  -- One fine record per overdue loan
    MemberID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    DateIssued TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DatePaid TIMESTAMP,
    Reason VARCHAR(255),
    CONSTRAINT fk_fines_loan FOREIGN KEY (LoanID)
        REFERENCES Loans(LoanID),
    CONSTRAINT fk_fines_member FOREIGN KEY (MemberID)
        REFERENCES Members(MemberID)
);

-- first error i found "Out of range value for column 'PublicationYear'" error occurs because the  data type in MySQL only supports values between 1901 and 2155. 
ALTER TABLE Books MODIFY COLUMN PublicationYear INT;


