# GST Report Module - Testing Guide

## Prerequisites

Before testing, ensure you have:
1. Backend server running
2. Flutter app running
3. At least one organization created
4. Some sales and purchase invoices with GST

## Step-by-Step Testing Guide

### Step 1: Add Navigation to GST Report

First, add a menu item to access the GST Report screen.

**Option A: Add to User Dashboard Sidebar**

Open `flutter_app/lib/screens/user/user_dashboard.dart` and find the drawer menu items. Add this after the "Cash & Bank" menu item:

```dart
ListTile(
  leading: const Icon(Icons.assessment, color: AppColors.textSecondary),
  title: const Text('GST Report'),
  onTap: () {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GstReportScreen(),
      ),
    );
  },
),
```

Don't forget to import the screen at the top:
```dart
import 'screens/user/gst_report_screen.dart';
```

**Option B: Add as a Button on Dashboard**

Add this button widget anywhere on your dashboard:

```dart
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GstReportScreen(),
      ),
    );
  },
  icon: const Icon(Icons.assessment),
  label: const Text('GST Report'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
),
```

### Step 2: Start Backend Server

```bash
cd backend
php artisan serve
```

The server should start at `http://localhost:8000`

### Step 3: Start Flutter App

```bash
cd flutter_app
flutter run
```

Or press F5 in VS Code if you have the Flutter extension.

### Step 4: Create Test Data (If Needed)

If you don't have sales/purchase invoices, create some test data:

#### Create Sales Invoices:
1. Go to Sales → Sales Invoice
2. Create 2-3 invoices with different GST rates:
   - Invoice 1: Items with 18% GST
   - Invoice 2: Items with 12% GST
   - Invoice 3: Items with 5% GST

#### Create Purchase Invoices:
1. Go to Purchases → Purchase Invoice
2. Create 2-3 invoices with different GST rates:
   - Invoice 1: Items with 18% GST
   - Invoice 2: Items with 12% GST

### Step 5: Test GST Report

#### Test 1: Access the Screen
1. Click on "GST Report" from the menu
2. ✅ Screen should load with orange header
3. ✅ Should show three tabs: Summary, By GST Rate, Transactions
4. ✅ Date filter should show current month dates

#### Test 2: Summary Tab
1. Click on "Summary" tab (should be selected by default)
2. ✅ Should show three metric cards:
   - Output GST (Sales) - Green card
   - Input GST (Purchase) - Blue card
   - Net GST Liability - Red/Green card
3. ✅ Should show detailed breakdown table below
4. ✅ All amounts should be formatted as ₹X,XXX.XX

**Expected Calculations:**
- Output GST = Sum of all sales invoice tax amounts
- Input GST = Sum of all purchase invoice tax amounts
- Net GST Liability = Output GST - Input GST

#### Test 3: By GST Rate Tab
1. Click on "By GST Rate" tab
2. ✅ Should show two tables:
   - Sales GST by Rate
   - Purchase GST by Rate
3. ✅ Each table should show:
   - GST Rate (0%, 5%, 12%, 18%, 28%)
   - Taxable Amount
   - GST Amount
   - Invoice Count
4. ✅ Orange header with white text
5. ✅ Warm peach background

#### Test 4: Transactions Tab
1. Click on "Transactions" tab
2. ✅ Should show all sales and purchase invoices
3. ✅ Each row should display:
   - Date
   - Type (Sales/Purchase badge)
   - Invoice Number
   - Party Name
   - GSTIN
   - Taxable Amount
   - GST Amount
   - Total Amount
4. ✅ Should be sorted by date (newest first)

#### Test 5: Date Filter
1. Click on "Start Date" button
2. Select a date from 3 months ago
3. ✅ Date should update
4. ✅ Data should reload automatically
5. Click on "End Date" button
6. Select today's date
7. ✅ Should show data for the selected period
8. ✅ All three tabs should reflect the new date range

#### Test 6: Refresh Button
1. Click the "Refresh" button (black button with refresh icon)
2. ✅ Should show loading indicator
3. ✅ Data should reload
4. ✅ All calculations should update

### Step 6: Verify Calculations

#### Manual Verification:
1. Go to Sales Invoices screen
2. Note down the tax amounts from 2-3 invoices
3. Add them up manually
4. Go to GST Report → Summary
5. ✅ Output GST should match your manual calculation

6. Go to Purchase Invoices screen
7. Note down the tax amounts from 2-3 invoices
8. Add them up manually
9. Go to GST Report → Summary
10. ✅ Input GST should match your manual calculation

11. Calculate: Output GST - Input GST
12. ✅ Net GST Liability should match your calculation

### Step 7: Test Edge Cases

#### Test Empty Data:
1. Select a date range with no invoices
2. ✅ Should show zero amounts
3. ✅ Should not crash

#### Test Single Invoice:
1. Select a date range with only 1 invoice
2. ✅ Should display correctly
3. ✅ Calculations should be accurate

#### Test Large Numbers:
1. Create invoices with large amounts (₹1,00,000+)
2. ✅ Should format correctly with commas
3. ✅ Should not overflow

### Step 8: Test API Endpoints (Optional)

You can test the backend APIs directly using a tool like Postman or curl:

#### Test Summary Endpoint:
```bash
curl -X GET "http://localhost:8000/api/gst-reports/summary?organization_id=1&start_date=2024-01-01&end_date=2024-12-31" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

#### Test By Rate Endpoint:
```bash
curl -X GET "http://localhost:8000/api/gst-reports/by-rate?organization_id=1&start_date=2024-01-01&end_date=2024-12-31" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

#### Test Transactions Endpoint:
```bash
curl -X GET "http://localhost:8000/api/gst-reports/transactions?organization_id=1&start_date=2024-01-01&end_date=2024-12-31&type=all" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

Replace `YOUR_TOKEN` with your actual auth token.

## Common Issues & Solutions

### Issue 1: Screen Not Loading
**Solution:** 
- Check if backend is running: `http://localhost:8000/api/health`
- Check console for errors
- Verify organization is selected

### Issue 2: No Data Showing
**Solution:**
- Verify you have sales/purchase invoices in the database
- Check the date range includes your invoices
- Check organization_id matches your invoices

### Issue 3: Wrong Calculations
**Solution:**
- Verify invoice items have correct gst_rate
- Check tax_amount is calculated correctly in invoices
- Verify invoice_date is within selected range

### Issue 4: API Errors
**Solution:**
- Check backend logs: `backend/storage/logs/laravel.log`
- Verify database tables exist
- Check authentication token is valid

## Testing Checklist

- [ ] Navigation to GST Report works
- [ ] Screen loads without errors
- [ ] Summary tab displays correctly
- [ ] Output GST calculation is accurate
- [ ] Input GST calculation is accurate
- [ ] Net GST Liability is correct
- [ ] By GST Rate tab shows data
- [ ] Sales by rate breakdown is correct
- [ ] Purchase by rate breakdown is correct
- [ ] Transactions tab lists all invoices
- [ ] Date filter works
- [ ] Refresh button works
- [ ] UI matches design (orange header, peach background)
- [ ] All amounts formatted correctly
- [ ] No console errors
- [ ] Works with empty data
- [ ] Works with large numbers

## Performance Testing

1. Create 100+ invoices
2. Load GST Report
3. ✅ Should load within 2-3 seconds
4. ✅ Tables should scroll smoothly
5. ✅ No lag when switching tabs

## Success Criteria

The GST Report module is working correctly if:
1. All three tabs load without errors
2. Calculations match manual verification
3. Date filter updates data correctly
4. UI is consistent with app design
5. No console errors or warnings
6. Performance is acceptable with large datasets

## Next Steps After Testing

Once testing is complete:
1. Add export functionality (PDF/Excel)
2. Add GSTR-1/GSTR-3B format reports
3. Add email scheduling for monthly reports
4. Add year-over-year comparison
5. Add graphical charts for visual representation

## Support

If you encounter any issues during testing, check:
1. Backend logs: `backend/storage/logs/laravel.log`
2. Flutter console output
3. Browser developer console (if using web)
4. Database query results

The module follows all existing patterns in your codebase and should work seamlessly with your current setup.
