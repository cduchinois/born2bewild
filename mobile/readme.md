# 🐾 WILD Sol - Wildlife Conservation Mobile Application

## 🌍 Overview

WILD Sol is an innovative mobile application dedicated to wildlife conservation, leveraging blockchain technology to support and protect endangered species.

## 🛠 Prerequisites

### Development Environment
- **Operating System**: macOS (required for iOS development)
- **Xcode**: Version 15+
- **Flutter SDK**: Version 3.10+ (Cross-platform framework, currently configured for iOS)
- **Dart SDK**: Compatible version
- **Apple Developer Account**
- **Your device has to be on developer mode**

### Required Tools
- Flutter CLI
- CocoaPods
- Xcode Command Line Tools
- Git

## 📦 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/cduchinois/born2bewild.git
cd born2bewild
cd mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. iOS Configuration

#### 3.1 Xcode and Signing
- Open Xcode
- Navigate to *Preferences > Accounts*
- Add your Apple Developer Account
- Select your Team for code signing

#### 3.2 Update Signing Configurations
- Open `ios/Runner.xcworkspace`
- Select *Runner* target
- Go to *Signing & Capabilities*
- Select your Team
- Ensure "Automatically manage signing" is checked

### 4. Environment Setup

Create a `.env` file in the project root:

```env
BASE_URL=https://your-api-endpoint.com
SOLANA_NETWORK=devnet
```

### 5. Permissions

Review `ios/Runner/Info.plist` for configured permissions:
- Camera access
- Photo library access
- Wallet connection schemes
- Associated domains

### 6. Run the Application

#### For Simulator
```bash
flutter run
```

#### For Physical Device
```bash
flutter run -d <device-id>
```

## 🔒 Wallet Connection

- **Wallet Required**: Phantom Wallet
- Ensure Phantom is installed on your iOS device
- Supports deep linking with Phantom wallet

## ✨ Features

- 🌐 Solana Blockchain Integration
- 🖼️ NFT Minting
- 🐘 Wildlife Conservation Campaigns
- 🔍 Animal Identification
- 🆔 Decentralized Identity Management

## 🐛 Troubleshooting

### Common iOS Issues
- Update CocoaPods: `pod repo update`
- Clean Flutter build: `flutter clean`
- Regenerate pods: 
  ```bash
  cd ios
  pod install
  cd ..
  ```

### Debugging
- Use Flutter DevTools
- Check Xcode console for specific errors
- Verify provisioning profiles and certificates


## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/)
- [Solana](https://solana.com/)
- [Phantom Wallet](https://phantom.app/)