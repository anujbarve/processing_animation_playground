class InputHandler {
  private Application app;
  private int gridSize;


  private static final int THEME_PANEL_X = 10;
  private static final int THEME_PANEL_Y = 10;
  private static final int THEME_PANEL_WIDTH = 200;
  private static final int THEME_PANEL_HEIGHT = 30;


  String[] ANIMATION_NAMES = {
    "Node Move",
    "Data Move",
  };

  private int currentAnimationIndex = 0;

  // Animation panel constants
  int ANIM_PANEL_X = 10;
  int ANIM_PANEL_Y = 50;
  int ANIM_PANEL_WIDTH = 200;
  int ANIM_PANEL_HEIGHT = 30;

  InputHandler(Application app) {
    this.app = app;
    this.gridSize = Constants.GRID_SIZE;
  }

  void handleKeyPressed(char key, int keyCode, KeyEvent event) {
    // Handle Ctrl+Z for undo
    if (keyCode == 'Z' && (event.isControlDown() || event.isMetaDown())) {
      app.getUndoRedoSystem().undo();
      app.getStepLogger().addStep("Undo performed");
      return;
    }

    // Handle Ctrl+Y for redo
    if (keyCode == 'Y' && (event.isControlDown() || event.isMetaDown())) {
      app.getUndoRedoSystem().redo();
      app.getStepLogger().addStep("Redo performed");
      return;
    }

    EntityManager entityManager = app.getEntityManager();
    Entity selectedEntity = entityManager.getSelectedEntity();
    AnimationSystem animSystem = app.getAnimationSystem();
    AnimationSequence currentSequence = animSystem.getCurrentSequence();

    switch (Character.toLowerCase(key)) {
    case DELETE:
    case BACKSPACE:
      if (selectedEntity != null) {
        handleDeleteEntity(selectedEntity);
      }
      break;

    case CODED:
      if (event.isShiftDown()) {
        handleThemeShortcuts(keyCode);
      } else {
        handleArrowKeys(keyCode, selectedEntity);
      }
      break;

    case 'm':
      handleMoveToMouse(selectedEntity);
      break;

    case 'n':
      handleCreateNode();
      break;

    case 's':
      handleCreateDataEntity();
      break;

    case 'a':
      handleAnimation();
      break;

    case 't':
      handleToggleType(selectedEntity);
      break;

    case 'd':
      handleDuplicateEntity(selectedEntity);
      break;

    case 'z':
      app.resetSimulation();
      break;

    case 'c':
      handleConnect(selectedEntity);
      break;

    case 'x':
      handleDisconnect(selectedEntity);
      break;

    case ' ':  // Space bar to toggle pause
      if (currentSequence != null) {
        currentSequence.togglePause();
        app.getStepLogger().addStep(currentSequence.isPaused() ?
          "Animation paused" : "Animation resumed");
      }
      break;

    case 'r':  // Reverse animation
      if (currentSequence != null) {
        currentSequence.reverse();
        app.getStepLogger().addStep(currentSequence.isReversed() ?
          "Animation reversed" : "Animation playing forward");
      }
      break;

    case '.':  // Next step
      if (currentSequence != null) {
        currentSequence.nextStep();
        app.getStepLogger().addStep("Moved to next step");
      }
      break;

    case ',':  // Previous step
      if (currentSequence != null) {
        currentSequence.previousStep();
        app.getStepLogger().addStep("Moved to previous step");
      }
      break;

    case '[':  // Slow down
      handleAnimationSpeed(0.5f);
      break;

    case ']':  // Speed up
      handleAnimationSpeed(2.0f);
      break;

    case 'h':  // Theme controls
      showThemeControls();
      break;

    default:
      handleNumberKeys(key, entityManager);
      break;
    }
  }


  private void handleThemeShortcuts(int keyCode) {
    if (keyCode >= 49 && keyCode <= 53) {  // 1-5 keys
      int themeType = keyCode - 49;  // Convert to 0-4
      app.getThemeManager().setTheme(themeType);
      app.getStepLogger().addStep("Switched to " + Constants.THEME_NAMES[themeType] + " theme");
    }
  }

  private void showThemeControls() {
    app.getStepLogger().addStep("Theme Controls:");
    app.getStepLogger().addStep("Shift + 1-5: Switch themes");
    app.getStepLogger().addStep("Click theme panel to cycle");
  }

  private void cycleTheme() {
    ThemeManager tm = app.getThemeManager();
    int nextTheme = (tm.getCurrentThemeType() + 1) % Constants.THEME_NAMES.length;
    tm.setTheme(nextTheme);
    app.getStepLogger().addStep("Switched to " + Constants.THEME_NAMES[nextTheme] + " theme");
  }

  void handleMousePressed(int mx, int my) {
    EntityManager entityManager = app.getEntityManager();
    Entity clickedEntity = entityManager.getEntityAtPosition(mx, my);


    if (mx >= THEME_PANEL_X && mx <= THEME_PANEL_X + THEME_PANEL_WIDTH &&
      my >= THEME_PANEL_Y && my <= THEME_PANEL_Y + THEME_PANEL_HEIGHT) {
      cycleTheme();
      return;
    }

    if (mx >= ANIM_PANEL_X && mx <= ANIM_PANEL_X + ANIM_PANEL_WIDTH &&
      my >= ANIM_PANEL_Y && my <= ANIM_PANEL_Y + ANIM_PANEL_HEIGHT) {
      cycleAnimation();
      return;
    }


    if (clickedEntity != null) {
      entityManager.setSelectedEntity(clickedEntity);
      entityManager.setDragging(true);
      app.getStepLogger().addStep("Selected entity: " + clickedEntity.data);
    } else if (entityManager.getSelectedEntity() != null) {
      entityManager.setSelectedEntity(null);
      app.getStepLogger().addStep("Deselected entity");
    }
  }

  void handleMouseReleased(int mx, int my) {
    EntityManager entityManager = app.getEntityManager();
    Entity selectedEntity = entityManager.getSelectedEntity();

    if (entityManager.isDragging() && selectedEntity != null) {
      float oldX = selectedEntity.x;
      float oldY = selectedEntity.y;

      int snappedX = (int) (Math.round((float) mx / gridSize) * gridSize);
      int snappedY = (int) (Math.round((float) my / gridSize) * gridSize);

      selectedEntity.x = snappedX;
      selectedEntity.y = snappedY;

      app.getStepLogger().addStep(String.format("Moved %s to (%d,%d)",
        selectedEntity.data, snappedX, snappedY));

      app.getUndoRedoSystem().recordOperation(
        new MoveOperation(selectedEntity, oldX, oldY, snappedX, snappedY));

      entityManager.setDragging(false);
    }
  }

  private void handleDeleteEntity(Entity entity) {
    EntityManager entityManager = app.getEntityManager();
    int entityIndex = entityManager.findEntityIndex(entity);

    if (entityIndex != -1) {
      ArrayList<Entity> connectedEntities = new ArrayList<>(entity.getConnections());

      // Record delete operation before actual deletion
      app.getUndoRedoSystem().recordOperation(
        new DeleteOperation(entity, entityIndex, connectedEntities, entityManager));

      entityManager.deleteEntity(entity);
      app.getStepLogger().addStep("Deleted entity: " + entity.data);
    }
  }

  // Add these methods to InputHandler
  private void handleAnimationPause() {
    AnimationSystem animSystem = app.getAnimationSystem();
    if (animSystem.hasActiveAnimations()) {
      AnimationSequence currentSequence = animSystem.getCurrentSequence();
      currentSequence.togglePause();
      app.getStepLogger().addStep(currentSequence.isPaused() ?
        "Animation paused" : "Animation resumed");
    }
  }

  private void handleAnimationReverse() {
    AnimationSystem animSystem = app.getAnimationSystem();
    if (animSystem.hasActiveAnimations()) {
      AnimationSequence currentSequence = animSystem.getCurrentSequence();
      currentSequence.reverse();
      app.getStepLogger().addStep(currentSequence.isReversed() ?
        "Animation reversed" : "Animation playing forward");
    }
  }

  private void handleAnimationSpeed(float speedMultiplier) {
    AnimationSystem animSystem = app.getAnimationSystem();
    if (animSystem.hasActiveAnimations()) {
      AnimationSequence currentSequence = animSystem.getCurrentSequence();
      float newSpeed = currentSequence.getPlaybackSpeed() * speedMultiplier;
      currentSequence.setSpeed(newSpeed);
      app.getStepLogger().addStep(String.format("Animation speed: %.1fx", newSpeed));
    }
  }

  private void handleArrowKeys(int keyCode, Entity entity) {
    if (entity == null) return;

    float oldX = entity.x;
    float oldY = entity.y;
    float newX = entity.x;
    float newY = entity.y;

    switch (keyCode) {
    case UP:
      newY = entity.y - gridSize;
      break;
    case DOWN:
      newY = entity.y + gridSize;
      break;
    case LEFT:
      newX = entity.x - gridSize;
      break;
    case RIGHT:
      newX = entity.x + gridSize;
      break;
    default:
      return;
    }

    entity.moveTo(newX, newY);
    app.getStepLogger().addStep(String.format("Moved %s using arrow keys", entity.data));

    if (oldX != newX || oldY != newY) {
      app.getUndoRedoSystem().recordOperation(
        new MoveOperation(entity, oldX, oldY, newX, newY));
    }
  }

  private void handleMoveToMouse(Entity entity) {
    if (entity == null) return;

    float oldX = entity.x;
    float oldY = entity.y;

    int snappedX = (int) (Math.round((float) mouseX / gridSize) * gridSize);
    int snappedY = (int) (Math.round((float) mouseY / gridSize) * gridSize);

    entity.moveTo(snappedX, snappedY);
    app.getStepLogger().addStep(String.format("Moved %s to mouse position (%d,%d)",
      entity.data, snappedX, snappedY));

    app.getUndoRedoSystem().recordOperation(
      new MoveOperation(entity, oldX, oldY, snappedX, snappedY));
  }

  private void handleCreateNode() {
    EntityManager entityManager = app.getEntityManager();
    if (entityManager.getNextEntityIndex() >= Constants.MAX_ENTITIES) return;

    int snappedX = (int) (Math.round((float) mouseX / gridSize) * gridSize);
    int snappedY = (int) (Math.round((float) mouseY / gridSize) * gridSize);

    String nodeName = "Node" + (entityManager.getNextEntityIndex()); // Add 1 for display purposes
    Entity newNode = entityManager.createEntity(snappedX, snappedY, Constants.TYPE_NODE, nodeName);

    if (newNode != null) {
      app.getStepLogger().addStep(String.format("Created new node at (%d,%d)",
        snappedX, snappedY));
    }
  }

  private void handleCreateDataEntity() {
    EntityManager entityManager = app.getEntityManager();
    if (entityManager.getNextEntityIndex() >= Constants.MAX_ENTITIES) return;

    int snappedX = (int) (Math.round((float) mouseX / gridSize) * gridSize);
    int snappedY = (int) (Math.round((float) mouseY / gridSize) * gridSize);

    Entity newData = new Entity(snappedX, snappedY, Constants.TYPE_DATA, "New Data");
    int entityIndex = entityManager.getNextEntityIndex();
    entityManager.getEntities()[entityIndex] = newData;

    app.getStepLogger().addStep(String.format("Created new data entity at (%d,%d)",
      snappedX, snappedY));

    app.getUndoRedoSystem().recordOperation(
      new CreateOperation(newData, entityIndex, entityManager));
  }



  private void handleToggleType(Entity entity) {
    if (entity == null) return;

    int oldType = entity.type;
    int newType = (entity.type == Constants.TYPE_NODE) ?
      Constants.TYPE_DATA : Constants.TYPE_NODE;

    app.getUndoRedoSystem().recordOperation(
      new TypeChangeOperation(entity, oldType, newType));

    entity.type = newType;
    app.getStepLogger().addStep(String.format("Changed type of %s to %s",
      entity.data, (newType == Constants.TYPE_NODE) ? "Node" : "Data"));
  }

  private void handleDuplicateEntity(Entity entity) {
    if (entity == null) return;

    EntityManager entityManager = app.getEntityManager();
    if (entityManager.getNextEntityIndex() >= Constants.MAX_ENTITIES) return;

    int snappedX = (int) (Math.round((float) mouseX / gridSize) * gridSize);
    int snappedY = (int) (Math.round((float) mouseY / gridSize) * gridSize);

    Entity duplicate = entity.duplicate(snappedX, snappedY);
    int entityIndex = entityManager.getNextEntityIndex();
    entityManager.getEntities()[entityIndex] = duplicate;

    app.getStepLogger().addStep(String.format("Duplicated %s to (%d,%d)",
      entity.data, snappedX, snappedY));

    app.getUndoRedoSystem().recordOperation(
      new CreateOperation(duplicate, entityIndex, entityManager));
  }

  private void handleConnect(Entity entity) {
    if (entity == null) return;

    EntityManager entityManager = app.getEntityManager();
    Entity targetEntity = entityManager.getEntityAtPosition(mouseX, mouseY);

    if (targetEntity != null && targetEntity != entity) {
      entity.connectTo(targetEntity);
      app.getStepLogger().addStep(String.format("Connected %s to %s",
        entity.data, targetEntity.data));

      app.getUndoRedoSystem().recordOperation(
        new ConnectionOperation(entity, targetEntity, true));
    }
  }

  private void handleDisconnect(Entity entity) {
    if (entity == null) return;

    EntityManager entityManager = app.getEntityManager();
    Entity targetEntity = entityManager.getEntityAtPosition(mouseX, mouseY);

    if (targetEntity != null && targetEntity != entity &&
      entity.getConnections().contains(targetEntity)) {

      app.getUndoRedoSystem().recordOperation(
        new ConnectionOperation(entity, targetEntity, false));

      entity.disconnectFrom(targetEntity);
      app.getStepLogger().addStep(String.format("Disconnected %s from %s",
        entity.data, targetEntity.data));
    }
  }

  private void handleNumberKeys(char key, EntityManager entityManager) {
    if (Character.isDigit(key)) {
      int index = Character.getNumericValue(key);
      if (index >= 0 && index < Constants.MAX_ENTITIES &&
        entityManager.getEntities()[index] != null) {

        entityManager.setSelectedEntity(entityManager.getEntities()[index]);
        app.getStepLogger().addStep("Selected node: " + index);
      }
    }
  }


  private void cycleAnimation() {
    currentAnimationIndex = (currentAnimationIndex + 1) % ANIMATION_NAMES.length;
    app.getStepLogger().addStep("Switched to " + ANIMATION_NAMES[currentAnimationIndex] + " animation");
  }

  // Getter for current animation name
  public String getCurrentAnimationName() {
    return ANIMATION_NAMES[currentAnimationIndex];
  }

  public int getCurrentAnimationIndex() {
    return currentAnimationIndex;
  }

  public int getAnimationCount() {
    return ANIMATION_NAMES.length;
  }


  private void handleAnimation() {
    app.resetSimulation();
    AnimationSequence sequence;

    switch(currentAnimationIndex) {
    case 0:
      sequence = NodeMove();
      break;
    case 1:
      sequence = DataMove();
      break;
    default:
      sequence = NodeMove();
      break;
    }

    app.getAnimationSystem().addSequence(sequence);
    app.getStepLogger().addStep("Started " + ANIMATION_NAMES[currentAnimationIndex]);
  }

  private AnimationSequence NodeMove() {
    AnimationSequence sequence = new AnimationSequence();
    EntityManager entityManager = app.getEntityManager();

    // Create initial entities and add them to the EntityManager
    Entity e1 = entityManager.createEntity(200, 200, Constants.TYPE_NODE, "M0");
    Entity e2 = entityManager.createEntity(200, 200, Constants.TYPE_NODE, "M0");
    Entity e3 = entityManager.createEntity(200, 200, Constants.TYPE_NODE, "M0");
    Entity e4 = entityManager.createEntity(200, 200, Constants.TYPE_NODE, "M1");
    Entity e5 = entityManager.createEntity(200, 200, Constants.TYPE_NODE, "5");
    Entity e6 = entityManager.createEntity(200, 200, Constants.TYPE_NODE, "6");
    Entity e7 = entityManager.createEntity(200, 200, Constants.TYPE_NODE, "7");
    Entity e8 = entityManager.createEntity(200, 200, Constants.TYPE_NODE, "8");

    // Add a small delay before starting movement
    sequence.addStep(new DelayStep(500));

    // Add movement steps
    sequence.addStep(new MoveStep(e1, 400, 300, 1000));

    sequence.addStep(new MoveStep(e2, 650, 300, 1000));

    sequence.addStep(new MoveStep(e3, 900, 300, 1000));

    sequence.addStep(new MoveStep(e4, 1150, 300, 1000));

    sequence.addStep(new MoveStep(e5, 400, 650, 1000));

    sequence.addStep(new MoveStep(e6, 650, 650, 1000));

    sequence.addStep(new MoveStep(e7, 900, 650, 1000));

    sequence.addStep(new MoveStep(e8, 1150, 650, 1000));


    sequence.addStep(new ConnectStep(e1, e2, 1000));
    sequence.addStep(new ConnectStep(e2, e3, 1000));
    sequence.addStep(new ConnectStep(e3, e4, 1000));
    sequence.addStep(new ConnectStep(e4, e5, 1000));
    sequence.addStep(new ConnectStep(e5, e6, 1000));
    sequence.addStep(new ConnectStep(e6, e7, 1000));
    sequence.addStep(new ConnectStep(e7, e8, 1000));
    sequence.addStep(new ConnectStep(e8, e1, 1000));







    app.getStepLogger().addStep("Created matrix animation");
    return sequence;
  }

  private AnimationSequence DataMove() {
    AnimationSequence sequence = new AnimationSequence();
    EntityManager entityManager = app.getEntityManager();

    // Create initial entities and add them to the EntityManager
    Entity e1 = entityManager.createEntity(200, 200, Constants.TYPE_DATA, "M0");
    Entity e2 = entityManager.createEntity(200, 200, Constants.TYPE_DATA, "M0");
    Entity e3 = entityManager.createEntity(200, 200, Constants.TYPE_DATA, "M0");
    Entity e4 = entityManager.createEntity(200, 200, Constants.TYPE_DATA, "M1");
    Entity e5 = entityManager.createEntity(200, 200, Constants.TYPE_DATA, "5");
    Entity e6 = entityManager.createEntity(200, 200, Constants.TYPE_DATA, "6");
    Entity e7 = entityManager.createEntity(200, 200, Constants.TYPE_DATA, "7");
    Entity e8 = entityManager.createEntity(200, 200, Constants.TYPE_DATA, "8");

    // Add a small delay before starting movement
    sequence.addStep(new DelayStep(500));

    // Add movement steps
    sequence.addStep(new MoveStep(e1, 400, 300, 1000));

    sequence.addStep(new MoveStep(e2, 650, 300, 1000));

    sequence.addStep(new MoveStep(e3, 900, 300, 1000));

    sequence.addStep(new MoveStep(e4, 1150, 300, 1000));

    sequence.addStep(new MoveStep(e5, 400, 650, 1000));

    sequence.addStep(new MoveStep(e6, 650, 650, 1000));

    sequence.addStep(new MoveStep(e7, 900, 650, 1000));

    sequence.addStep(new MoveStep(e8, 1150, 650, 1000));


    sequence.addStep(new ConnectStep(e1, e2, 1000));
    sequence.addStep(new ConnectStep(e2, e3, 1000));
    sequence.addStep(new ConnectStep(e3, e4, 1000));
    sequence.addStep(new ConnectStep(e4, e5, 1000));
    sequence.addStep(new ConnectStep(e5, e6, 1000));
    sequence.addStep(new ConnectStep(e6, e7, 1000));
    sequence.addStep(new ConnectStep(e7, e8, 1000));
    sequence.addStep(new ConnectStep(e8, e1, 1000));







    app.getStepLogger().addStep("Created matrix animation");
    return sequence;
  }
}
