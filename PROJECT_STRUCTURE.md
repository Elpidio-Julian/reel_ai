# Project Structure and Architecture

## Overview
We are building a TikTok clone MVP with an AI-first approach for Android using Flutter and Firebase, integrating with AWS Openshot API for video processing. This document outlines our project structure and architecture, refactored to support a future comprehensive metrics recording system and reduced integration complexity.

## Directory Structure
```
/ (root)
├── assets/               # Static resources (images, icons, fonts)
├── android/              # Android-specific configuration (e.g., google-services.json)
├── lib/
│   ├── main.dart         # App entry point
│   ├── src/
│   │   ├── models/       # Data models (e.g., Video, User)
│   │   ├── providers/    # State management using Provider
│   │   ├── services/     # External integrations and business logic
│   │   │   ├── firebase_service.dart      # Firebase integration for Auth, Firestore, Storage
│   │   │   ├── aws_openshot_service.dart    # Handles AWS Openshot API calls
│   │   │   └── video_processing_facade.dart # Facade to centralize external service integration
│   │   ├── views/        # UI screens and pages
│   │   ├── widgets/      # Reusable UI components
│   │   ├── utils/        # Utility classes, constants, and helper functions
│   │   └── metrics/      # Metrics recording module for analytics and event logging
│   │         ├── metrics_service.dart    # Logs events (uploads, errors, performance metrics)
│   │         ├── metrics_model.dart      # Defines structure for metrics events
│   │         └── analytics_config.dart   # Configuration for third-party analytics tools
└── README.md             # Project overview and instructions
```

## Architecture

### Layered Separation

1. **UI Layer**
   - Contains views/screens and widgets that interact with the user.

2. **Business Logic Layer**
   - Managed by Providers in the `/providers/` directory. This layer orchestrates data flow and user interactions.

3. **Service Layer**
   - Handles external integrations and core business logic. It includes:
     - **Firebase Service:** Manages authentication, video uploads to Firebase Storage, and metadata updates in Firestore.
     - **AWS Openshot Service:** Manages communication with the AWS Openshot API for video processing.
     - **VideoProcessingFacade:** Provides a unified interface that wraps interactions with Firebase and AWS Openshot services, centralizing error handling and logging (including dispatching events to the Metrics module).

4. **Metrics Module**
   - Dedicated to recording comprehensive metrics for analytics and performance monitoring.
     - Captures events such as video upload start/completion, errors, and performance data.
     - Uses an event-driven approach to decouple metrics logic from business logic, simplifying future integrations with additional analytics providers.

### Video Upload to Publishing Pipeline

1. The user selects a video for upload via the UI.
2. A Provider initiates the process and calls the VideoProcessingFacade.
3. The Firebase Service uploads the video to Firebase Storage.
4. After the upload, the AWS Openshot Service is triggered to process the video.
5. Throughout the process, the Metrics Service logs significant events (e.g., upload start, finish, errors).
6. Once processing is complete, the Provider updates Firestore, making the video available in the published feed.

### Reducing Integration Complexity

- **Facade Pattern:** The VideoProcessingFacade centralizes calls to both Firebase and AWS Openshot services, minimizing the impact of changes at integration points.
- **Metrics Module:** Separates metrics recording from business logic, allowing for easy upgrades and extensions without cluttering the codebase.
- **Event-Driven Approach:** Uses event broadcasting to log important events, further decoupling integration details from core app functionality.

## Future Considerations

- As the app scales, consider migrating the state management solution from Provider to more robust alternatives (e.g., Bloc or Riverpod).
- Monitor performance and adjust Firebase and AWS integrations as user load increases.
- Continually update the Metrics module to incorporate new analytics and monitoring tools as needed. 