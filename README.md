# MySQL-MariaDB-Database-and-Server-Configuration
# MySQL Backup, Restore, and Maintenance Scripts

This repository contains simple, reusable shell scripts for managing MySQL database backups, restores, replication checks, and cleanup tasks.  
These scripts help automate routine DBA tasks to ensure high availability, data integrity, and clean storage management.

---

## 📂 Project Structure
├── mysql_database_dump.sh # Full database dump to local storage
├── restore_mysql_database.sh # Restore database from dump file
├── confirm_mysql_replication_status.sh # Check replication status
├── purge_old_local_backups.sh # Purge old local backup files
├── purge_rubrik_tokens.sh # Purge old Rubrik tokens (if using Rubrik)
├── my.cnf # MySQL client configuration file
└── README.md # Documentation


---

## ⚙️ Scripts Overview

### `mysql_database_dump.sh`

- Creates a full dump of the MySQL database.
- Stores the dump locally for backup or migration.
- Useful for periodic backups or before major changes.

---

### `restore_mysql_database.sh`

- Restores the database from a specified dump file.
- Ensures minimal downtime when recovering from backups.

---

### `confirm_mysql_replication_status.sh`

- Checks the status of MySQL replication.
- Useful for verifying that master-slave or Galera Cluster replication is healthy.

---

### `purge_old_local_backups.sh`

- Deletes local backup files older than a specified number of days.
- Keeps local storage clean and prevents unnecessary disk usage.

---

### `purge_rubrik_tokens.sh`

- Cleans up old Rubrik API tokens.
- Useful if you use Rubrik to store database backups securely.

---

## ⚙️ `my.cnf`

Your `my.cnf` file stores configuration settings for the MySQL client and server.  

---

## ✅ Prerequisites

- **MySQL/MariaDB** installed and running.
- Proper permissions for the MySQL user (backup/restore).
- Sufficient disk space for dump files.
- Basic shell environment (bash).
- Rubrik API credentials (if using `purge_rubrik_tokens.sh`).

