# SQL Introduction: The Language of Databases

## Introduction

Welcome to the first class of our SQL course! In this module, we will explore the fundamental concepts of SQL (Structured Query Language), the standard language for managing and manipulating relational databases. Whether you are a beginner or looking to reinforce your knowledge, this class will provide you with a solid foundation to start working with databases.

## Learning Objectives

At the end of this class, you will be able to:

*   Understand what SQL is and its importance in the world of data.
*   Differentiate between various types of databases.
*   Know the basic structure of a table in a relational database.
*   Perform basic operations: create a database, create a table, and insert data.

## What is SQL?

SQL (Structured Query Language) is a specialized language used to manage and query data stored in relational database management systems (RDBMS). It is the standard language for interacting with databases, allowing you to perform operations such as creating, modifying, and deleting data, as well as defining the structure of the database.

*   **SQL** (Structured Query Language) - Pronunciation: /ˌɛsˌkjuːˈɛl/ (es-kyoo-EL)
*   **RDBMS** (Relational Database Management System) - Pronunciation: /ˌɑːrˌbiːˌdiːˌɛmˈɛs/ (ar-bee-dee-em-ES)

## Types of Databases

There are several types of databases, but in this course, we will focus on relational databases, which are the most common and use SQL.

*   **Relational Databases**: Store data in tables, which are related to each other through common fields. Examples: MySQL, PostgreSQL, SQL Server, Oracle.
*   **NoSQL Databases**: Designed for specific data models and have flexible schemas. Examples: MongoDB (document-oriented), Cassandra (column-oriented), Redis (key-value).

*   **MySQL** - Pronunciation: /ˌmaɪˌɛsˈkjuːˌɛl/ (my-es-kyoo-EL)
*   **PostgreSQL** - Pronunciation: /ˈpoʊstɡrɛsˌkjuːˌɛl/ (pohst-gres-kyoo-EL)
*   **SQL Server** - Pronunciation: /ˌɛsˌkjuːˌɛl ˈsɜːrvər/ (es-kyoo-EL SUR-ver)
*   **Oracle** - Pronunciation: /ˈɔːrəkəl/ (OR-uh-kuhl)
*   **MongoDB** - Pronunciation: /ˈmɒŋɡoʊˌdiːˌbiː/ (MONG-goh-dee-bee)
*   **Cassandra** - Pronunciation: /kəˈsændrə/ (kuh-SAN-druh)
*   **Redis** - Pronunciation: /ˈrɛdɪs/ (RED-iss)

## Basic Table Structure

In a relational database, data is organized into tables. Each table consists of:

*   **Columns (Fields)**: Represent the attributes of the data. Each column has a name and a data type (e.g., `INT`, `VARCHAR`, `DATE`).
*   **Rows (Records)**: Represent individual entries or records in the table. Each row contains a value for each column.

*   **Columns** - Pronunciation: /ˈkɒləmz/ (KOL-uhmz)
*   **Rows** - Pronunciation: /roʊz/ (rohz)
*   **INT** (Integer) - Pronunciation: /ɪnt/ (int)
*   **VARCHAR** (Variable Character) - Pronunciation: /ˈvɑːrˌkɑːr/ (var-KAR)
*   **DATE** - Pronunciation: /deɪt/ (dayt)

## Basic Operations in SQL

Let's start with some practical examples. We will use a generic SQL syntax that should work in most relational database systems.

### 1. Creating a Database

To create a new database, we use the `CREATE DATABASE` statement.

**Example:**

```sql
CREATE DATABASE my_first_database;
```

*   **CREATE DATABASE** - Pronunciation: /kriːˈeɪt ˈdeɪtəˌbeɪs/ (kree-AYT DAY-tuh-bays)

### 2. Using a Database

Once created, we need to select it to work within it.

**Example:**

```sql
USE my_first_database;
```

*   **USE** - Pronunciation: /juːz/ (yooz)

### 3. Creating a Table

To store data, we need to create tables. We define the columns and their data types.

**Example:**

```sql
CREATE TABLE students (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    email VARCHAR(100)
);
```

*   **CREATE TABLE** - Pronunciation: /kriːˈeɪt ˈteɪbəl/ (kree-AYT TAY-buhl)
*   **PRIMARY KEY** - Pronunciation: /ˈpraɪˌmɛri kiː/ (PRY-mer-ee kee)

### 4. Inserting Data

To add records to our table, we use the `INSERT INTO` statement.

**Example:**

```sql
INSERT INTO students (id, name, age, email) VALUES (1, 'Alice', 20, 'alice@example.com');
INSERT INTO students (id, name, age, email) VALUES (2, 'Bob', 22, 'bob@example.com');
```

*   **INSERT INTO** - Pronunciation: /ɪnˈsɜːrt ˈɪntuː/ (in-SERT IN-too)
*   **VALUES** - Pronunciation: /ˈvæljuːz/ (VAL-yooz)

### 5. Selecting Data

To retrieve data from a table, we use the `SELECT` statement.

**Example:**

```sql
SELECT * FROM students;
```

This will return all columns and all rows from the `students` table.

*   **SELECT** - Pronunciation: /sɪˈlɛkt/ (sih-LEKT)
*   **FROM** - Pronunciation: /frɒm/ (from)

### 6. Selecting Specific Columns

You can also select only certain columns.

**Example:**

```sql
SELECT name, email FROM students;
```

### 7. Filtering Data (WHERE Clause)

To filter records based on a condition, we use the `WHERE` clause.

**Example:**

```sql
SELECT * FROM students WHERE age > 21;
```

*   **WHERE** - Pronunciation: /wɛər/ (wair)

### 8. Updating Data

To modify existing records, we use the `UPDATE` statement.

**Example:**

```sql
UPDATE students SET age = 21 WHERE name = 'Alice';
```

*   **UPDATE** - Pronunciation: /ʌpˈdeɪt/ (up-DAYT)
*   **SET** - Pronunciation: /sɛt/ (set)

### 9. Deleting Data

To remove records from a table, we use the `DELETE FROM` statement.

**Example:**

```sql
DELETE FROM students WHERE name = 'Bob';
```

*   **DELETE FROM** - Pronunciation: /dɪˈliːt frɒm/ (dih-LEET from)

### 10. Dropping a Table

To delete an entire table, we use the `DROP TABLE` statement.

**Example:**

```sql
DROP TABLE students;
```

*   **DROP TABLE** - Pronunciation: /drɒp ˈteɪbəl/ (drop TAY-buhl)

### 11. Dropping a Database

To delete an entire database, we use the `DROP DATABASE` statement.

**Example:**

```sql
DROP DATABASE my_first_database;
```

*   **DROP DATABASE** - Pronunciation: /drɒp ˈdeɪtəˌbeɪs/ (drop DAY-tuh-bays)

## Practice Exercises

To reinforce what you've learned, try these exercises:

1.  Create a database named `library_db`.
2.  Use the `library_db` database.
3.  Create a table named `books` with the following columns:
    *   `book_id` (INT, PRIMARY KEY)
    *   `title` (VARCHAR(255))
    *   `author` (VARCHAR(255))
    *   `publication_year` (INT)
    *   `genre` (VARCHAR(100))
4.  Insert at least 3 books into the `books` table.
5.  Select all books from the `books` table.
6.  Select only the `title` and `author` of the books.
7.  Select books published after the year 2000.
8.  Update the `genre` of one of your books.
9.  Delete a book from the table.
10. Drop the `books` table.
11. Drop the `library_db` database.

## Summary

In this class, you have learned:

*   What SQL is and why it is essential for database management.
*   The difference between relational and NoSQL databases.
*   The basic structure of tables, columns, and rows.
*   How to perform fundamental SQL operations: `CREATE DATABASE`, `USE`, `CREATE TABLE`, `INSERT INTO`, `SELECT`, `UPDATE`, `DELETE FROM`, `DROP TABLE`, and `DROP DATABASE`.

## Next Steps

In the next class, we will delve into data types, constraints, and more advanced table creation techniques. Keep practicing!

## Navigation

*   [Full Index](INDICE_COMPLETO.md)
*   [Quick Navigation](NAVEGACION_RAPIDA.md)