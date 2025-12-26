# 🎮 Marble Grouping Game

An interactive educational math game that teaches division concepts through visual marble grouping. Built with Flutter and Flame Engine for a smooth and engaging gaming experience.

## 📖 Description

**Marble Grouping Game** is a math learning application designed to help students understand division concepts in a fun and interactive way. Players must group marbles according to the displayed division result, then place these groups into submit areas to validate their answers.

### 🎯 Learning Objectives

- Understand division as a concept of grouping objects
- Practice logical thinking and problem-solving skills
- Develop visual-motor coordination through drag-and-drop interactions
- Learn mathematics in a fun and engaging way

## ✨ Key Features

### 🎲 Game Mechanics

- **Interactive Drag & Drop**: Drag marbles to form groups
- **Magnetic Grouping**: Marbles automatically snap together when close
- **Visual Feedback**: 
  - Connection lines between marbles in a group
  - Border color changes when marbles are grouped
  - Submit area highlights when groups are nearby
  - Shake animation for incorrect answers
- **Polygon Pattern**: Marbles arranged in neat polygon patterns
- **Double-Tap Detach**: Double-tap to detach marbles from groups
- **Submit Areas**: Three colored areas to place answer groups

### 🎨 Animations & Visual Effects

- Smooth animations when marbles move to center
- Spread effect when marbles scatter
- Bounce effect when groups return to submit position
- Shake animation for error feedback
- Staggered animation when detaching groups
- Smooth color transitions

### 🧮 Equation System

- Automatic division equation generator
- Result range: 2-10
- Value range: 2-30
- Number randomization animation during new question transitions
- Real-time answer validation

## 🏗️ Technical Architecture

### Tech Stack

- **Framework**: Flutter
- **Game Engine**: Flame
- **State Management**: GetX
- **Architecture Pattern**: MVC (Model-View-Controller) or GetX Pattern

### Project Structure

```
lib/
├── app/
│   ├── common/
│   │   └── widgets/          # Common widgets (ShadowButton, etc.)
│   ├── core/
│   │   ├── themes/           # Themes, colors, and styles
│   │   └── utils/            # Utility classes (EquationGenerator)
│   ├── data/
│   │   └── models/           # Data models (EquationModel)
│   ├── modules/
│   │   └── marble_game/
│   │       ├── bindings/     # Dependency injection
│   │       ├── controllers/  # Game controller (state management)
│   │       ├── game/
│   │       │   ├── components/      # Marble, MarbleGroup, SubmitArea
│   │       │   ├── constants/       # Game constants
│   │       │   ├── helpers/         # Animation helpers
│   │       │   ├── services/        # Game services (grouping, validation, etc.)
│   │       │   └── marble_flame.dart # Main game class
│   │       ├── views/        # UI screens
│   │       └── widgets/      # Game-specific widgets
│   └── routes/               # App routing
└── main.dart                 # Entry point
```

### Main Components

#### 1. **MarbleFlame** (Game Engine)
Main game class that manages all game logic using Flame Engine.

**Services:**
- `MarblePositioningService`: Calculates marble positions
- `MarbleAnimationService`: Manages all animations
- `GroupingService`: Marble grouping logic
- `GameValidationService`: Player answer validation

#### 2. **Marble** (Component)
Individual marble component with features:
- Drag & drop functionality
- Collision detection
- Visual state changes
- Double-tap detection

#### 3. **MarbleGroup** (Component)
Marble group component with:
- Hexagonal arrangement
- Connection line rendering
- Submit/unsubmit mechanism
- Bounce & shake animations

#### 4. **SubmitArea** (Component)
Answer submission area with:
- Highlight effect
- Occupied state management
- Color-coded borders
- Group validation

#### 5. **MarbleGameController** (GetX Controller)
Main controller that manages:
- Equation generation
- Game state management
- Answer validation
- Result overlay display

## 🚀 Installation & Running the Project

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio / VS Code with Flutter extension
- Emulator or physical device for testing

### Installation Steps

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd marble_grouping_game
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 🎮 How to Play

1. **Start Game**: The app will display a division equation (example: 12 ÷ 3)
2. **Understand the Problem**: The division result shows the number of marbles per group to create
3. **Group Marbles**: 
   - Drag marbles close to other marbles to form groups
   - Marbles will automatically snap together if close enough
   - Notice the connection lines and border color changes
4. **Submit Answer**:
   - Drag groups to one of the 3 submit areas on the left side
   - Areas will highlight when groups are nearby
   - Groups will snap to submit position
5. **Validate**: Press the "Check Answer" button
   - ✅ **Correct**: A new question will appear with animation
   - ❌ **Wrong**: Incorrect groups will shake, fix your answer!

### Playing Tips

- **Detach Marble**: Double-tap on a marble to detach it from a group
- **Unsubmit Group**: Drag a submitted group far enough to cancel submission
- **Bounce Effect**: Slightly dragging a submitted group will bounce it back to position
- **Watch Colors**: Marble borders will change to match the submit area color

## 🎨 Customization

### Changing Equation Range

Edit file `lib/app/modules/marble_game/controllers/marble_game_controller.dart`:

```dart
final EquationGenerator equationGenerator = EquationGenerator(
  maxResult: 10,  // Maximum division result
  maxB: 30,       // Maximum divisor value
  maxA: 30,       // Maximum dividend value
);
```

### Changing Theme Colors

Edit file `lib/app/core/themes/my_color.dart` to change the application color scheme.

### Changing Game Constants

Edit file `lib/app/modules/marble_game/game/constants/game_constants.dart`:

```dart
class GameConstants {
  static const double defaultMarbleRadius = 20.0;
  static const double proximityThreshold = 50.0;
  static const double moveToCenterDuration = 0.8;
  // ... and others
}
```

---

**Happy Playing and Learning! 🎓🎮**
