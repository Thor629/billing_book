# Fintech Color Scheme Implementation Guide

## 🎨 Color Palette

The application now uses a modern fintech-inspired color scheme based on the provided design reference.

### Primary Accent Colors

```dart
// Yellow - For primary actions (Top up, Add new, Create)
accentYellow: #F4E4A6

// Green - For transfers, confirmations, success states
accentGreen: #C8E6C9

// Blue - For withdrawals, info, secondary actions
accentBlue: #B3E5FC
```

### Dark Theme Base

```dart
// Primary dark backgrounds
primaryDark: #1A1A1A
primary: #212121
primaryLight: #424242
```

### Usage Examples

## 🔘 Buttons

### Using FintechButton Widget

```dart
import 'package:your_app/widgets/fintech_button.dart';

// Yellow button (default - for primary actions)
FintechButton(
  text: 'Create Invoice',
  icon: Icons.add,
  style: FintechButtonStyle.yellow,
  onPressed: () {},
)

// Green button (for confirmations/transfers)
FintechButton(
  text: 'Transfer',
  icon: Icons.swap_horiz,
  style: FintechButtonStyle.green,
  onPressed: () {},
)

// Blue button (for info/secondary actions)
FintechButton(
  text: 'View Details',
  icon: Icons.info_outline,
  style: FintechButtonStyle.blue,
  onPressed: () {},
)

// Dark button (for critical actions)
FintechButton(
  text: 'Delete',
  icon: Icons.delete,
  style: FintechButtonStyle.dark,
  onPressed: () {},
)
```

### Icon Buttons for Services

```dart
// Compact icon button (like in the fintech app services section)
FintechIconButton(
  icon: Icons.add,
  label: 'Add new',
  style: FintechButtonStyle.yellow,
  onPressed: () {},
)

FintechIconButton(
  icon: Icons.people,
  label: 'Family',
  style: FintechButtonStyle.green,
  onPressed: () {},
)
```

## 📦 Cards

### Standard Card

```dart
import 'package:your_app/widgets/fintech_card.dart';

FintechCard(
  child: Column(
    children: [
      Text('Card Content'),
      // ... more widgets
    ],
  ),
)
```

### Accent Card (for highlights)

```dart
FintechAccentCard(
  accentColor: AppColors.accentGreen,
  child: Row(
    children: [
      Icon(Icons.person),
      Text('Lewis Baldwin'),
      Text('+ \$1,220.00'),
    ],
  ),
)
```

### Balance Display Card

```dart
FintechBalanceCard(
  title: 'Total Balance',
  amount: '16,008.00',
  currency: 'USD',
  actions: [
    FintechButton(
      text: 'Top up',
      icon: Icons.add,
      style: FintechButtonStyle.yellow,
      onPressed: () {},
    ),
    FintechButton(
      text: 'Transfer',
      icon: Icons.swap_horiz,
      style: FintechButtonStyle.green,
      onPressed: () {},
    ),
  ],
)
```

## 🎯 Color Usage Guidelines

### When to Use Each Color

**Yellow (#F4E4A6)**
- Primary actions (Create, Add, Save)
- Call-to-action buttons
- "Top up" or increase actions
- New item creation

**Green (#C8E6C9)**
- Transfers and movements
- Confirmations
- Success states
- Positive financial actions
- Family/group related features

**Blue (#B3E5FC)**
- Withdrawals
- Information displays
- Secondary actions
- Friend/social features
- View/read actions

**Dark (#1A1A1A)**
- Critical actions (Delete, Cancel)
- Navigation bars
- Headers
- Background sections

## 🔄 Migration from Old Colors

### Replace Old Button Styles

**Before:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryDark,
  ),
  child: Text('Save'),
  onPressed: () {},
)
```

**After:**
```dart
FintechButton(
  text: 'Save',
  style: FintechButtonStyle.yellow,
  onPressed: () {},
)
```

### Update Card Styles

**Before:**
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: content,
  ),
)
```

**After:**
```dart
FintechCard(
  child: content,
)
```

## 📱 Screen Examples

### Dashboard with Balance Card

```dart
Column(
  children: [
    FintechBalanceCard(
      title: 'Total Revenue',
      amount: '45,230.00',
      currency: 'USD',
      actions: [
        FintechButton(
          text: 'New Invoice',
          icon: Icons.receipt,
          style: FintechButtonStyle.yellow,
          onPressed: () => _createInvoice(),
        ),
        FintechButton(
          text: 'View Reports',
          icon: Icons.analytics,
          style: FintechButtonStyle.blue,
          onPressed: () => _viewReports(),
        ),
      ],
    ),
    SizedBox(height: 20),
    // Services grid
    GridView.count(
      crossAxisCount: 3,
      children: [
        FintechIconButton(
          icon: Icons.receipt,
          label: 'Invoices',
          style: FintechButtonStyle.yellow,
          onPressed: () {},
        ),
        FintechIconButton(
          icon: Icons.people,
          label: 'Parties',
          style: FintechButtonStyle.green,
          onPressed: () {},
        ),
        FintechIconButton(
          icon: Icons.inventory,
          label: 'Items',
          style: FintechButtonStyle.blue,
          onPressed: () {},
        ),
      ],
    ),
  ],
)
```

## 🎨 Direct Color Access

If you need to use colors directly:

```dart
import 'package:your_app/core/constants/app_colors.dart';

Container(
  color: AppColors.accentYellow,
  child: Text(
    'Custom styled widget',
    style: TextStyle(color: AppColors.buttonTextDark),
  ),
)
```

## ✅ Best Practices

1. **Use FintechButton** instead of ElevatedButton for consistency
2. **Use FintechCard** for all card-based layouts
3. **Choose colors based on action type**, not randomly
4. **Maintain contrast** - use buttonTextDark on accent colors
5. **Use dark backgrounds** for headers and navigation
6. **Keep white cards** for content areas

## 🚀 Quick Start Checklist

- [ ] Import fintech widgets in your screen files
- [ ] Replace ElevatedButton with FintechButton
- [ ] Replace Card with FintechCard
- [ ] Update primary action buttons to yellow
- [ ] Update transfer/confirm buttons to green
- [ ] Update info/view buttons to blue
- [ ] Test color contrast and readability
- [ ] Verify dark mode compatibility (if applicable)

## 📝 Notes

- All colors are defined in `lib/core/constants/app_colors.dart`
- Widget components are in `lib/widgets/fintech_button.dart` and `fintech_card.dart`
- The theme is configured in `lib/main.dart`
- Border radius is consistently 16-20px for modern look
- Shadows are subtle (4-10px blur) for depth
