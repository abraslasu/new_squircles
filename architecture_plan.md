# Visual Language UI - Implementation Plan

## Phase 1: Project Setup & Core UI Shell
**Goal:** Establish the Flutter app foundation, routing, and the static UI layout (Tray, Grid, Text Area).
*   Initialize Flutter project with iOS specific configurations.
*   Set up state management (`flutter_riverpod`).
*   Build the base UI shell (Dark theme, bottom action bar, empty tray, generic icon grid).
*   Implement drag-and-drop or tap-to-select logic to move icons from the Grid to the Tray.
*   **[UPDATED]** Build the "Lock Screen" entry point (`HomeScreen`) featuring the central sparkle button and radial category menu (`@1..png` & `@2..png`).
*   **[UPDATED]** Build the Category Detail screen (`CommandBuilderScreen`) featuring a dynamic grid, a 5-slot bottom tray (with dotted empty states), and dynamic sentence translation (`@3. commerce.png` & `@3. commerce 2.png`).
*   **[REPLACED]** The generic text area and horizontal tray list have been replaced by the vertical sidebar, the dynamic sentence header, and the 5-slot circular tray at the bottom.

## Phase 2: Onboarding & The Context Engine
**Goal:** Build a high-converting, trust-building onboarding flow that explains the "Visual AI" concept and secures the necessary permissions to build the local Knowledge Graph.
* Step 1: The Routing Logic (Gatekeeper)
Implement shared_preferences to check isFirstLaunch.
If true, route the user to the OnboardingFlow. If false, route directly to the main Visual UI.

* Step 2: The Value Proposition Carousel
Build a swipable PageView with fluid animations.
Screen A (The Concept): "Combine icons to command your world." (Show a quick looping GIF or animation of icons turning into text, similar to https://design.google/_next/image?url=https://storage.googleapis.com/gd-prod/images/87b37ebd-c035-44c2-84d7-3936f7504981.799a99c1196c2fd4.gif&w=1920&q=75). 
Screen B (The Brain): "To give you sensible defaults, your AI needs context. Your data never leaves your device." (Crucial privacy reassurance).

* Step 3: The Pre-Prompt Permission Flow
Build custom UI cards for each core permission, handled sequentially:
Location: "Allow access to suggest places near you and calculate travel times." -> triggers OS prompt.
Calendar: "Allow access to avoid double-booking and suggest actions based on your schedule." -> triggers OS prompt.
Contacts: "Allow access to easily send money, messages, or share ETAs with friends." -> triggers OS prompt.
Technical Detail: Use Riverpod to reactively track which permissions have been granted in real-time. If a user denies one, we allow them to proceed but log the denial so the AI Brain knows not to assume that context later.

* Step 4: The Initial Sync (The "Magic" Loading Screen)
Once permissions are granted, show a stylized loading screen ("Building your local knowledge graph...").
Initialize Isar (the local database).
Run the first background sync: fetch the next 7 days of calendar events, cache the current GPS coordinates, and map the top 50 starred/recent contacts into the database.

👉 What I need from you before we start Phase 2 (Onboarding):
1. Visual Style: Do you want the onboarding to be strictly text/buttons (minimalist, like the dark mockups), or do you want to include illustrations/Lottie animations?
A: also include animations
2. Hard Gate vs. Soft Gate: If the user aggressively denies all permissions, do we let them into the app anyway (the AI will just leave all Pills blank for manual entry), or do we require at least one (like Location) to use the app?
A: allow to use the app with the pills blank, that will have to be defined manually

## Phase 3: Schema-Driven UI (Universal Components)
**Goal:** Build the "dumb" UI building blocks (Pills and Overlays) that will render based on future AI JSON responses.
*   Define the base JSON schema model in Dart (`Variable`, `CommandSchema`).
*   Build the `TextCommandWidget` that parses a string with variables (e.g., "Get a flight to {destination}") and inserts interactive "Pills".
*   Build the Universal Overlays:
    *   `Date/Time Component`
    *   `Location Component`
    *   `Contacts List Component`
    *   `List Selection Component`
**Prompt for new component**
    * 
    * I am building a Flutter application ("Visual Language UI") that uses a Vision LLM to parse icon-based commands and generate interactive "Pill" widgets in a text sentence. 
    * We use a "Registry Architecture" for handling these dynamic variables. The `Variable` model has a `type` string (e.g., 'text', 'date', 'location') and an optional `metadata` Map for extra payload data. The core UI (`PillWidget`) looks up a `VariableHandler` from the `CapabilityRegistry` to trigger a specific interaction overlay (like a modal bottom sheet or dialog) when the pill is tapped. 
    * I need to add a new capability/component to this system.

    **New Component Details:**
     1.  **Capability Name (String ID):** `[INSERT NAME HERE, e.g., 'contact', 'payment', 'flight_seat']`
     2.  **UI Description:** `[DESCRIBE THE UI OVERLAY, e.g., "A BottomSheet showing a list of mock contacts with a search bar", or "A Map view to select a pickup location"]`
     3.  **Expected Metadata (Optional):** `[DESCRIBE IF THE LLM SENDS EXTRA DATA, e.g., "{ 'filter': 'favorites_only' }"]`

    **Please write the code to implement this following our established architecture. I need 3 specific things:**

     1.  **The UI Overlay Widget:**
      *   Create a stateless or stateful widget (e.g., `lib/widgets/overlays/[name]_overlay.dart`).
      *   It must accept the `Variable` and a `ValueChanged<String> onSelected` callback in its constructor.
      *   It should match a dark theme (`Color(0xFF141414)`, `Colors.grey.shade900`).
      *   When the user makes a selection, it must call `onSelected(value)` and close itself (e.g., `Navigator.pop(context)`).

     2.  **The VariableHandler Implementation:**
         *   Write a class that implements `VariableHandler` (e.g., `[Name]VariableHandler`).
         *   Implement the `handleInteraction(BuildContext context, Variable variable, ValueChanged<String> onValueChanged)` method.
         *   This method should trigger the overlay you built in Step 1 using `showModalBottomSheet`, `showDialog`, or `Navigator.push`.

     3.  **The Registry Registration Step:**
         *   Provide the exact line of code I need to add to `CapabilityRegistry.registerDefaults()` in `lib/services/capability_registry.dart` to link the String ID to the new Handler.

    Please ensure the code is modular and does not modify `PillWidget` or `TextCommandWidget`.

## Phase 4: The Integration Hub (Device Context)
**Goal:** Connect the app to iOS native features to gather "Sensible Defaults".
*   Implement `permission_handler` to request iOS Core Permissions (Location, Contacts, Calendar, Reminders, Notes, Music, HealthKit, Speech Recognition & Microphone, Local Network).
*   Set up a local database (recommendation: `Isar` for fast, offline, NoSQL document storage).
*   Create a background or app-startup sync method to pull upcoming calendar events and current location into the local DB.
    **👉 What I need from you before we start Phase 3:**
1. Which 3 permissions do you want to start with for V1?
Location, Calendar, Contacts

**Prompt for new device capability** 
   I am building a Flutter application ("Visual Language UI") that acts as a local-first AI assistant. It uses a "Registry Architecture" to sync native device data into a local Isar database. This data is then injected into a Vision LLM's context prompt.
   We use an abstract interface called ContextSyncer:
   ```
   abstract class ContextSyncer {
   String get name;
   Permission get requiredPermission;
   Future<void> syncData(Isar isar);
   String get llmPromptInjection;
   }
   ```
   We implement a "Mock Mode" where, if the app detects it is running on an iOS Simulator, it registers a Mock[Name]Syncer instead of the real one to populate the Isar DB with dummy data for UI testing.
   I need to add a new device capability to this engine.
   New Capability Details:
   1. Capability Name: [INSERT NAME, e.g., reminders]
   2. Native Package: [INSERT FLUTTER PACKAGE TO USE, e.g., device_calendar]
   3. Required OS Permission: [INSERT PERMISSION, e.g., Permission.reminders]
   4. Data to Store: [DESCRIBE THE DATA MODEL, e.g., A Reminder object with an ID, title, dueDate, and isCompleted flag]
   5. LLM Prompt Context: [DESCRIBE WHAT THE AI SHOULD KNOW, e.g., You have access to the user's Reminders. Query the local DB if they ask to add or check a to-do item.]
   
    Please write the code to implement this following our established architecture. I need 5 specific things:
   1. The Isar Schema ([name]_model.dart):
   Create an @collection class for Isar to store this data.
   Include Id id = Isar.autoIncrement; and the fields described above.
   2. The Real Syncer (real_[name]_syncer.dart):
   Write a class Real[Name]Syncer that implements ContextSyncer.
   Implement the syncData method to fetch real data using the specified native package and save it into the Isar database.
   3. The Mock Syncer (mock_[name]_syncer.dart):
   Write a class Mock[Name]Syncer that implements ContextSyncer.
   Implement the syncData method to generate 5-10 realistic dummy records and save them into the Isar database.
   4. The Native Configuration:
   Provide the exact <key> and <string> pairs I need to add to ios/Runner/Info.plist to request this permission without Apple rejecting the app.
   5. The Registry Registration Step:
   Provide the exact lines of code to add this to ContextSyncService in the dependency injection step (checking isPhysicalDevice to choose between Real and Mock).

## Phase 5: The Visual AI Brain
**Goal:** Connect the UI selections to a Vision LLM to generate the JSON schemas.
*   Write the image conversion utility (converting Flutter SVGs/Icons to Base64).
*   Set up the API Client (connecting to OpenAI GPT-4o or Claude Vision API).
*   Draft the "Master System Prompt" that forces the LLM to output the strict JSON structure we defined in Phase 2.
*   Implement the loading state (e.g., a shimmer effect on the text) while waiting for the LLM response.
    **👉 What I need from you before we start Phase 4:**
1. Which LLM provider do you want to use for the Vision model?
Google
2. We need to define 3 specific "Test Case Commands" (e.g., Booking a flight, setting a timer, buying food) to train our prompt. What are your 3 test cases?

## Phase 6: Execution Layer (App Intents & Deep Links)
**Goal:** Make the final command actually *do* something on the iOS device.
*   Create a `MethodChannel` in Flutter to communicate with native iOS.
*   Write Swift code (`AppDelegate.swift`) to receive the finalized command.
*   Implement native iOS App Intent execution (e.g., natively adding an event to Apple Calendar without leaving the app).
*   Implement Deep Link construction (e.g., formatting the URL scheme to open a web service or third-party app).
*   Build the iOS Lock Screen / Control Center widgets to launch the app.
    **👉 What I need from you before we start Phase 5:**
1. For your 3 test cases, what are the target destination apps? (e.g., Does the flight command open Expedia, Skyscanner, or Safari?)