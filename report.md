# Engineering Progress Report: Guestbook Application
**Project Goal:** A secure, automated, multi-tier application ready for OpenShift deployment.  
**Student Name:** [Your Name]  
**Date Range:** January 15 – January 19, 2026

---

## 📅 Timeline & Task Details

### Jan 15 – Jan 16: Initial Containerization & Networking
* **Task:** Analyze source code and build initial container images.
* **Process:** * Created a **multi-stage Containerfile** for the Go backend to ensure a small, secure production image.
    * Configured an Nginx-based frontend to serve static assets.
* **Challenges:** The frontend could not communicate with the backend API.
* **Resolution:** Created a custom bridge network (`guestbook-net`). This allowed the containers to use **DNS resolution**, enabling the frontend to find the backend via the hostname `backend:8080`.



### Jan 17: Externalizing Configuration (Security)
* **Task:** Secure the application by removing hardcoded credentials.
* **Process:** * Shifted all sensitive data (DB passwords, Hostnames) to a `.env` file located in the `./backend` directory.
    * Added `.env` to `.gitignore` to prevent accidental leaks to GitHub.
* **Challenges:** The application crashed at startup because it could no longer find its configuration file inside the container.
* **Resolution:** Implemented **Runtime Volume Mounting**. Used the `-v` flag to map the local `.env` file into the container's `WORKDIR` only at runtime.

### Jan 18: Data Persistence & SELinux Permissions
* **Task:** Ensure user posts survive container restarts.
* **Process:** * Assigned **Named Volumes** (`pgdata` and `redisdata`) to the database containers.
* **Challenges:** 1. **Data Loss:** Without volumes, deleting a container wiped the database.
    2. **Permission Denied:** Rootless Podman on Linux initially blocked access to the mounted `.env` file.
* **Resolution:** * Mapped volumes to `/var/lib/pgsql/data` (Postgres) and `/data` (Redis) to move storage from the container layer to the host disk.
    * Applied the **`:Z` SELinux flag** to mounts, allowing the container's non-root user (1001) to read the host files securely.



### Jan 19: Automation & Absolute Pathing
* **Task:** Create a "One-Click" startup solution.
* **Process:** * Developed `start.sh` to automate network creation, variable sourcing, and container sequencing.
* **Challenges:** The script failed with `lstat` errors when trying to find the `.env` file from the root directory.
* **Resolution:** * Integrated `$(pwd)` into the script to generate **absolute paths** for all volume mounts.
    * Used a bash `export` loop to inject variables from `./backend/.env` directly into the shell environment before launching containers.
