# GST Report - Complete Explanation & Testing Guide

## What is GST Report?

GST Report is a tool that helps you track and calculate your GST (Goods and Services Tax) obligations. It shows:
- How much GST you collected from customers (Output GST)
- How much GST you paid to suppliers (Input GST)
- How much you need to pay to the government (Net GST Liability)

## How It Works - Simple Explanation

### The Concept

Imagine you run a shop:

1. **When you SELL something:**
   - You charge customer ₹1,000 + 18% GST (₹180)
   - Customer pays you ₹1,180 total
   - You collected ₹180 as GST (this is **Output GST**)

2. **When you BUY something:**
   - Supplier charges you ₹500 + 18% GST (₹90)
   - You pay supplier ₹590 total
   - You paid ₹90 as GST (this is **Input GST**)

3. **At month end:**
   - You collected ₹180 from customers
   - You paid ₹90 to suppliers
   - You owe government: ₹180 - ₹90 = ₹90 (this is **Net GST Liability**)

## How to Test - Step by Step

### Step 1: Start Your Backend Server

Open a terminal/command prompt:
```bash
cd backend
php artisan serve
```

**What you should see:**
```
Laravel development server started: http://127.0.0.1:8000
```

Keep this terminal open!

### Step 2: Start Your Flutter App

Open another terminal:
```bash
cd flutter_app
flutter run
```

**Or** press **F5** in VS Code

Wait for the app to load (takes 1-2 minutes first time)

### Step 3: Login to Your App

1. Enter your email and password
2. Click Login
3. You should see the dashboard

### Step 4: Find GST Report

Look at the left sidebar menu:
- Scroll down to "ACCOUNTING SOLUTIONS" section
- You'll see "GST Report" with a chart icon 📊
- It's right after "Cash & Bank"

**Click on "GST Report"**

### Step 5: What You'll See

The screen has 3 main parts:

#### A. Date Filter (Top)
- **Start Date**: Shows "12 Nov 2025" (or current date)
- **End Date**: Shows "12 Dec 2025" (or current date)
- **Refresh Button**: Black button to reload data

#### B. Three Tabs (Below date filter)
1. **Summary** - Overview of your GST
2. **By GST Rate** - Breakdown by tax rates
3. **Transactions** - List of all invoices

#### C. Content Area
Shows data based on selected tab

## Understanding Each Tab

### Tab 1: Summary (Default View)

You'll see 3 colorful cards:

#### Card 1: Output GST (Sales) - Green
```
┌─────────────────────────┐
│ 📈 Output GST (Sales)   │
│                         │
│ ₹0.00                   │
└─────────────────────────┘
```
- This is GST you collected from customers
- Comes from all your Sales Invoices
- Green color = Money you collected

#### Card 2: Input GST (Purchase) - Blue
```
┌─────────────────────────┐
│ 📉 Input GST (Purchase) │
│                         │
│ ₹0.00                   │
└─────────────────────────┘
```
- This is GST you paid to suppliers
- Comes from all your Purchase Invoices
- Blue color = Money you paid

#### Card 3: Net GST Liability - Red/Green
```
┌─────────────────────────┐
│ 💰 Net GST Liability    │
│                         │
│ ₹0.00                   │
└─────────────────────────┘
```
- This is what you owe to government
- Formula: Output GST - Input GST
- Red = You owe money
- Green = Government owes you refund

#### Detailed Breakdown Table
Below the cards, you'll see a table with:
- Sales Taxable Amount
- Sales GST
- Total Sales
- Purchase Taxable Amount
- Purchase GST
- Total Purchase

### Tab 2: By GST Rate

Shows two tables:

#### Sales GST by Rate
```
┌──────────┬─────────────────┬────────────┬──────────────┐
│ GST Rate │ Taxable Amount  │ GST Amount │ Invoice Count│
├──────────┼─────────────────┼────────────┼──────────────┤
│ 0%       │ ₹0.00          │ ₹0.00      │ 0            │
│ 5%       │ ₹0.00          │ ₹0.00      │ 0            │
│ 12%      │ ₹0.00          │ ₹0.00      │ 0            │
│ 18%      │ ₹0.00          │ ₹0.00      │ 0            │
│ 28%      │ ₹0.00          │ ₹0.00      │ 0            │
└──────────┴─────────────────┴────────────┴──────────────┘
```

#### Purchase GST by Rate
Same format as above, but for purchases

**What this shows:**
- How much GST at each rate (0%, 5%, 12%, 18%, 28%)
- Helps you fill GSTR-1 form
- Shows which products have which tax rates

### Tab 3: Transactions

Shows a list of all invoices:
```
┌────────────┬──────────┬──────────────┬────────────┬────────┬─────────────────┬────────────┬───────┐
│ Date       │ Type     │ Invoice No   │ Party Name │ GSTIN  │ Taxable Amount  │ GST Amount │ Total │
├────────────┼──────────┼──────────────┼────────────┼────────┼─────────────────┼────────────┼───────┤
│ 12 Dec 2025│ Sales    │ SI-001       │ Customer A │ 123... │ ₹1,000.00      │ ₹180.00    │₹1,180 │
│ 11 Dec 2025│ Purchase │ PI-001       │ Supplier B │ 456... │ ₹500.00        │ ₹90.00     │₹590   │
└────────────┴──────────┴──────────────┴────────────┴────────┴─────────────────┴────────────┴───────┘
```

**What this shows:**
- Every sales and purchase invoice
- Date, invoice number, party name
- GST number (GSTIN)
- Amount breakdown

## Creating Test Data

Right now you'll see ₹0.00 everywhere because you have no invoices. Let's create some!

### Create a Sales Invoice (To see Output GST)

1. **Go to Sales → Sales Invoice**
2. **Click "Create Sales Invoice"** (black button)
3. **Fill in the form:**
   - Party Name: Select or create a customer
   - Invoice Date: Today's date
   - Add Items:
     - Click "Add Item"
     - Select an item (or create one)
     - Quantity: 10
     - Price: ₹100
     - GST Rate: 18%
     - The system will calculate: Tax = ₹180
4. **Click Save**

**What happens:**
- Total Amount: ₹1,180 (₹1,000 + ₹180 GST)
- This ₹180 will show in Output GST

### Create a Purchase Invoice (To see Input GST)

1. **Go to Purchases → Purchase Invoice**
2. **Click "Create Purchase Invoice"**
3. **Fill in the form:**
   - Party Name: Select or create a supplier
   - Invoice Date: Today's date
   - Add Items:
     - Click "Add Item"
     - Select an item
     - Quantity: 5
     - Price: ₹100
     - GST Rate: 18%
     - Tax = ₹90
4. **Click Save**

**What happens:**
- Total Amount: ₹590 (₹500 + ₹90 GST)
- This ₹90 will show in Input GST

### View the Results

1. **Go back to GST Report**
2. **Click Refresh button** (black button, top right)
3. **You should now see:**
   - Output GST: ₹180.00 (green card)
   - Input GST: ₹90.00 (blue card)
   - Net GST Liability: ₹90.00 (red card)

## Testing Different Scenarios

### Scenario 1: Multiple GST Rates

Create invoices with different GST rates:
- Invoice 1: Items with 5% GST
- Invoice 2: Items with 12% GST
- Invoice 3: Items with 18% GST

Then check "By GST Rate" tab to see breakdown.

### Scenario 2: Date Range Filter

1. Create invoices on different dates
2. In GST Report, click "Start Date"
3. Select a date from last month
4. Click "End Date"
5. Select today
6. Data will update automatically

### Scenario 3: More Purchases than Sales

Create:
- 1 Sales Invoice: ₹1,000 + ₹180 GST
- 2 Purchase Invoices: ₹1,500 + ₹270 GST

Result:
- Output GST: ₹180
- Input GST: ₹270
- Net GST Liability: -₹90 (negative = government owes you!)

## How the Calculation Works

### Behind the Scenes

1. **When you click GST Report:**
   - App sends request to backend server
   - Backend queries database for all invoices
   - Backend calculates totals
   - Backend sends data back to app
   - App displays the data

2. **The SQL queries:**
   ```sql
   -- For Output GST
   SELECT SUM(tax_amount) FROM sales_invoices 
   WHERE organization_id = YOUR_ORG 
   AND invoice_date BETWEEN start_date AND end_date

   -- For Input GST
   SELECT SUM(tax_amount) FROM purchase_invoices 
   WHERE organization_id = YOUR_ORG 
   AND invoice_date BETWEEN start_date AND end_date
   ```

3. **The calculation:**
   ```
   Net GST Liability = Output GST - Input GST
   ```

## Real-World Example

Let's say you run a mobile shop for December 2025:

### Your Sales (What you sold):
1. Sold Phone A: ₹10,000 + 18% GST (₹1,800) = ₹11,800
2. Sold Phone B: ₹15,000 + 18% GST (₹2,700) = ₹17,700
3. Sold Charger: ₹500 + 18% GST (₹90) = ₹590

**Total Output GST = ₹1,800 + ₹2,700 + ₹90 = ₹4,590**

### Your Purchases (What you bought):
1. Bought Phone A from supplier: ₹8,000 + 18% GST (₹1,440) = ₹9,440
2. Bought Phone B from supplier: ₹12,000 + 18% GST (₹2,160) = ₹14,160
3. Bought Chargers: ₹300 + 18% GST (₹54) = ₹354

**Total Input GST = ₹1,440 + ₹2,160 + ₹54 = ₹3,654**

### Your GST Report will show:
- **Output GST (Sales)**: ₹4,590 (green card)
- **Input GST (Purchase)**: ₹3,654 (blue card)
- **Net GST Liability**: ₹936 (red card)

**This means you need to pay ₹936 to the government for December.**

## Common Questions

### Q: Why am I seeing ₹0.00?
**A:** You haven't created any invoices yet. Create some sales and purchase invoices first.

### Q: Can I change the date range?
**A:** Yes! Click on Start Date and End Date buttons at the top to select different dates.

### Q: What if I see an error?
**A:** Make sure:
1. Backend server is running
2. You're logged in
3. You have an organization selected
4. Try clicking the Refresh button

### Q: How often should I check this?
**A:** Check it monthly before filing your GST return (usually by 20th of next month).

### Q: Can I export this data?
**A:** The export button is there (download icon) but not yet implemented. Coming soon!

## Tips for Using GST Report

1. **Check Monthly**: Review your GST report at the end of each month
2. **Verify Invoices**: Use the Transactions tab to verify all invoices are included
3. **Check Rates**: Use By GST Rate tab to ensure correct tax rates
4. **Keep Records**: Take screenshots or export data for your records
5. **Match with Books**: Compare with your accounting books to ensure accuracy

## Troubleshooting

### Problem: Screen shows "No data"
**Solution:** 
- Create some invoices first
- Check if date range includes your invoices
- Click Refresh button

### Problem: Numbers don't match my records
**Solution:**
- Check the date range
- Verify all invoices are saved properly
- Check if GST rates are correct on items

### Problem: App crashes or shows error
**Solution:**
- Restart the app
- Check if backend is running
- Check console for error messages

## Next Steps

Once you're comfortable with GST Report:
1. Use it for monthly GST filing
2. Compare with GSTR-2A from GST portal
3. File GSTR-1 and GSTR-3B using this data
4. Keep monthly records for audit purposes

## Summary

The GST Report is your tool to:
- ✅ Track GST collected from customers
- ✅ Track GST paid to suppliers
- ✅ Calculate what you owe to government
- ✅ Prepare for GST return filing
- ✅ Maintain proper GST records

It's simple, automatic, and saves you hours of manual calculation!
