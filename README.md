# Node Graph Animation System

A Processing-based interactive visualization system for creating, manipulating, and animating node-based graphs with support for various operations and animations.

## Features

### Node Management
- Create and delete nodes
- Two types of nodes: Circle (Node) and Square (Data)
- Dynamic node connections
- Node selection and dragging
- Grid-snapping functionality
- Node duplication

### Animation System
- Smooth animations for node movement
- Connection animations with flowing lines
- Pre-defined matrix animation sequence
- Animation controls:
  - Play/Pause (SPACE)
  - Reverse (R)
  - Speed control ([ and ])
  - Reset (Z)

### Undo/Redo System
- Support for multiple operations
- Undo (Ctrl+Z)
- Redo (Ctrl+Y)
- Operation history tracking

### User Interface
- Grid-based layout
- Step logging panel
- Operation status display
- Undo/Redo status indicators

## Controls

### Basic Operations
- `N` - Create new Node (circle)
- `S` - Create new Data node (square)
- `D` - Duplicate selected node
- `T` - Toggle node type
- `DELETE/BACKSPACE` - Delete selected node

### Node Connections
- `C` - Connect selected node to target node
- `X` - Disconnect selected node from target node

### Movement
- Arrow Keys - Move selected node
- `M` - Move selected node to mouse position
- Mouse Drag - Move node freely

### Animation Controls
- `Q` - Start matrix animation
- `SPACE` - Pause/Resume animation
- `R` - Reverse animation direction
- `[` - Slow down animation
- `]` - Speed up animation

### System Controls
- `Ctrl+Z` - Undo last operation
- `Ctrl+Y` - Redo last operation
- `Z` - Reset simulation
- `1-9` - Select node by index

## Technical Architecture

### Core Components
1. **Application**
   - Main controller class
   - Manages all subsystems
   - Handles state coordination

2. **EntityManager**
   - Manages node creation and deletion
   - Handles node selection
   - Maintains node relationships

3. **AnimationSystem**
   - Controls animation sequences
   - Manages animation states
   - Handles timing and transitions

4. **UndoRedoSystem**
   - Tracks operations
   - Manages operation history
   - Handles state reversal

5. **InputHandler**
   - Processes user input
   - Manages keyboard and mouse events
   - Routes commands to appropriate systems

6. **UIRenderer**
   - Renders grid
   - Displays step log
   - Shows system status

### Entity Types
- **Node (Circle)**
  - Standard node type
  - Supports connections
  - Animated movement

- **Data (Square)**
  - Alternative node type
  - Supports connections
  - Animated movement

## Setup and Installation

1. Install Processing 4.0 or later
2. Clone the repository
3. Open the main sketch file in Processing
4. Run the sketch

## Dependencies
- Processing 4.0+
- Java 8 or higher

## File Structure