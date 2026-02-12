# Mastodon Bash Sitemap Generator 🚀

A lightweight, high-performance sitemap generator for Mastodon instances.  
Unlike the built-in Ruby task, this script uses direct PostgreSQL queries to generate sitemaps in seconds, making it ideal for large instances, low-resource VPS environments, or Docker/Coolify deployments.

---

## ✨ Features

- 🚀 **High Performance** — Direct SQL queries instead of heavy Ruby/Rails execution
- 🧠 **Auto Container Detection** — Works seamlessly with Docker & Coolify
- 🔍 **SEO-Optimized** — Indexes public profiles and public statuses
- 🛠 **Zero Extra Dependencies** — Requires only `bash`, `docker`, and `cron`
- 🔒 **Privacy-Compliant** — Respects Mastodon visibility rules

---

## 📦 Installation

### 1️⃣ Create Directory

```bash
sudo mkdir -p /opt/sitemap
sudo chown $USER:$USER /opt/sitemap
```

---

### 2️⃣ Create the Script

```bash
nano /opt/sitemap/generate_sitemap.sh
```

Paste the script contents, then:

```bash
chmod +x /opt/sitemap/generate_sitemap.sh
```

---

### 3️⃣ Configure Domain

Edit the `DOMAIN` variable inside the script:

```bash
DOMAIN="social.yourdomain.com"
```

---

## ⏱ Automating with Cron

Keeping your sitemap fresh is critical for SEO indexing stability.

### Option A — User Crontab (Recommended)

```bash
crontab -e
```

Add:

```bash
0 0 * * * /opt/sitemap/generate_sitemap.sh > /dev/null 2>&1
```

Runs daily at **00:00**.

---

### Option B — System-wide Cron File

Create:

```bash
sudo nano /etc/cron.d/mastodon-sitemap
```

Insert:

```text
# -----------------------------------------------------------------
# Mastodon Bash Sitemap Generator - Cron Job
# Copy to: /etc/cron.d/mastodon-sitemap
# -----------------------------------------------------------------

0 0 * * * root /opt/sitemap/generate_sitemap.sh > /dev/null 2>&1
```

---

## 🌐 Serving the Sitemap

Two deployment models are supported:

### 1️⃣ Docker Auto-Sync (Default)

The script runs:

```
docker cp sitemap.xml <mastodon-web-container>:/mastodon/public/
```

Your sitemap becomes available at:

```
https://yourdomain.com/sitemap.xml
```

---

### 2️⃣ Reverse Proxy Serving

Alternatively, configure Nginx or Traefik to serve:

```
/opt/sitemap/sitemap.xml
```

This method removes container coupling and is operationally cleaner in high-availability setups.

---

## 🔒 Privacy & Filtering Logic

The generator strictly respects Mastodon privacy settings:

### ✔ Indexed

- Local accounts
- Not suspended
- Not silenced
- Not moved
- Public statuses (`visibility = 0`)
- Non-reblogs (no boosts)

### ❌ Excluded

- Followers-only posts
- Direct messages
- Boosts
- Suspended or silenced accounts

---

## ⚙ Performance Limits

Default limits:

| Type      | Limit  |
|-----------|--------|
| Profiles  | 10,000 |
| Statuses  | 40,000 |

Limits can be adjusted inside the script.

The purpose is to prevent memory spikes on low-resource VPS deployments.

---

## 🧩 Architecture Overview

```
PostgreSQL → SQL Query → XML Builder → sitemap.xml → Docker Sync / Proxy
```

No Rails runtime.  
No Sidekiq jobs.  
No unnecessary memory overhead.

---

## 🤝 Contributing

Pull requests are welcome for:

- Query optimization
- Multi-instance federation filtering
- Orchestrator abstraction
- Pagination support (sitemap index)

---

## 📄 License

MIT License — Free for personal and commercial use.
