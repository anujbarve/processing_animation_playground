
// StepLogger.pde
class StepLogger {
    private ArrayList<String> steps;
    
    StepLogger() {
        steps = new ArrayList<>();
    }
    
    void addStep(String step) {
        steps.add(step);
    }
    
    void clear() {
        steps.clear();
    }
    
    ArrayList<String> getSteps() {
        return steps;
    }
    
    int getStepCount() {
        return steps.size();
    }
}
