# 🗄️ Database Setup for Windows

## ⚠️ MySQL Not Found

MySQL is not installed or not in your system PATH.

---

## Option 1: Use XAMPP (Recommended for Windows) ✅

### Step 1: Install XAMPP
1. Download from: https://www.apachefriends.org/
2. Install XAMPP
3. Start XAMPP Control Panel

### Step 2: Start MySQL
1. Open XAMPP Control Panel
2. Click "Start" next to MySQL
3. Wait for it to turn green

### Step 3: Create Database
**Option A - Using phpMyAdmin:**
1. Click "Admin" next to MySQL in XAMPP
2. Opens phpMyAdmin in browser
3. Click "New" in left sidebar
4. Database name: `saas_billing`
5. Click "Create"

**Option B - Using Command Line:**
```bash
cd C:\xampp\mysql\bin
mysql -u root -p
```
Then:
```sql
CREATE DATABASE saas_billing;
EXIT;
```

### Step 4: Configure Laravel
```bash
cd backend
copy .env.example .env
```

Edit `backend\.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=saas_billing
DB_USERNAME=root
DB_PASSWORD=
```
(Leave password empty for XAMPP default)

### Step 5: Run Setup
```bash
composer install
php artisan key:generate
php artisan migrate
php artisan db:seed
php artisan serve
```

---

## Option 2: Install MySQL Standalone

### Step 1: Download MySQL
https://dev.mysql.com/downloads/installer/

### Step 2: Install
1. Run installer
2. Choose "Developer Default"
3. Set root password (remember this!)
4. Complete installation

### Step 3: Add to PATH
1. Open System Environment Variables
2. Edit PATH
3. Add: `C:\Program Files\MySQL\MySQL Server 8.0\bin`
4. Restart terminal

### Step 4: Create Database
```bash
mysql -u root -p
```
Enter your password, then:
```sql
CREATE DATABASE saas_billing;
EXIT;
```

### Step 5: Configure Laravel
Edit `backend\.env`:
```env
DB_PASSWORD=your_mysql_password
```

### Step 6: Run Setup
```bash
cd backend
composer install
php artisan key:generate
php artisan migrate
php artisan db:seed
```

---

## Option 3: Use Laravel Sail (Docker)

If you have Docker Desktop:

```bash
cd backend
composer require laravel/sail --dev
php artisan sail:install
./vendor/bin/sail up -d
./vendor/bin/sail artisan migrate
./vendor/bin/sail artisan db:seed
```

---

## Option 4: Use SQLite (No MySQL Needed)

### Step 1: Update .env
```env
DB_CONNECTION=sqlite
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=saas_billing
# DB_USERNAME=root
# DB_PASSWORD=
```

### Step 2: Create Database File
```bash
cd backend
type nul > database\database.sqlite
```

### Step 3: Run Migrations
```bash
php artisan migrate
php artisan db:seed
php artisan serve
```

---

## ✅ Recommended: XAMPP

**Why XAMPP?**
- ✅ Easy to install
- ✅ Includes MySQL + phpMyAdmin
- ✅ No configuration needed
- ✅ Perfect for development
- ✅ Free

**Download:** https://www.apachefriends.org/download.html

---

## Quick XAMPP Setup

1. **Install XAMPP** → https://www.apachefriends.org/
2. **Start MySQL** in XAMPP Control Panel
3. **Open phpMyAdmin** → http://localhost/phpmyadmin
4. **Create database** named `saas_billing`
5. **Configure .env:**
   ```env
   DB_DATABASE=saas_billing
   DB_USERNAME=root
   DB_PASSWORD=
   ```
6. **Run commands:**
   ```bash
   cd backend
   composer install
   php artisan key:generate
   php artisan migrate
   php artisan db:seed
   php artisan serve
   ```

---

## Verify Setup

After setup, test:

```bash
cd backend
php artisan tinker
```

Then type:
```php
\App\Models\User::count();
```

Should return `4` (1 admin + 3 users)

Type `exit` to quit.

---

## Need Help?

**Check if MySQL is running:**
- Open XAMPP Control Panel
- MySQL should be green/running

**Check database exists:**
- Open phpMyAdmin
- Look for `saas_billing` in left sidebar

**Still having issues?**
- Use SQLite (Option 4) - easiest solution!

---

## 🎯 Next Steps

Once database is set up:

1. ✅ Database created
2. ✅ Migrations run  
3. ✅ Data seeded
4. 🚀 `php artisan serve`
5. 🎨 `cd ..\flutter_app && flutter run -d chrome`
6. 🔐 Login: `admin@example.com` / `password123`
