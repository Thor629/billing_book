# Quick Fix - Enable ZIP Extension

The Composer installation is working but very slow because the ZIP extension is disabled in PHP.

## Fix in 3 Easy Steps:

### Step 1: Open php.ini
1. Open file: `C:\xampp\php\php.ini` in Notepad
2. Press `Ctrl+F` to search

### Step 2: Find and Enable ZIP
1. Search for: `;extension=zip`
2. Remove the semicolon `;` so it becomes: `extension=zip`
3. Save the file

### Step 3: Restart and Continue
1. If XAMPP is running, restart it
2. Run: `SETUP_WITH_XAMPP.bat` again

---

## Alternative: Let the Installation Continue

The installation IS working, it's just slow (downloading from Git instead of ZIP files).

You can:
1. Wait for it to complete (may take 10-15 minutes)
2. Or follow the steps above to speed it up

---

## After Installation Completes

Once Composer finishes installing dependencies, run these commands in the `backend` folder:

```bash
C:\xampp\php\php.exe artisan key:generate
C:\xampp\php\php.exe artisan migrate:fresh --seed
```

Then start the server:
```bash
C:\xampp\php\php.exe artisan serve
```

Your API will be at: http://localhost:8000
