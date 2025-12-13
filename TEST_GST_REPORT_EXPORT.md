# Quick Test Guide - GST Report Export & Share

## 🚀 Quick Start

### 1. Run the App
```bash
cd flutter_app
flutter run
```

### 2. Navigate to GST Report
1. Login to the app
2. Go to **Reports** section
3. Click on **GST Report**

### 3. Test Export PDF
1. Select a date range with data
2. Click **"Export PDF"** button (orange)
3. Wait for PDF generation
4. Preview the PDF
5. Download or print

### 4. Test WhatsApp Share
1. Click **"Share"** button (green)
2. Choose **"Share on WhatsApp"**
3. Select a contact
4. Send the message with PDF

## 📊 Expected Results

### PDF Should Contain:
- ✅ Organization name and date range
- ✅ Summary cards (Output GST, Input GST, Net Liability)
- ✅ Detailed breakdown table
- ✅ GST by Rate tables (if data exists)
- ✅ Transactions table (if data exists)

### Share Options Should Show:
- ✅ Share on WhatsApp (green icon)
- ✅ Share via Other Apps (blue icon)
- ✅ Share Text Only (grey icon)

### WhatsApp Message Should Include:
```
📊 *GST Report*
[Date Range]

💰 *Summary*
Output GST (Sales): ₹[amount]
Input GST (Purchase): ₹[amount]
Net GST Liability: ₹[amount]

📄 Detailed report attached.
```

## 🐛 Troubleshooting

### Issue: "No data to export"
**Solution**: Create some sales/purchase invoices first

### Issue: WhatsApp not opening
**Solution**: 
1. Make sure WhatsApp is installed
2. Try "Share via Other Apps" instead
3. Manually select WhatsApp from the share menu

### Issue: PDF not generating
**Solution**:
1. Check console for errors
2. Ensure all packages are installed (`flutter pub get`)
3. Restart the app

### Issue: Backend errors
**Solution**:
1. Make sure backend is running
2. Check Laravel logs: `backend/storage/logs/laravel.log`
3. Verify database has data

## ✅ Success Indicators

- [ ] PDF generates without errors
- [ ] PDF preview shows correctly
- [ ] All data appears in PDF
- [ ] Share modal opens
- [ ] WhatsApp opens with message
- [ ] PDF attaches to WhatsApp
- [ ] Can share via email/other apps

## 🎯 Test Scenarios

### Scenario 1: With Data
1. Create 2-3 sales invoices
2. Create 1-2 purchase invoices
3. Generate GST report
4. Export PDF
5. Share on WhatsApp

### Scenario 2: Without Data
1. Select date range with no invoices
2. Should show "No data" message
3. Export should be disabled or show empty report

### Scenario 3: Large Dataset
1. Create 10+ invoices
2. Generate report
3. PDF should handle pagination
4. Transactions limited to 50 with note

## 📱 Platform-Specific Notes

### Android
- PDF saves to Downloads folder
- WhatsApp share works directly
- May need storage permissions

### iOS
- PDF saves to Files app
- WhatsApp share via share sheet
- No special permissions needed

### Web
- PDF downloads to browser
- WhatsApp opens in web browser
- Share API may vary by browser

## 🎉 All Done!

If all tests pass, the GST Report export and share functionality is working perfectly!
