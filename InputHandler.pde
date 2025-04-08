class InputHandler {
  private Application app;
  private int gridSize;

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

    switch (Character.toLowerCase(key)) {
    case DELETE:
    case BACKSPACE:
      if (selectedEntity != null) {
        handleDeleteEntity(selectedEntity);
      }
      break;

    case CODED:
      handleArrowKeys(keyCode, selectedEntity);
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

    case 'q':
      handleStartMatrixAnimation();
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
      handleAnimationPause();
      break;

    case 'r':  // Reverse animation
      handleAnimationReverse();
      break;

    case '[':  // Slow down
      handleAnimationSpeed(0.5f);
      break;

    case ']':  // Speed up
      handleAnimationSpeed(2.0f);
      break;

    default:
      handleNumberKeys(key, entityManager);
      break;
    }
  }

  void handleMousePressed(int mx, int my) {
    EntityManager entityManager = app.getEntityManager();
    Entity clickedEntity = entityManager.getEntityAtPosition(mx, my);

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

    String nodeName = "Node" + (entityManager.getNextEntityIndex() + 1); // Add 1 for display purposes
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

  private void handleStartMatrixAnimation() {
    // Clear existing entities and state
    app.resetSimulation();

    // Create and start the new animation
    AnimationSequence sequence = createMatrixAnimation();
    app.getAnimationSystem().addSequence(sequence);
    app.getStepLogger().addStep("Started matrix animation");
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

  private AnimationSequence createMatrixAnimation() {
    AnimationSequence sequence = new AnimationSequence();
    EntityManager entityManager = app.getEntityManager();

    // Create initial entities and add them to the EntityManager
    Entity e1 = entityManager.createEntity(200, 200, Constants.TYPE_NODE, "1");
    Entity e2 = entityManager.createEntity(200, 300, Constants.TYPE_NODE, "2");
    Entity e3 = entityManager.createEntity(300, 200, Constants.TYPE_NODE, "3");
    Entity e4 = entityManager.createEntity(300, 300, Constants.TYPE_NODE, "4");

    // Add a small delay before starting movement
    sequence.addStep(new DelayStep(500));

    // Add movement steps
    sequence.addStep(new MoveStep(e1, 200, 600, 1000));
    sequence.addStep(new DelayStep(200));  // Add small delay between movements

    sequence.addStep(new MoveStep(e2, 200, 700, 1000));
    sequence.addStep(new DelayStep(200));

    sequence.addStep(new MoveStep(e3, 300, 600, 1000));
    sequence.addStep(new DelayStep(200));

    sequence.addStep(new MoveStep(e4, 300, 700, 1000));
    sequence.addStep(new DelayStep(200));

    app.getStepLogger().addStep("Created matrix animation");
    return sequence;
  }
}
