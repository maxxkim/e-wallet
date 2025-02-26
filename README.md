# Zentro Wallet (^ω^) ✨

## Overview UwU

Zentro Wallet is a modern mobile payment application built with Flutter that allows users to manage their financial transactions with ease! The app provides a seamless experience for transferring money, scanning QR codes for payments, tracking transaction history, and taking advantage of special offers and discounts from various merchants. (≧◡≦)

## Features (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧

### Core Functionality
- **User Authentication**: Secure login via SMS verification
- **Dashboard**: View balance and recent transactions at a glance
- **Transaction History**: Filter and search through past transactions
- **Transfer Money**: Send money to contacts or other users
- **Top Up**: Add funds to your wallet through various payment providers
- **Withdrawal**: Cash out your wallet balance
- **QR Code Payments**: Scan QR codes to make quick payments
- **Offers**: Discover and activate special discounts from merchants

### Technical Features
- **Multilingual Support**: Available in English and Spanish
- **Theme Switching**: Toggle between light and dark themes
- **Contact Management**: Add, edit and manage payment contacts
- **Offline Capability**: View cached data when offline
- **Transaction Sharing**: Share transaction details with others

## Project Structure ʕ•ᴥ•ʔ

```
lib/
├── data/               # Data layer with repositories and API connections
│   ├── api/            # API service implementations
│   ├── mapper/         # Data mapping between API and domain models
│   └── repository/     # Repository implementations
├── domain/             # Domain layer with business logic
│   ├── model/          # Business models
│   ├── repository/     # Repository interfaces
│   └── state/          # State management for business logic
├── presentation/       # UI layer
│   ├── animation/      # Animation utilities
│   ├── bloc/           # BLoC state management
│   ├── screen/         # UI screens
│   ├── session/        # Authentication session management
│   ├── theme/          # App theming
│   └── widget/         # Reusable widgets
└── l10n/               # Localization resources
```

## Architecture (◕‿◕)♡

The application follows a clean architecture pattern with three main layers:

1. **Presentation Layer** - Contains UI components, screens, and BLoC state management.
2. **Domain Layer** - Contains business logic, models, and repository interfaces.
3. **Data Layer** - Contains repository implementations, API services, and data mapping.

The project uses the BLoC (Business Logic Component) pattern for state management, which provides a clean separation of concerns and makes the code more testable and maintainable. (^_^)

## State Management (˶ᵔ ᵕ ᵔ˶)

The app uses the `flutter_bloc` package for state management. Each feature has its own Cubit or Bloc class that manages the state for that feature. The Cubits and Blocs interact with repositories to fetch and update data.

Examples of state management in the app:
- `DashboardCubit` - Manages the state of the dashboard screen, including balance and transactions.
- `AuthCubit` - Manages the authentication state.
- `OfferCubit` - Manages the state of offers and discounts.
- `QrPaymentCubit` - Manages the state of QR code payments.

## Navigation ( •̀ ω •́ )y

The app uses `go_router` for navigation, which provides a clean and declarative way to define routes and handle deep linking. Routes are defined in `lib/presentation/app_router.dart`.

## API Integration (≧◡≦)

The app integrates with a RESTful API using the `dio` package. The API endpoints and service implementations are defined in `lib/data/api/service/api_service.dart`. The app uses repository classes to interact with the API and handle data mapping.

## Getting Started (づ｡◕‿‿◕｡)づ

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio or Visual Studio Code
- Android or iOS device/emulator

### Installation
1. Clone the repository:
```bash
git clone https://github.com/yourusername/zentro-wallet.git
```

2. Navigate to the project directory:
```bash
cd zentro-wallet
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Testing (੭˃ᴗ˂)੭

The project includes unit tests for most of the business logic components. Tests are organized in a similar structure to the main code.

To run tests:
```bash
flutter test
```

## Main Endpoints (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧

The app interacts with the following main API endpoints:

### Authentication
- `POST /api/v1/auth/initiate` - Initiate authentication
- `POST /api/v1/auth/verify` - Verify authentication code
- `POST /api/v1/auth/refresh` - Refresh authentication token

### Dashboard
- `GET /api/v1/balance` - Get user balance
- `GET /api/v1/transactions` - Get user transactions

### Offers
- `GET /api/v1/offers` - Get filtered offers
- `GET /api/v1/offers/top` - Get top offers
- `GET /api/v1/categories` - Get offer categories
- `GET /api/v1/merchants` - Get merchants list
- `POST /api/v1/activations/{offer_id}` - Activate an offer

### Payments
- `POST /api/v1/qr/check` - Check QR code
- `POST /api/v1/qr/payment` - Process payment
- `POST /api/v1/transfer` - Initiate money transfer

### Wallet
- `POST /api/v1/topup` - Initiate wallet top-up
- `POST /api/v1/withdrawal` - Initiate wallet withdrawal

## Contributing (>ᴗ<)

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License ヽ(・∀・)ﾉ

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements UwU

- Flutter team for their amazing framework
- All the package authors that made this project possible
- [Your company/team name] for supporting the development of Zentro Wallet

Nyaa~ Thank you for checking out our project! (⁄ ⁄>⁄ ▽ ⁄<⁄ ⁄)
