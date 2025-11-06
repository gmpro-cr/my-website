# Credit Card Pay - iOS App

A native iOS application for managing and paying credit card bills using UPI, built with SwiftUI and following the MVVM architecture pattern.

## Features

### 🔐 Authentication
- Secure login screen with password visibility toggle
- Form validation with real-time error messages
- Loading states during authentication
- Session management

### 📊 Dashboard
- Personalized welcome screen
- Quick stats cards:
  - Total Due Amount
  - Active Cards Count
  - Upcoming Payments
  - Paid This Month
- Payment reminders for overdue and upcoming dues
- Credit cards overview with quick actions
- Recent transactions across all cards
- Payment history with transaction IDs

### 💳 Credit Card Management
- View all credit cards
- Detailed card information:
  - Total due and minimum due
  - Due date
  - Credit limit and available credit
  - Transaction history
- Visual indicators for overdue payments

### 💰 Payment Features
- Multiple payment amount options:
  - Minimum due
  - Total due
  - Custom amount
- UPI payment methods:
  - Google Pay
  - PhonePe
  - Paytm
  - Direct UPI ID
- Payment processing simulation
- Transaction ID generation
- Payment success confirmation

### ⚙️ Settings
- Dark mode toggle
- Account information
- Help & FAQ section
- Secure logout

## Architecture

### MVVM Pattern
- **Models**: `CreditCard`, `Transaction`, `Payment`
- **Views**: SwiftUI views for all screens
- **ViewModels**: `AuthViewModel`, `CardViewModel`
- **Services**: `PersistenceController` for CoreData

### Project Structure
```
CreditCardPayApp/
├── CreditCardPayApp/
│   ├── Models/
│   │   ├── CreditCard.swift
│   │   ├── Transaction.swift
│   │   └── Payment.swift
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift
│   │   └── CardViewModel.swift
│   ├── Views/
│   │   ├── LoginView.swift
│   │   ├── DashboardView.swift
│   │   ├── CardDetailView.swift
│   │   ├── PaymentView.swift
│   │   ├── PaymentSuccessView.swift
│   │   ├── SettingsView.swift
│   │   ├── CardsListView.swift
│   │   └── Components/
│   │       ├── StatCard.swift
│   │       ├── CreditCardRow.swift
│   │       └── TransactionRow.swift
│   ├── Services/
│   │   └── PersistenceController.swift
│   ├── Resources/
│   │   └── CreditCardPayApp.xcdatamodeld/
│   ├── CreditCardPayAppApp.swift
│   └── Info.plist
└── README.md
```

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository
2. Open `CreditCardPayApp.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (⌘R)

## Usage

### Demo Credentials
- Username: `demo`
- Password: `demo123`

### Sample Data
The app comes with 3 pre-configured credit cards:
1. HDFC Bank - ₹45,678 due
2. SBI Card - ₹23,450 due
3. ICICI Bank - ₹67,890 due

### Making a Payment
1. Login with demo credentials
2. Select a credit card from the dashboard
3. Tap "Pay Now"
4. Choose payment amount (minimum, total, or custom)
5. Select UPI payment method
6. Tap "Proceed to Pay"
7. View transaction ID and payment confirmation

## Key Features

### iOS Native Components
- SwiftUI for modern UI development
- NavigationView for screen navigation
- @StateObject and @EnvironmentObject for state management
- @AppStorage for user preferences
- Native iOS animations and transitions
- SF Symbols for icons

### Data Persistence
- UserDefaults for payment history
- CoreData setup for future enhancements
- Local data storage (no external servers)

### Dark Mode Support
- System-wide dark mode toggle
- Preference persisted across sessions
- Optimized color schemes for both themes

### Accessibility
- VoiceOver support
- Dynamic Type support
- High contrast text
- Clear visual hierarchy

## Development

### Adding New Features

#### Add a New Card
Update `CardViewModel.swift` in the `loadSampleData()` method:

```swift
cards.append(CreditCard(
    bank: "Your Bank",
    cardNumber: "1234 5678 9012 3456",
    totalDue: 10000,
    minimumDue: 1000,
    dueDate: Date(),
    creditLimit: 100000,
    availableCredit: 90000
))
```

#### Customize Colors
Modify the `Color` extensions in `LoginView.swift` or create a new theme file.

## Testing

Run unit tests:
```bash
⌘U in Xcode
```

## Future Enhancements

- [ ] Biometric authentication (Face ID / Touch ID)
- [ ] Push notifications for due dates
- [ ] Bill payment reminders
- [ ] Export payment history
- [ ] Multiple user accounts
- [ ] Credit score integration
- [ ] Rewards tracking
- [ ] EMI calculator

## License

This is a demo project created for educational purposes.

## Support

For issues or questions, please check the Help & FAQ section in the app settings.

---

**Note**: This is a demo application with simulated payment processing. No real payments are processed, and no data is sent to external servers.
