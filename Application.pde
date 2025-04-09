// Application.pde
class Application {
  private EntityManager entityManager;
  private AnimationSystem animationSystem;
  private UndoRedoSystem undoRedoSystem;
  private UIRenderer uiRenderer;
  private InputHandler inputHandler;
  private StepLogger stepLogger;
  private ThemeManager themeManager;
  private boolean showHelp;

  Application() {
    entityManager = new EntityManager();
    animationSystem = new AnimationSystem();
    undoRedoSystem = new UndoRedoSystem();
    uiRenderer = new UIRenderer();
    stepLogger = new StepLogger();
    inputHandler = new InputHandler(this);
    themeManager = new ThemeManager();
  }

  void update() {
    animationSystem.update();
    entityManager.update();
  }

  void draw() {
    uiRenderer.renderGrid();
    entityManager.render();
    uiRenderer.renderSteps(stepLogger);
    uiRenderer.renderUndoRedoStatus(undoRedoSystem);
    uiRenderer.renderThemePanel();
    uiRenderer.renderAnimationControls();
    if (entityManager.getSelectedEntity() != null) {
      uiRenderer.renderEntityInfo(entityManager.getSelectedEntity());
    }
    uiRenderer.renderStatusBar();

    // Render help overlay last if help is enabled
    uiRenderer.renderHelpOverlay(showHelp);  // Add showHelp boolean to Application class
  }

  void resetSimulation() {
    entityManager.reset();
    undoRedoSystem.clear();
    stepLogger.clear();
    stepLogger.addStep("Simulation reset");
  }

  // Getter methods
  ThemeManager getThemeManager() {
    return themeManager;
  }
  EntityManager getEntityManager() {
    return entityManager;
  }
  AnimationSystem getAnimationSystem() {
    return animationSystem;
  }
  UndoRedoSystem getUndoRedoSystem() {
    return undoRedoSystem;
  }
  UIRenderer getUIRenderer() {
    return uiRenderer;
  }
  StepLogger getStepLogger() {
    return stepLogger;
  }
  InputHandler getInputHandler() {
    return inputHandler;
  } // Added this getter
}
