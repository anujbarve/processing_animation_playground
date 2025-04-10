// AnimationSystem.pde
import java.util.Iterator; // Add this import at the top

// Add the enum definition
enum AnimationType {
    MOVE,
    CONNECT,
    DISCONNECT,
    CREATE,
    DELETE,
    CHANGE_TYPE,
    DELAY,
    CUSTOM
}

class AnimationSystem {
    private ArrayList<AnimationSequence> activeSequences;
    
    AnimationSystem() {
        activeSequences = new ArrayList<>();
    }
    
    void addSequence(AnimationSequence sequence) {
        activeSequences.add(sequence);
        sequence.play();
    }
    
    void update() {
        Iterator<AnimationSequence> iterator = activeSequences.iterator();
        while (iterator.hasNext()) {
            AnimationSequence sequence = iterator.next();
            sequence.update();
            if (sequence.isComplete()) {
                iterator.remove();
            }
        }
    }
    
    boolean hasActiveAnimations() {
        return !activeSequences.isEmpty();
    }
    
    AnimationSequence getCurrentSequence() {
    return activeSequences.isEmpty() ? null : activeSequences.get(0);
}
}

class AnimationSequence {
    private ArrayList<AnimationStep> steps;
    private int currentStep;
    private boolean isPlaying;
    private boolean isPaused;
    private boolean isReversed;
    private float playbackSpeed;
    
 AnimationSequence() {
        steps = new ArrayList<>();
        currentStep = 0;
        isPlaying = false;
        isPaused = false;
        isReversed = false;
        playbackSpeed = 1.0f;
    }
    
    void addStep(AnimationStep step) {
        steps.add(step);
    }
    
    void play() {
        if (steps.isEmpty()) return;
        isPlaying = true;
        isPaused = false;
        if (currentStep >= steps.size()) {
            currentStep = 0;
        }
        steps.get(currentStep).start();
    }
    
     void pause() {
        isPaused = true;
    }
    
    void resume() {
        isPaused = false;
    }
    
    void togglePause() {
        if (isPaused) resume();
        else pause();
    }
    
    
    void setSpeed(float speed) {
        playbackSpeed = speed;
        // Adjust current step's timing if in progress
        if (currentStep < steps.size()) {
            AnimationStep currentAnim = steps.get(currentStep);
            if (!currentAnim.isComplete) {
                float progress = (millis() - currentAnim.startTime) / (float)currentAnim.duration;
                currentAnim.duration = (long)(currentAnim.duration / playbackSpeed);
                currentAnim.startTime = millis() - (long)(progress * currentAnim.duration);
            }
        }
    }
    
    void nextStep() {
        if (!isPlaying || currentStep >= steps.size() - 1) return;
        
        // Complete current step
        AnimationStep currentAnim = steps.get(currentStep);
        currentAnim.isComplete = true;
        currentAnim.finish();
        
        // Move to next step
        currentStep++;
        if (currentStep < steps.size()) {
            steps.get(currentStep).start();
        }
    }
    
    void previousStep() {
        if (!isPlaying || currentStep <= 0) return;
        
        // Complete current step
        AnimationStep currentAnim = steps.get(currentStep);
        currentAnim.isComplete = true;
        currentAnim.finish();
        
        // Move to previous step
        currentStep--;
        steps.get(currentStep).start();
    }
    
    void reverse() {
        isReversed = !isReversed;
        if (currentStep < steps.size() && !isPaused) {
            AnimationStep currentAnim = steps.get(currentStep);
            if (!currentAnim.isComplete) {
                // Reverse the progress
                float progress = (millis() - currentAnim.startTime) / (float)currentAnim.duration;
                currentAnim.startTime = millis() - (long)((1 - progress) * currentAnim.duration);
            }
        }
    }

    void update() {
        if (!isPlaying || isPaused || currentStep >= steps.size()) return;
        
        AnimationStep currentAnim = steps.get(currentStep);
        
        if (!currentAnim.isComplete) {
            currentAnim.execute();
            
            float progress = (millis() - currentAnim.startTime) / (float)currentAnim.duration;
            if (isReversed) {
                progress = 1 - progress;
            }
            
            if (currentAnim instanceof MoveStep) {
                MoveStep moveStep = (MoveStep)currentAnim;
                moveStep.updatePosition(progress);
            }
        }
        
        if (currentAnim.update()) {
            currentAnim.finish();
            if (isReversed) {
                currentStep--;
                if (currentStep >= 0) {
                    steps.get(currentStep).start();
                } else {
                    isPlaying = false;
                }
            } else {
                currentStep++;
                if (currentStep < steps.size()) {
                    steps.get(currentStep).start();
                } else {
                    isPlaying = false;
                }
            }
        }
    }
    
    boolean isComplete() {
        return !isPlaying && ((isReversed && currentStep < 0) || 
                            (!isReversed && currentStep >= steps.size()));
    }
    
    // Getter methods
    boolean isPaused() { return isPaused; }
    boolean isReversed() { return isReversed; }
    float getPlaybackSpeed() { return playbackSpeed; }
}

class AnimationStep {
    AnimationType type;
    long duration;
    long startTime;
    boolean isComplete;
    
    AnimationStep(AnimationType type, long duration) {
        this.type = type;
        this.duration = duration;
        this.isComplete = false;
    }
    
    void start() {
        startTime = millis();
    }
    
    boolean update() {
        if (isComplete) return true;
        isComplete = (millis() - startTime >= duration);
        return isComplete;
    }
    
    void execute() {}
    void finish() {}
}

class MoveStep extends AnimationStep {
    Entity entity;
    float startX, startY;
    float targetX, targetY;
    
    MoveStep(Entity entity, float targetX, float targetY, long duration) {
        super(AnimationType.MOVE, duration);
        this.entity = entity;
        this.targetX = targetX;
        this.targetY = targetY;
    }
    
    @Override
    void start() {
        super.start();
        startX = entity.x;
        startY = entity.y;
    }
    
    void updatePosition(float progress) {
        progress = min(1, max(0, progress));
        float eased = easeInOutCubic(progress);
        entity.x = lerp(startX, targetX, eased);
        entity.y = lerp(startY, targetY, eased);
    }
    
    @Override
    boolean update() {
        if (isComplete) return true;
        isComplete = (millis() - startTime >= duration);
        return isComplete;
    }
}

class ConnectStep extends AnimationStep {
    Entity source, target;
    
    ConnectStep(Entity source, Entity target, long duration) {
        super(AnimationType.CONNECT, duration);
        this.source = source;
        this.target = target;
    }
    
    @Override
    void execute() {
        source.connectTo(target);
    }
}

class DelayStep extends AnimationStep {
    DelayStep(long duration) {
        super(AnimationType.DELAY, duration);
    }
}

// Utility function for easing
float easeInOutCubic(float x) {
    return x < 0.5 ? 
        4 * x * x * x : 
        1 - pow(-2 * x + 2, 3) / 2;
}
