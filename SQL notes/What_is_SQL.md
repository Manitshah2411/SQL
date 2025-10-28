# SQL Foundational Concepts

---

## 1. What is SQL?

* **Data:** Simply information about something (e.g., a customer's name, the price of a product).
* **Database:** An organized container where related data is stored, like a digital filing cabinet.
* **Why SQL?:** Big companies can't store data in Excel as it becomes messy and inefficient. You can talk to and manipulate data with a universal language called **SQL (Structured Query Language)**.

---

## 2. How Databases are Managed

* A **DBMS (Database Management System)** acts as the central hub or gatekeeper for a database. It manages all interactions from users, applications, and analytics tools (like Power BI) to ensure data is secure and consistent.
[](Diagrams/db.png)

* **Servers:** These are powerful, always-on computers where databases live. They provide the constant availability and processing power that a personal PC cannot.
[](Diagrams/flow_db.png)

---

## 3. Types of Databases

[](Diagrams/types_db.png)

### Relational Databases (The real SQL)

* **Structure:** Organizes data into tables with **rows** and **columns**, like a collection of interconnected spreadsheets.
* **Core Idea:** The relationships *between* the tables are key (e.g., how a `Customers` table connects to an `Orders` table).

### Key-Value Stores (No - SQL)

* **Structure:** Organizes data into simple "key-value" pairs.
* **Analogy:** Like a two-column dictionary or a phone book (`Key` = Name, `Value` = Phone Number).
* **Use Case:** Extremely fast for retrieving a known value when you have the key.

### Column-Based Databases (No - SQL)

* **Structure:** Organizes data in columns instead of rows.
* **Analogy:** Imagine tearing a phone book into separate piles for "Names," "Addresses," and "Phone Numbers."
* **Use Case:** Very fast for analytical queries that scan just a few columns over millions of rows.

### Graph Databases (No - SQL)

* **Structure:** Organizes data as a network of **nodes** (objects) and **edges** (relationships).
* **Core Idea:** The relationships are the most important part of the data.
* **Use Case:** Perfect for social networks, fraud detection, and recommendation engines.

### Document Databases (No - SQL)

* **Structure:** Stores data in flexible, JSON-like "documents."
* **Analogy:** Like a collection of Word documents where each one contains all the information about a single thing.
* **Use Case:** Great for applications with evolving requirements where the data structure isn't fixed, like blog posts or product catalogs.

## 4. Types of Commands

[](Diagrams/types_commands.png)

### Data Definition Language (DDL)

* **Create, Alter and Drop:** This commands are the definition of the Tables.

### Data Manupilation Language (DML)

* **Insert, Update, Delete:** This commands are used to manupilate the data.

### Data Query Language (DQL) - The most important one

* **Select:** Used to select and get the specific data with running well designed queries.

---
