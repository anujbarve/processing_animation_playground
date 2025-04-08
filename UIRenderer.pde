class UIRenderer {
    void renderGrid() {
        stroke(Constants.GRID_COLOR);
        strokeWeight(1);
        int w = width / Constants.GRID_SIZE;
        int h = height / Constants.GRID_SIZE;
        
        for (int i = 0; i <= w; i++) {
            line(i * Constants.GRID_SIZE, 0, i * Constants.GRID_SIZE, height);
        }
        for (int j = 0; j <= h; j++) {
            line(0, j * Constants.GRID_SIZE, width, j * Constants.GRID_SIZE);
        }
    }
    
    void renderSteps(StepLogger stepLogger) {
        // Create semi-transparent overlay
        rectMode(CORNER);
        noStroke();
        fill(0, 200);
        rect(width - 410, 0, 410, height);
        
        // Panel header
        fill(255);
        textSize(24);
        textAlign(CENTER);
        text("Steps Performed", width - 205, 30);
        
        // Divider
        stroke(100);
        strokeWeight(1);
        line(width - 410, 40, width - 0, 40);
        
        // Reset text alignment
        textAlign(LEFT);
        noStroke();
        
        // Step count
        fill(200);
        textSize(16);
        text("Total Steps: " + stepLogger.getStepCount(), width - 400, 60);
        
        // Display steps
        ArrayList<String> steps = stepLogger.getSteps();
        textSize(18);
        int yPos = 90;
        int lineHeight = 28;
        int visibleSteps = (height - 100) / lineHeight;
        int start = max(0, steps.size() - visibleSteps);
        
        for (int i = start; i < steps.size(); i++) {
            fill(i == steps.size() - 1 ? color(255, 255, 0) : color(255));
            text((i + 1) + ": " + steps.get(i), width - 400, yPos);
            yPos += lineHeight;
        }
    }
    
    void renderUndoRedoStatus(UndoRedoSystem undoRedoSystem) {
        fill(200);
        textSize(16);
        textAlign(LEFT);
        
        String undoStatus = undoRedoSystem.canUndo() ? 
            "Undo available (Ctrl+Z)" : "Nothing to undo";
        String redoStatus = undoRedoSystem.canRedo() ? 
            "Redo available (Ctrl+Y)" : "Nothing to redo";
        
        text(undoStatus, 20, height - 40);
        text(redoStatus, 20, height - 20);
    }
}
