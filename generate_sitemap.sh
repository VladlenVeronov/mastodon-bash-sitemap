#!/bin/bash

# =================================================================#
# Mastodon Bash Sitemap Generator                                  #
# High-performance sitemap generation via direct SQL queries       #
# =================================================================#

# --- Configuration ---
DOMAIN="social.vir.group"                # Your Mastodon domain
OUTPUT_DIR="/opt/sitemap"                # Local directory for sitemap
OUTPUT_FILE="$OUTPUT_DIR/sitemap.xml"
LIMIT_ACCOUNTS=10000                     # Max profiles in sitemap
LIMIT_STATUSES=40000                     # Max posts in sitemap

# --- Container Discovery ---
# Automatically finds containers even if Coolify/Docker changes suffixes
DB_CONTAINER=$(docker ps --format "{{.Names}}" | grep "^db-" | head -n 1)
WEB_CONTAINER=$(docker ps --format "{{.Names}}" | grep "^web-" | head -n 1)

echo "Starting sitemap generation for $DOMAIN..."

if [ -z "$DB_CONTAINER" ]; then
    echo "Error: Database container not found!"
    exit 1
fi

# Create directory if not exists
mkdir -p $OUTPUT_DIR

# --- XML Header ---
cat <<EOF > $OUTPUT_FILE
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://$DOMAIN/</loc><priority>1.0</priority></url>
EOF

# --- 1. Profiles (Accounts) ---
echo "Fetching profiles..."
docker exec $DB_CONTAINER psql -U postgres -t -c \
"SELECT '  <url><loc>https://$DOMAIN/@' || username || '</loc><changefreq>daily</changefreq><priority>0.7</priority></url>' 
 FROM accounts WHERE domain IS NULL AND suspended_at IS NULL AND silenced_at IS NULL AND moved_to_account_id IS NULL LIMIT $LIMIT_ACCOUNTS;" >> $OUTPUT_FILE

# --- 2. Public Statuses (Posts) ---
echo "Fetching public statuses..."
docker exec $DB_CONTAINER psql -U postgres -t -c \
"SELECT '  <url><loc>https://$DOMAIN/@' || a.username || '/' || s.id || '</loc><changefreq>weekly</changefreq><priority>0.5</priority></url>' 
 FROM statuses s JOIN accounts a ON s.account_id = a.id 
 WHERE s.local = true AND s.visibility = 0 AND s.reblog_of_id IS NULL ORDER BY s.created_at DESC LIMIT $LIMIT_STATUSES;" >> $OUTPUT_FILE

# --- XML Footer ---
echo "</urlset>" >> $OUTPUT_FILE

# Clean up whitespaces
sed -i 's/^[[:space:]]*//' $OUTPUT_FILE

# --- Optional: Sync to Web Container ---
if [ ! -z "$WEB_CONTAINER" ]; then
    docker cp $OUTPUT_FILE $WEB_CONTAINER:/opt/mastodon/public/sitemap.xml
    echo "Synced to web container: $WEB_CONTAINER"
fi

echo "Success! Total URLs: $(grep -c '<loc>' $OUTPUT_FILE)"
