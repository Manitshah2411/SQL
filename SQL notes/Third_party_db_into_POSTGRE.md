# My Guide: Loading a Third-Party Database into PostgreSQL

This guide covers the one-time setup for the command line on macOS and the steps to load a complex database like AdventureWorks.

---

## 1. Prerequisites: Software Installation

* **PostgreSQL:** The core database engine. Installed using the official installer.
* **pgAdmin 4:** A graphical user interface (GUI) for managing and querying the database. It is installed automatically with PostgreSQL.
* **VS Code:** A code editor, perfect for writing and saving SQL scripts and notes in Markdown (`.md`).

---

## 2. Configuring the Command Line (One-Time Setup on Mac)

This is a one-time fix to allow the terminal to find the `psql` command.

### The Problem

After installation, running `psql` in the terminal gives a `command not found` error. This is because the terminal doesn't know the location of the PostgreSQL programs.

### The Permanent Solution

The most reliable solution is to add the PostgreSQL `bin` directory to the shell's `PATH` variable in the `.zshrc` file. This file is read every time a new interactive terminal opens.

1. **Open the configuration file:**

    ```bash
    nano ~/.zshrc
    ```

2. **Add the path:** Add this line to the end of the file. It tells the terminal to look for commands in PostgreSQL's folder.

    ```bash
    export PATH="/Library/PostgreSQL/17/bin:$PATH"
    ```

3. **Save and Exit:**
    * Press `Ctrl + O`, then `Enter` to save.
    * Press `Ctrl + X` to exit.

4. **Apply and Verify:**
    * **Crucial Step:** Close and reopen the terminal, or run `source ~/.zshrc`.
    * Verify the fix by running `which psql`. The system should now find it.

---

## 3. Loading a Database from a `.sql` Script via `psql` (The Successful Method)

This method works when you have a complete script designed for the `psql` command-line tool. This was the method that worked for the AdventureWorks database.

### Step 1: Find a Reliable `.sql` Script

* The script must contain all `CREATE` statements for the structure and all data loading commands (`\copy` or `INSERT`).
* **Example:** We found a corrected `install.sql` for AdventureWorks that fixed data consistency errors.

### Step 2: Navigate to the Script's Folder

* You must run the commands from the folder containing the `.sql` script and its associated data files (e.g., the `data` folder with CSVs).

    ```bash
    cd ~/path/to/your/script_folder
    ```

### Step 3: Create the Empty Database

* Use `psql` to create the empty database that will hold the restored data.

    ```bash
    psql -U postgres -c "CREATE DATABASE Adventureworks;"
    ```

### Step 4: Run the Script

* Use the `psql` command with the `-f` flag to execute the script file.

    ```bash
    psql -U postgres -d Adventureworks -f install.sql
    ```

---

## 4. Alternative Method: Using a `.dump` File

This is another common, professional method for restoring a complete database.

* **The File:** This method uses a compressed, binary backup file, often ending in `.dump`.
* **The Command:** It requires the `pg_restore` tool.

    ```bash
    pg_restore -U postgres -d YourDatabaseName -v /path/to/your/file.dump
    ```

---

## 5. Troubleshooting & Key Concepts

* **`command not found`:** The `PATH` variable is not set correctly for your terminal session.
* **`...database does not exist`:** You tried to connect to a database that wasn't successfully created in a previous step.
* **`syntax error at or near...` in pgAdmin:** You are trying to run a script containing `psql`-specific commands (like `\copy`) in the GUI, which doesn't understand them.
* **Foreign Key Violation Error:** This happened with the initial `.sql` script. It means the script tried to insert data in the wrong order (e.g., adding a "review" for a product that didn't exist yet). The solution was to find a **corrected script** where the order of operations was fixed.
