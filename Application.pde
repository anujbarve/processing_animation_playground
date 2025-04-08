// Application.pde
class Application {
    private EntityManager entityManager;
    private AnimationSystem animationSystem;
    private UndoRedoSystem undoRedoSystem;
    private UIRenderer uiRenderer;
    private InputHandler inputHandler;
    private StepLogger stepLogger;
    
    Application() {
        entityManager = new EntityManager();
        animationSystem = new AnimationSystem();
        undoRedoSystem = new UndoRedoSystem();
        uiRenderer = new UIRenderer();
        stepLogger = new StepLogger();
        inputHandler = new InputHandler(this);
    }
    
    void update() {
        animationSystem.update();
        entityManager.update();
    }
    
    void draw() {
        background(0);
        uiRenderer.renderGrid();
        entityManager.render();
        uiRenderer.renderSteps(stepLogger);
        uiRenderer.renderUndoRedoStatus(undoRedoSystem);
    }
    
    void resetSimulation() {
        entityManager.reset();
        undoRedoSystem.clear();
        stepLogger.clear();
        stepLogger.addStep("Simulation reset");
    }
    
    // Getter methods
    EntityManager getEntityManager() { return entityManager; }
    AnimationSystem getAnimationSystem() { return animationSystem; }
    UndoRedoSystem getUndoRedoSystem() { return undoRedoSystem; }
    UIRenderer getUIRenderer() { return uiRenderer; }
    StepLogger getStepLogger() { return stepLogger; }
    InputHandler getInputHandler() { return inputHandler; } // Added this getter
}
