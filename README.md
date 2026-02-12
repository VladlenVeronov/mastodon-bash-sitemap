# Mastodon Bash Sitemap Generator 🚀

A lightweight, high-performance sitemap generator for Mastodon instances.  
Unlike the built-in Ruby task, this script uses direct PostgreSQL queries to generate sitemaps in seconds, making it ideal for large instances, low-resource VPS, or Docker/Coolify setups.

## ✨ Features

- **🚀 Fast:** Uses direct SQL queries instead of heavy Ruby/Rails execution.
- **🧠 Smart:** Auto-discovers Docker containers (perfect for Coolify/Docker Compose).
- **🔍 SEO Friendly:** Specifically designed to index **public profiles** and **public statuses**.
- **🛠 Zero Dependencies:** Works with standard Linux tools (`bash`, `docker`, `cron`).

---

## 📥 Installation

### 1. Setup Directory
Create a directory to store the script and the generated sitemap:

```bash
sudo mkdir -p /opt/sitemap
sudo chown $USER:$USER /opt/sitemap
```

### 2. Create the Script
Create a new file named `generate_sitemap.sh`:

```bash
nano /opt/sitemap/generate_sitemap.sh
```

*(Paste the script code here, save with `Ctrl+O`, and exit with `Ctrl+X`)*

Make the script executable:

```bash
chmod +x /opt/sitemap/generate_sitemap.sh
```

### 3. Configuration
Open the script and edit the `DOMAIN` variable at the top of the file to match your Mastodon instance:

```bash
# Inside generate_sitemap.sh
DOMAIN="social.yourdomain.com"
```

### 4. Automate with Cron
To keep your sitemap up to date automatically, add a cron job.

1. Open the cron editor:

   ```bash
   crontab -e
   ```

2. Add the following line at the end of the file to run the generator every night at midnight (00:00):

   ```bash
   0 0 * * * /opt/sitemap/generate_sitemap.sh > /dev/null 2>&1
   ```

---

## 🌐 Serving the Sitemap

The script is designed to be flexible and offers two ways to serve the file:

1. **Direct Sync (Default):** The script automatically runs `docker cp` to copy the generated `sitemap.xml` into your Mastodon `web` container's `public` folder. It becomes available immediately at `https://yourdomain.com/sitemap.xml`.
2. **Nginx Sidecar:** You can point an external Nginx container or your reverse proxy (Traefik/Nginx) to serve the file directly from the host directory `/opt/sitemap/sitemap.xml`.

---

## 🔒 Content Privacy & Safety

This generator strictly respects Mastodon privacy settings to ensure no private data is leaked to search engines. It only indexes:

- **Public Profiles:** Local accounts that are **not** suspended, silenced, or moved.
- **Public Statuses:** Local statuses with `public` visibility (`visibility = 0`) that are **not** reblogs (boosts).
- **Limits:** Default limits are set to 10,000 profiles and 40,000 statuses to prevent memory overload (configurable in the script).

---

## 🤝 Contributing

Feel free to open issues or submit pull requests if you want to improve the SQL queries or add support for other container orchestrators!

## 📄 License

**MIT License**. Feel free to use, modify, and distribute this script for your own instances.
