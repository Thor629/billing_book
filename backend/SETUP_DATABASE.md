# 🗄️ Database Setup Guide

## Quick Setup (Choose One Method)

### Method 1: Using Command Line (Fastest) ⚡

**Step 1: Create Database**
```bash
cd backend
mysql -u root -p < setup_database.sql
```
Enter your MySQL password when prompted.

**Step 2: Configure Laravel**
```bash
cp .env.example .env
```

Edit `backend/.env` and set:
```env
DB_DATABASE=saas_billing
DB_USERNAME=root
DB_PASSWORD=your_mysql_password
```

**Step 3: Run Migrations**
```bash
composer install
php artisan key:generate
php artisan migrate
php artisan db:seed
```

**Done!** ✅

---

### Method 2: Manual MySQL Command

```bash
mysql -u root -p
```

Then run:
```sql
CREATE DATABASE saas_billing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

Then follow Steps 2-3 from Method 1.

---

### Method 3: Using phpMyAdmin

1. Open `http://localhost/phpmyadmin`
2. Click "New" in left sidebar
3. Database name: `saas_billing`
4. Collation: `utf8mb4_unicode_ci`
5. Click "Create"

Then follow Steps 2-3 from Method 1.

---

### Method 4: Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your MySQL server
3. Click "Create Schema" icon (cylinder with +)
4. Schema name: `saas_billing`
5. Charset: `utf8mb4`
6. Click "Apply"

Then follow Steps 2-3 from Method 1.

---

## Complete Setup Commands

```bash
# Navigate to backend
cd backend

# Create database (using SQL file)
mysql -u root -p < setup_database.sql

# Copy environment file
cp .env.example .env

# Edit .env with your database password
# Set DB_PASSWORD=your_password

# Install dependencies
composer install

# Generate application key
php artisan key:generate

# Create tables
php artisan migrate

# Add sample data
php artisan db:seed

# Start server
php artisan serve
```

---

## Verify Database Creation

```bash
mysql -u root -p -e "SHOW DATABASES LIKE 'saas_billing';"
```

Should show:
```
+---------------------------+
| Database (saas_billing)   |
+---------------------------+
| saas_billing              |
+---------------------------+
```

---

## Troubleshooting

### "Access denied for user 'root'"
**Solution:** Check your MySQL password in `.env`

### "Unknown database 'saas_billing'"
**Solution:** Database not created. Run the SQL file again.

### "SQLSTATE[HY000] [2002] Connection refused"
**Solution:** MySQL is not running. Start MySQL service.

**Windows:**
```bash
net start mysql
```

**Mac:**
```bash
brew services start mysql
```

**Linux:**
```bash
sudo systemctl start mysql
```

---

## What Gets Created

### Database
- Name: `saas_billing`
- Charset: `utf8mb4`
- Collation: `utf8mb4_unicode_ci`

### Tables (After Migration)
1. `users` - User accounts
2. `plans` - Subscription plans
3. `subscriptions` - User subscriptions
4. `activity_logs` - Audit trail
5. `personal_access_tokens` - Auth tokens

### Sample Data (After Seeding)
- 1 Admin: `admin@example.com` / `password123`
- 3 Users: `john@example.com`, `jane@example.com`, `bob@example.com`
- 3 Plans: Basic ($9.99), Pro ($29.99), Enterprise ($99.99)
- 2 Active subscriptions

---

## Quick Test

After setup, test the database:

```bash
php artisan tinker
```

Then:
```php
User::count();  // Should return 4
Plan::count();  // Should return 3
```

Type `exit` to quit.

---

## Next Steps

After database is created:

1. ✅ Database created
2. ✅ Migrations run
3. ✅ Sample data seeded
4. 🚀 Start server: `php artisan serve`
5. 🎨 Start Flutter: `cd ../flutter_app && flutter run -d chrome`
6. 🔐 Login: `admin@example.com` / `password123`

---

## Need Help?

**Check MySQL is running:**
```bash
mysql -u root -p -e "SELECT VERSION();"
```

**Check database exists:**
```bash
mysql -u root -p -e "SHOW DATABASES;"
```

**Check tables exist:**
```bash
mysql -u root -p saas_billing -e "SHOW TABLES;"
```
