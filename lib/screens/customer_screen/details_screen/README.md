# Customer Detail Screen - Clean Architecture

This directory contains the cleaned up customer detail screen implementation, split into smaller, more manageable components.

## Structure

### Main Screen
- `customer_detail_screen.dart` - Main screen widget (reduced from 1013 lines to ~150 lines)

### Widgets
- `widgets/transaction_table.dart` - Reusable transaction table widget
- `widgets/summary_card.dart` - Customer account summary card widget

### Utilities
- `utils/text_utils.dart` - Text processing utilities (mixed Arabic/English text)
- `utils/pdf_utils.dart` - PDF generation and handling utilities
- `utils/dialog_utils.dart` - Dialog-related utility functions

## Benefits of the Clean Structure

1. **Separation of Concerns**: Each file has a single responsibility
2. **Reusability**: Widgets can be reused in other parts of the app
3. **Maintainability**: Easier to find and fix issues
4. **Testability**: Smaller components are easier to test
5. **Readability**: Code is more organized and easier to understand

## File Descriptions

### Main Screen (`customer_detail_screen.dart`)
- Handles the main screen logic and state management
- Coordinates between different widgets and utilities
- Manages customer data and transaction operations

### Transaction Table Widget (`widgets/transaction_table.dart`)
- Displays customer transactions in a table format
- Handles transaction row building and context menus
- Supports both vertical and horizontal scrolling

### Summary Card Widget (`widgets/summary_card.dart`)
- Shows customer account summary with balance information
- Displays credit/debit transaction counts
- Uses gradient colors based on balance status

### Text Utilities (`utils/text_utils.dart`)
- Processes mixed Arabic/English text for proper display
- Adds LRM (Left-to-Right Mark) for proper text direction

### PDF Utilities (`utils/pdf_utils.dart`)
- Handles PDF generation, viewing, printing, and saving
- Manages storage permissions for file operations
- Provides cross-platform file handling

### Dialog Utilities (`utils/dialog_utils.dart`)
- Manages all dialog-related operations
- Handles transaction editing, adding, and deletion dialogs
- Provides PDF options dialog

## Usage

The main screen can be used exactly as before, but now the code is much cleaner and more maintainable. All the functionality has been preserved while improving the code structure. 