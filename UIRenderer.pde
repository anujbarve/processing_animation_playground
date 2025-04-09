class UIRenderer {
    private static final int PANEL_WIDTH = 410;
    private static final int PANEL_MARGIN = 20;
    private static final int HEADER_HEIGHT = 40;
    private static final int LINE_HEIGHT = 28;
    
    void renderGrid() {
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        background(theme.backgroundColor);
        stroke(theme.gridColor);
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
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        
        // Create semi-transparent overlay
        rectMode(CORNER);
        noStroke();
        fill(theme.panelBackgroundColor);
        rect(width - PANEL_WIDTH, 0, PANEL_WIDTH, height);
        
        // Panel header
        fill(theme.textColor);
        textSize(24);
        textAlign(CENTER);
        text("Steps Performed", width - PANEL_WIDTH/2, 30);
        
        // Divider
        stroke(theme.accentColor);
        strokeWeight(1);
        line(width - PANEL_WIDTH, HEADER_HEIGHT, width, HEADER_HEIGHT);
        
        // Reset text alignment
        textAlign(LEFT);
        noStroke();
        
        // Step count
        fill(theme.textColor, 200);
        textSize(16);
        text("Total Steps: " + stepLogger.getStepCount(), width - PANEL_WIDTH + PANEL_MARGIN, 60);
        
        // Display steps
        ArrayList<String> steps = stepLogger.getSteps();
        textSize(18);
        int yPos = 90;
        int visibleSteps = (height - 100) / LINE_HEIGHT;
        int start = max(0, steps.size() - visibleSteps);
        
        for (int i = start; i < steps.size(); i++) {
            fill(i == steps.size() - 1 ? theme.highlightColor : theme.textColor);
            text((i + 1) + ": " + steps.get(i), width - PANEL_WIDTH + PANEL_MARGIN, yPos);
            yPos += LINE_HEIGHT;
        }
    }
    
    void renderUndoRedoStatus(UndoRedoSystem undoRedoSystem) {
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        fill(theme.textColor, 200);
        textSize(16);
        textAlign(LEFT);
        
        String undoStatus = undoRedoSystem.canUndo() ? 
            "Undo available (Ctrl+Z)" : "Nothing to undo";
        String redoStatus = undoRedoSystem.canRedo() ? 
            "Redo available (Ctrl+Y)" : "Nothing to redo";
        
        text(undoStatus, PANEL_MARGIN, height - 40);
        text(redoStatus, PANEL_MARGIN, height - 20);
    }
    
    void renderThemePanel() {
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        
        // Draw theme selector panel
        fill(theme.panelBackgroundColor);
        noStroke();
        rect(PANEL_MARGIN, PANEL_MARGIN, 200, 30);
        
        // Draw theme name
        fill(theme.textColor);
        textAlign(LEFT, CENTER);
        textSize(14);
        text("Theme: " + Constants.THEME_NAMES[app.getThemeManager().getCurrentThemeType()],
             PANEL_MARGIN + 10, PANEL_MARGIN + 15);
             
        // Draw theme preview dots
        int dotSize = 8;
        int dotSpacing = 15;
        int dotsStartX = PANEL_MARGIN + 160;
        int dotsY = PANEL_MARGIN + 15;
        
        for (int i = 0; i < Constants.THEME_NAMES.length; i++) {
            if (i == app.getThemeManager().getCurrentThemeType()) {
                fill(theme.highlightColor);
                ellipse(dotsStartX + i * dotSpacing, dotsY, dotSize, dotSize);
            } else {
                fill(theme.textColor, 100);
                ellipse(dotsStartX + i * dotSpacing, dotsY, dotSize, dotSize);
            }
        }
    }
    
    void renderAnimationControls() {
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        
        // Draw animation controls panel
        fill(theme.panelBackgroundColor);
        noStroke();
        rect(PANEL_MARGIN, height - 100, 200, 40);
        
        // Draw control buttons
        textAlign(CENTER, CENTER);
        textSize(12);
        
        // Play/Pause
        fill(theme.textColor);
        text("SPACE", PANEL_MARGIN + 30, height - 90);
        text("Play/Pause", PANEL_MARGIN + 30, height - 75);
        
        // Reverse
        text("R", PANEL_MARGIN + 100, height - 90);
        text("Reverse", PANEL_MARGIN + 100, height - 75);
        
        // Speed
        text("[ ]", PANEL_MARGIN + 170, height - 90);
        text("Speed", PANEL_MARGIN + 170, height - 75);
    }
    
    void renderEntityInfo(Entity selectedEntity) {
        if (selectedEntity == null) return;
        
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        
        // Draw entity info panel
        fill(theme.panelBackgroundColor);
        noStroke();
        rect(PANEL_MARGIN, 60, 200, 100);
        
        // Draw entity information
        fill(theme.textColor);
        textAlign(LEFT);
        textSize(14);
        text("Selected Entity", PANEL_MARGIN + 10, 80);
        text("ID: " + selectedEntity.data, PANEL_MARGIN + 10, 100);
        text("Type: " + (selectedEntity.type == Constants.TYPE_NODE ? "Node" : "Data"),
             PANEL_MARGIN + 10, 120);
        text("Connections: " + selectedEntity.getConnections().size(),
             PANEL_MARGIN + 10, 140);
    }
    
    void renderHelpOverlay(boolean showHelp) {
        if (!showHelp) return;
        
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        
        // Semi-transparent background
        fill(theme.backgroundColor, 230);
        rect(0, 0, width, height);
        
        // Help content
        fill(theme.textColor);
        textAlign(LEFT);
        textSize(20);
        text("Controls:", width/4, height/4);
        
        textSize(16);
        int y = height/4 + 40;
        String[] controls = {
            "N - Create Node",
            "S - Create Data Entity",
            "C - Connect Entities",
            "X - Disconnect Entities",
            "D - Duplicate Entity",
            "T - Toggle Entity Type",
            "SPACE - Play/Pause Animation",
            "R - Reverse Animation",
            "[ ] - Adjust Animation Speed",
            "Shift + 1-5 - Change Themes",
            "H - Toggle Help"
        };
        
        for (String control : controls) {
            text(control, width/4, y);
            y += 25;
        }
    }
    
    void renderStatusBar() {
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        
        // Draw status bar background
        fill(theme.panelBackgroundColor);
        noStroke();
        rect(0, height - 25, width, 25);
        
        // Draw status information
        fill(theme.textColor);
        textAlign(LEFT, CENTER);
        textSize(12);
        
        // Show current mode, selected entity, and other relevant info
        String status = "Mode: Normal | ";
        status += app.getAnimationSystem().hasActiveAnimations() ? "Animating | " : "";
        status += "Theme: " + Constants.THEME_NAMES[app.getThemeManager().getCurrentThemeType()];
        
        text(status, PANEL_MARGIN, height - 12);
    }
}
