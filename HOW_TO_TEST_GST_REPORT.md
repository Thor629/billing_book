# How to Test GST Report - Simple Guide

## What I Did

I added a "GST Report" button to your app's sidebar menu. It's right after "Cash & Bank".

## How to See It

### Step 1: Make Sure Backend is Running
Open a terminal and run:
```bash
cd backend
php artisan serve
```

Keep this terminal open. You should see: `Laravel development server started: http://127.0.0.1:8000`

### Step 2: Run Your Flutter App
Open another terminal and run:
```bash
cd flutter_app
flutter run
```

Or just press **F5** in VS Code.

### Step 3: Find the GST Report Button
1. Login to your app
2. Look at the left sidebar menu
3. You'll see a new menu item: **"GST Report"** with a chart icon 📊
4. It's located right after "Cash & Bank"

### Step 4: Click on GST Report
Click the "GST Report" button and you'll see:

**Three Tabs at the Top:**
1. **Summary** - Shows your GST overview
2. **By GST Rate** - Shows breakdown by 0%, 5%, 12%, 18%, 28%
3. **Transactions** - Shows all your invoices

## What You'll See

### Summary Tab (Default View)
You'll see 3 colorful cards:

1. **Output GST (Sales)** - Green card
   - This is GST you collected from customers
   - From all your sales invoices

2. **Input GST (Purchase)** - Blue card
   - This is GST you paid to suppliers
   - From all your purchase invoices

3. **Net GST Liability** - Red/Green card
   - This is what you owe to government
   - Formula: Output GST - Input GST
   - If positive (red): You need to pay this amount
   - If negative (green): Government owes you refund

Below the cards, you'll see a detailed breakdown table.

### By GST Rate Tab
Click this tab to see:
- How much GST at 0% rate
- How much GST at 5% rate
- How much GST at 12% rate
- How much GST at 18% rate
- How much GST at 28% rate

Separate tables for Sales and Purchases.

### Transactions Tab
Click this tab to see:
- List of all your sales and purchase invoices
- Date, Invoice Number, Party Name
- GSTIN (GST number)
- Amounts with GST breakdown

## Date Filter

At the top, you'll see two date buttons:
- **Start Date** - Click to change from date
- **End Date** - Click to change to date
- **Refresh** button - Click to reload data

Default shows last 30 days.

## If You Don't See Any Data

That's normal if you haven't created any invoices yet!

**To create test data:**

1. Go to **Sales → Sales Invoice**
2. Create a new invoice with some items
3. Make sure items have GST rates (5%, 12%, 18%, etc.)
4. Save the invoice

5. Go to **Purchases → Purchase Invoice**
6. Create a purchase invoice
7. Save it

8. Now go back to **GST Report**
9. You should see the data!

## Quick Test

1. Create 1 sales invoice for ₹1,000 with 18% GST (₹180 tax)
2. Create 1 purchase invoice for ₹500 with 18% GST (₹90 tax)
3. Go to GST Report
4. You should see:
   - Output GST: ₹180
   - Input GST: ₹90
   - Net GST Liability: ₹90 (you owe government)

## Troubleshooting

### Problem: "GST Report" button not showing
**Solution:** 
- Stop the app (Ctrl+C)
- Run `flutter clean`
- Run `flutter pub get`
- Run `flutter run` again

### Problem: Screen is blank or loading forever
**Solution:**
- Check if backend is running (Step 1)
- Check if you're logged in
- Check if you have an organization selected

### Problem: Shows all zeros
**Solution:**
- This is normal if you have no invoices
- Create some sales/purchase invoices first
- Make sure the date range includes your invoices

### Problem: Error message appears
**Solution:**
- Check backend terminal for errors
- Make sure database is set up
- Try refreshing the page

## What This Report Does

**For Business Owners:**
- Shows how much GST you collected from customers
- Shows how much GST you paid to suppliers
- Calculates what you owe to government
- Helps with GST return filing

**For Accountants:**
- Quick GST summary for the month
- Rate-wise breakdown for GSTR-1
- Transaction details for verification
- Export ready (coming soon)

## Visual Guide

```
┌─────────────────────────────────────────┐
│  Sidebar Menu                           │
├─────────────────────────────────────────┤
│  📊 Dashboard                           │
│  👥 Parties                             │
│  📦 Items                               │
│  🏢 Godowns                             │
│  ▼ Sales                                │
│  ▼ Purchases                            │
│  💰 Cash & Bank                         │
│  📊 GST Report  ← NEW! CLICK HERE      │
│  📧 E-Invoicing                         │
│  💵 Expenses                            │
└─────────────────────────────────────────┘
```

## Next Steps

Once you see the GST Report working:
1. Try changing date ranges
2. Create more invoices with different GST rates
3. Check if calculations match your expectations
4. Use it for your monthly GST filing

## Need Help?

If something doesn't work:
1. Check both terminals are running
2. Look for error messages in red
3. Make sure you have invoices in the date range
4. Try the refresh button

The GST Report is now live in your app! Just click the button in the sidebar and explore.
