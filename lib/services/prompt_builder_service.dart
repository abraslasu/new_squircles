import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'taxonomy_service.dart';

/// Provider for the PromptBuilderService
final promptBuilderProvider = Provider<PromptBuilderService>((ref) {
  return PromptBuilderService();
});

/// A service to format the local device context and user icon selections
/// into a strict, highly-optimized System Prompt for the local LLM.
class PromptBuilderService {
  
  /// Builds the "Master Prompt" for the local LLM using the semantic taxonomy mapping.
  /// 
  /// [selectedIconPaths] e.g., ['assets/icons/fi-rr-plane.svg', 'assets/icons/fi-rr-calendar.svg']
  /// [taxonomyService] The injected TaxonomyService (loaded at startup).
  String buildMasterPrompt(List<String> selectedIconPaths, TaxonomyService taxonomyService) {
    
    // ==========================================
    // 1. Gather Local Device Context (Mocked for Phase 4)
    // ==========================================
    // Once Isar is implemented, we will await real queries here.
    // e.g., await isar.contacts.where().limit(5).findAll();
    final String currentDateTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    const String currentLocation = "San Francisco, CA";
    const String topContacts = "Sarah (Phone: 555-0100), Mom, John, Alice, Bob";
    const String upcomingCalendar = """
    - Today 2:00 PM: Lunch with Alice
    - Friday: Flight to Miami (Vacation)
    - Next Tuesday: Dentist Appointment
    """;

    // ==========================================
    // 2. Semantic Translation (Using Taxonomy)
    // ==========================================
    // Translate raw file paths into rich tags so the LLM knows exactly what they mean.
    final String semanticIcons = taxonomyService.getRichTextForIcons(selectedIconPaths);

    // ==========================================
    // 3. Define the Target JSON Schema (Enforcing Intents)
    // ==========================================
    // We explicitly tell the LLM exactly what format we expect.
    // The keys must match our Intent classes in `intent_schema.dart`.
    final String targetSchema = '''
{
  "intentType": "FlightSearchIntent | WalletPaymentIntent | CalendarEventIntent | SendMessageIntent | WebSearchIntent",
  "translation": "A beautiful English sentence explaining the command. Use curly braces {like_this} for variables.",
  "destination": "City name (if FlightSearchIntent)",
  "recipientName": "Contact name (if Payment or Message)",
  "amount": "Number (if Payment)",
  "title": "Event title (if Calendar)",
  "startDate": "ISO 8601 Date (if Calendar or Flight)"
}
''';

    // ==========================================
    // 4. Assemble the Few-Shot System Prompt
    // ==========================================
    // We use a strict prompt format optimized for Instruct models like Gemma.
    // We provide the Context, the Rules, and the Input.
    
    final promptTemplate = '''
<start_of_turn>user
You are an offline iOS System Engine that translates a sequence of selected icons into executable intents.
You must output ONLY raw, valid JSON. Do not output any markdown formatting, explanations, or conversational text.

### CONTEXT
- Current Time: $currentDateTime
- Current Location: $currentLocation
- Top Contacts: $topContacts
- Upcoming Calendar Events: $upcomingCalendar

### RULES
1. Analyze the 'Selected Icons' and their associated semantic tags.
2. Determine what the user is trying to do based on the tags and their current context.
3. Guess sensible defaults for the variables based ONLY on their Calendar or Location. For example, if they select a Plane and their calendar says "Flight to Miami", the destination is "Miami".
4. Output EXACTLY ONE valid JSON object matching the schema below.

### SCHEMA
$targetSchema

### INPUT
Selected Icons:
$semanticIcons

Output the JSON now:<end_of_turn>
<start_of_turn>model
''';

    return promptTemplate;
  }
}
