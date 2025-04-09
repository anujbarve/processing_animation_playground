class Entity {
    float x, y, targetX, targetY, startX, startY;
    float moveProgress;
    final float moveSpeed;
    boolean isMoving;
    int size;
    int type;
    String data;
    ArrayList<Entity> connections;
    float flowProgress;
    final float flowSpeed;
    boolean isSelected;
    
    Entity(float x, float y, int type, String data) {
        this.x = this.startX = this.targetX = x;
        this.y = this.startY = this.targetY = y;
        this.type = type;
        this.moveSpeed = 0.01;
        this.data = data;
        this.size = 100;
        this.connections = new ArrayList<>();
        this.flowProgress = 0;
        this.flowSpeed = 0.02;
        this.isSelected = false;
        this.moveProgress = 0;
        this.isMoving = false;
    }
    
    void update() {
        if (isMoving) {
            moveProgress = min(1, moveProgress + moveSpeed);
            float eased = easeInOutCubic(moveProgress);
            x = startX + (targetX - startX) * eased;
            y = startY + (targetY - startY) * eased;
            if (moveProgress >= 1) isMoving = false;
        }
        
        flowProgress = (flowProgress + flowSpeed) % 1.0;
    }
    
    void showConnections() {
        for (Entity connected : connections) {
            drawConnection(connected);
        }
    }
    
    void drawConnection(Entity connected) {
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        float dx = connected.x - x;
        float dy = connected.y - y;
        float distance = dist(x, y, connected.x, connected.y);
        
        float fromRadius = size / 2;
        float toRadius = connected.size / 2;
        
        float nx = dx / distance;
        float ny = dy / distance;
        
        float x1 = x + nx * fromRadius;
        float y1 = y + ny * fromRadius;
        float x2 = connected.x - nx * toRadius;
        float y2 = connected.y - ny * toRadius;
        
        // Base connection line
        stroke(theme.connectionColor);
        strokeWeight(2);
        line(x1, y1, x2, y2);
        
        // Animated flow
        drawFlowingLine(x1, y1, x2, y2, distance - fromRadius - toRadius);
    }
    
    void drawFlowingLine(float x1, float y1, float x2, float y2, float length) {
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        float dashLength = 10;
        float gapLength = 15;
        float totalLength = dashLength + gapLength;
        
        stroke(theme.flowColor);
        strokeWeight(2);
        
        int dashCount = ceil(length / totalLength);
        float startOffset = flowProgress * totalLength;
        
        for (int i = 0; i < dashCount; i++) {
            float dashStart = startOffset + i * totalLength;
            float dashEnd = dashStart + dashLength;
            
            if (dashStart < length) {
                float dashStartX = lerp(x1, x2, constrain(dashStart / length, 0, 1));
                float dashStartY = lerp(y1, y2, constrain(dashStart / length, 0, 1));
                float dashEndX = lerp(x1, x2, constrain(dashEnd / length, 0, 1));
                float dashEndY = lerp(y1, y2, constrain(dashEnd / length, 0, 1));
                
                line(dashStartX, dashStartY, dashEndX, dashEndY);
            }
        }
    }
    
    void showEntities() {
        ColorScheme theme = app.getThemeManager().getCurrentTheme();
        stroke(1);
        
        // Set fill color based on entity type
        if (type == Constants.TYPE_NODE) {
            fill(theme.nodeColor);
            circle(x, y, size);
        } else {
            fill(theme.dataNodeColor);
            rectMode(CENTER);
            square(x, y, size);
        }
        
        // Draw selection indicator if selected
        if (isSelected) {
            noFill();
            stroke(theme.highlightColor);
            strokeWeight(2);
            if (type == Constants.TYPE_NODE) {
                circle(x, y, size + 10);
            } else {
                rectMode(CENTER);
                square(x, y, size + 10);
            }
        }
        
        // Draw entity text
        if (data != null && !data.isEmpty()) {
            fill(theme.textColorEntity);
            textAlign(CENTER, CENTER);
            textSize(22);
            text(data, x, y);
        }
    }
    
    // Rest of the methods remain the same...
    boolean isMouseOver(float mx, float my) {
        if (type == Constants.TYPE_NODE) {
            return dist(mx, my, x, y) < size / 2;
        } else {
            return abs(mx - x) < size / 2 && abs(my - y) < size / 2;
        }
    }
    
    void drag(float mx, float my) {
        if (isSelected) {
            x = mx;
            y = my;
        }
    }
    
    void moveTo(float newX, float newY) {
        if (x != newX || y != newY) {
            startX = x;
            startY = y;
            targetX = newX;
            targetY = newY;
            moveProgress = 0;
            isMoving = true;
        }
    }
    
    Entity duplicate(float newX, float newY) {
        Entity clone = new Entity(x, y, type, data);
        clone.moveTo(newX, newY);
        return clone;
    }
    
    void connectTo(Entity other) {
        if (!connections.contains(other)) {
            connections.add(other);
            other.connections.add(this);
        }
    }
    
    void disconnectFrom(Entity other) {
        connections.remove(other);
        other.connections.remove(this);
    }
    
    ArrayList<Entity> getConnections() {
        return connections;
    }
}
