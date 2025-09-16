# SQL Course: Junior Level - Class 2: Data Types and Constraints

## Introduction

Welcome to the second class of the SQL Junior Level course! In this session, we will delve into two fundamental pillars of database design and management: **Data Types** and **Constraints**. Understanding these concepts is crucial for creating robust, efficient, and error-free databases.

### Learning Objectives

At the end of this class, you will be able to:

- Understand what data types are in SQL and why they are important.
- Identify and apply the most common data types for numbers, text, and dates.
- Understand what constraints are and their role in data integrity.
- Apply different types of constraints (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT) to tables.
- Design and create tables with appropriate data types and constraints.

### Estimated Duration

2 hours (including practical exercises).

---

## 1. Data Types in SQL

Data types define the kind of values that can be stored in a column. Choosing the correct data type is essential for:

- **Data Integrity**: Ensuring that only valid data is stored.
- **Storage Optimization**: Using the minimum necessary space.
- **Performance**: Improving query execution speed.

Let's explore the most common data types.

### 1.1 Numeric Data Types

Used to store numerical values.

#### `INT` (Integer)
**Pronunciation**: /ɪnt/ (like "int" in "internet")
**Description**: Stores whole numbers (without decimals). It is one of the most used data types.
**Example**: `age INT`, `quantity INT`
**Range**: Typically from -2,147,483,648 to 2,147,483,647 (depending on the system).

```sql
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(255),
    Price INT
);
```
**Explanation**:
- `ProductID INT PRIMARY KEY`: Defines `ProductID` as an integer and primary key.
- `Price INT`: Defines `Price` as an integer.

#### `DECIMAL(p, s)` or `NUMERIC(p, s)`
**Pronunciation**: /ˈdɛsɪməl/ (like "dess-i-mal") or /ˈnjuːmɛrɪk/ (like "new-mer-ik")
**Description**: Stores exact decimal numbers. `p` is the total number of digits (precision) and `s` is the number of digits after the decimal point (scale).
**Example**: `price DECIMAL(10, 2)` (up to 10 digits in total, 2 after the decimal point).
**Range**: Varies by precision and scale.

```sql
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    TotalAmount DECIMAL(10, 2)
);
```
**Explanation**:
- `TotalAmount DECIMAL(10, 2)`: Stores monetary values with up to 10 digits in total, 2 of which are decimals.

#### `FLOAT` and `DOUBLE`
**Pronunciation**: /floʊt/ (like "float") and /ˈdʌbəl/ (like "dub-uhl")
**Description**: Stores approximate decimal numbers (floating point). `FLOAT` is single-precision and `DOUBLE` is double-precision. They are generally used when exact precision is not critical, such as scientific calculations.
**Example**: `temperature FLOAT`, `latitude DOUBLE`

```sql
CREATE TABLE Sensors (
    SensorID INT PRIMARY KEY,
    Temperature FLOAT,
    Humidity DOUBLE
);
```
**Explanation**:
- `Temperature FLOAT`: Stores temperature values with approximate decimals.
- `Humidity DOUBLE`: Stores humidity values with higher precision approximate decimals.

### 1.2 Text Data Types

Used to store character strings.

#### `VARCHAR(n)` (Variable Character)
**Pronunciation**: /ˈvɑːrˌkɑːr/ (like "var-car")
**Description**: Stores character strings of variable length, up to a maximum of `n` characters. It is very efficient as it only uses the necessary storage space.
**Example**: `name VARCHAR(100)`, `address VARCHAR(255)`
**Maximum Length**: Varies by database, commonly up to 65,535 characters.

```sql
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100)
);
```
**Explanation**:
- `FirstName VARCHAR(50)`: Stores names up to 50 characters.
- `Email VARCHAR(100)`: Stores email addresses up to 100 characters.

#### `CHAR(n)` (Character)
**Pronunciation**: /tʃɑːr/ (like "char" in "charcoal")
**Description**: Stores fixed-length character strings. If the stored string is shorter than `n`, it is padded with spaces. Less common than `VARCHAR` for general text.
**Example**: `country_code CHAR(2)` (e.g., 'US', 'ES')
**Maximum Length**: Varies by database, commonly up to 255 characters.

```sql
CREATE TABLE Countries (
    CountryCode CHAR(2) PRIMARY KEY,
    CountryName VARCHAR(100)
);
```
**Explanation**:
- `CountryCode CHAR(2)`: Stores a fixed 2-character country code.

#### `TEXT`
**Pronunciation**: /tɛkst/ (like "text")
**Description**: Stores very long character strings. The maximum length is much greater than `VARCHAR`.
**Example**: `description TEXT`, `article_content TEXT`
**Maximum Length**: Varies by database, can be several gigabytes.

```sql
CREATE TABLE Articles (
    ArticleID INT PRIMARY KEY,
    Title VARCHAR(255),
    Content TEXT
);
```
**Explanation**:
- `Content TEXT`: Stores the full content of an article, which can be very long.

### 1.3 Date and Time Data Types

Used to store dates and times.

#### `DATE`
**Pronunciation**: /deɪt/ (like "date")
**Description**: Stores a date (year, month, day).
**Example**: `birth_date DATE`, `order_date DATE`
**Format**: 'YYYY-MM-DD'

```sql
CREATE TABLE Events (
    EventID INT PRIMARY KEY,
    EventName VARCHAR(255),
    EventDate DATE
);
```
**Explanation**:
- `EventDate DATE`: Stores the date of an event.

#### `TIME`
**Pronunciation**: /taɪm/ (like "time")
**Description**: Stores a time (hour, minute, second).
**Example**: `start_time TIME`, `end_time TIME`
**Format**: 'HH:MM:SS'

```sql
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY,
    AppointmentDate DATE,
    AppointmentTime TIME
);
```
**Explanation**:
- `AppointmentTime TIME`: Stores the time of an appointment.

#### `DATETIME` or `TIMESTAMP`
**Pronunciation**: /ˈdeɪtˌtaɪm/ (like "date-time") or /ˈtaɪmˌstæmp/ (like "time-stamp")
**Description**: Stores both date and time. `TIMESTAMP` often includes timezone information and is automatically updated in some databases.
**Example**: `created_at DATETIME`, `last_updated TIMESTAMP`
**Format**: 'YYYY-MM-DD HH:MM:SS'

```sql
CREATE TABLE Log (
    LogID INT PRIMARY KEY,
    Action VARCHAR(255),
    ActionDateTime DATETIME
);
```
**Explanation**:
- `ActionDateTime DATETIME`: Stores the exact date and time an action occurred.

---

## 2. Constraints in SQL

Constraints are rules enforced on data columns in a table. They are used to limit the type of data that can go into a table, ensuring the accuracy and reliability of the data.

### 2.1 `NOT NULL`
**Pronunciation**: /nɒt nʌl/ (like "not null")
**Description**: Ensures that a column cannot have a `NULL` value. This means that a value must always be provided for that column.
**Example**: `ProductName VARCHAR(255) NOT NULL`

```sql
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);
```
**Explanation**:
- `CategoryName VARCHAR(100) NOT NULL`: Ensures that every category must have a name.

### 2.2 `UNIQUE`
**Pronunciation**: /ˈjuːniːk/ (like "you-neek")
**Description**: Ensures that all values in a column are different. While a `PRIMARY KEY` automatically has a `UNIQUE` constraint, you can have multiple `UNIQUE` constraints in a table.
**Example**: `Email VARCHAR(100) UNIQUE`

```sql
CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Email VARCHAR(100) UNIQUE
);
```
**Explanation**:
- `Username VARCHAR(50) NOT NULL UNIQUE`: Ensures each username is unique and not null.
- `Email VARCHAR(100) UNIQUE`: Ensures each email is unique.

### 2.3 `PRIMARY KEY`
**Pronunciation**: /ˈpraɪmɛri kiː/ (like "pry-mary key")
**Description**: Uniquely identifies each record in a table. A table can only have one primary key, which must contain `UNIQUE` values and cannot contain `NULL` values.
**Example**: `CustomerID INT PRIMARY KEY`

```sql
CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(255)
);
```
**Explanation**:
- `BookID INT PRIMARY KEY`: `BookID` is the unique identifier for each book.

### 2.4 `FOREIGN KEY`
**Pronunciation**: /ˈfɒrɪn kiː/ (like "for-in key")
**Description**: Links two tables together. A foreign key in one table refers to the primary key in another table. It ensures referential integrity.
**Example**: `CustomerID INT, FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)`

```sql
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
```
**Explanation**:
- `FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)`: Establishes a link between the `Orders` table and the `Customers` table using `CustomerID`.

### 2.5 `CHECK`
**Pronunciation**: /tʃɛk/ (like "check")
**Description**: Ensures that all values in a column satisfy a specific condition.
**Example**: `Age INT CHECK (Age >= 18)`

```sql
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Age INT CHECK (Age >= 18)
);
```
**Explanation**:
- `Age INT CHECK (Age >= 18)`: Ensures that the age of an employee is 18 or older.

### 2.6 `DEFAULT`
**Pronunciation**: /ˈdiːfɔːlt/ (like "dee-folt")
**Description**: Provides a default value for a column when no value is specified during an `INSERT` operation.
**Example**: `Status VARCHAR(50) DEFAULT 'Active'`

```sql
CREATE TABLE Tasks (
    TaskID INT PRIMARY KEY,
    TaskName VARCHAR(255) NOT NULL,
    Status VARCHAR(50) DEFAULT 'Pending'
);
```
**Explanation**:
- `Status VARCHAR(50) DEFAULT 'Pending'`: If no status is provided, it will default to 'Pending'.

---

## 3. Practical Exercise: Designing a Database

Let's apply what we've learned by designing a simple database for a university.

### Scenario

We need to store information about students, courses, and their enrollments.

### Requirements

1.  **Students**:
    *   Each student must have a unique ID.
    *   First name and last name are mandatory.
    *   Age must be between 16 and 99.
    *   Email must be unique.
2.  **Courses**:
    *   Each course must have a unique ID.
    *   Course title is mandatory and unique.
    *   Credits must be between 1 and 6.
3.  **Enrollments**:
    *   Links students to courses.
    *   Enrollment date is mandatory and defaults to the current date.

### Solution

```sql
-- Create Students Table
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Age INT CHECK (Age >= 16 AND Age <= 99),
    Email VARCHAR(100) UNIQUE NOT NULL
);

-- Create Courses Table
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseTitle VARCHAR(100) NOT NULL UNIQUE,
    Credits INT CHECK (Credits >= 1 AND Credits <= 6)
);

-- Create Enrollments Table
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    EnrollmentDate DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);
```

**Explanation of the Solution**:

-   **Students Table**:
    *   `StudentID INT PRIMARY KEY`: Unique identifier for each student.
    *   `FirstName VARCHAR(50) NOT NULL`, `LastName VARCHAR(50) NOT NULL`: Mandatory fields for student names.
    *   `Age INT CHECK (Age >= 16 AND Age <= 99)`: Ensures age is within the valid range.
    *   `Email VARCHAR(100) UNIQUE NOT NULL`: Ensures each student has a unique and mandatory email.
-   **Courses Table**:
    *   `CourseID INT PRIMARY KEY`: Unique identifier for each course.
    *   `CourseTitle VARCHAR(100) NOT NULL UNIQUE`: Mandatory and unique title for each course.
    *   `Credits INT CHECK (Credits >= 1 AND Credits <= 6)`: Ensures credits are within the valid range.
-   **Enrollments Table**:
    *   `EnrollmentID INT PRIMARY KEY`: Unique identifier for each enrollment.
    *   `StudentID INT`, `CourseID INT`: Foreign keys linking to the `Students` and `Courses` tables, respectively.
    *   `EnrollmentDate DATE DEFAULT CURRENT_DATE`: Mandatory enrollment date, defaulting to the current date if not specified.

---

## 4. Summary

In this class, we have covered:

-   **Data Types**: How to define the type of data a column can store (numeric, text, date/time).
-   **Constraints**: Rules that maintain data integrity and consistency (NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY, CHECK, DEFAULT).
-   **Practical Application**: Designing a database schema using appropriate data types and constraints.

Mastering data types and constraints is fundamental for any database professional, as it directly impacts the quality and performance of your database systems.

---

## 5. Next Steps

In the next class, we will explore **Table Relationships**, a crucial topic for designing relational databases effectively.

---

## Navigation

-   [Back to Junior Level Index](README.md)
-   [Previous Class: Introduction to SQL](clase_1_introduccion_sql.md)
-   [Next Class: Table Relationships](clase_3_relaciones_tablas.md)