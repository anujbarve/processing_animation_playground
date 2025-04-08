// EntityManager.pde
class EntityManager {
    private Entity[] entities;
    private Entity selectedEntity;
    private int nextEntityIndex;  // Changed to start from 0
    private boolean dragging;
    
    EntityManager() {
        entities = new Entity[Constants.MAX_ENTITIES];
        nextEntityIndex = 1;
        dragging = false;
    }
    
    void update() {
        for (Entity e : entities) {
            if (e != null) {
                e.update();
            }
        }
        
        if (selectedEntity != null && dragging) {
            selectedEntity.drag(mouseX, mouseY);
        }
    }
    
    void render() {
        // Render connections first
        for (Entity e : entities) {
            if (e != null) {
                e.showConnections();
            }
        }
        
        // Render entities on top
        for (Entity e : entities) {
            if (e != null) {
                e.showEntities();
            }
        }
    }
    
     Entity createEntity(float x, float y, int type, String data) {
        if (nextEntityIndex >= entities.length) return null;
        
        // Find the next available slot
        while (nextEntityIndex < entities.length && entities[nextEntityIndex] != null) {
            nextEntityIndex++;
        }
        
        if (nextEntityIndex >= entities.length) return null;
        
        Entity entity = new Entity(x, y, type, data);
        entities[nextEntityIndex] = entity;
        nextEntityIndex++;
        return entity;
    }
    
    void deleteEntity(Entity entity) {
        if (entity == null) return;
        
        int entityIndex = findEntityIndex(entity);
        if (entityIndex != -1) {
            // Disconnect from all connected entities
            for (Entity connected : new ArrayList<>(entity.getConnections())) {
                entity.disconnectFrom(connected);
            }
            
            entities[entityIndex] = null;
            if (selectedEntity == entity) {
                selectedEntity = null;
            }
            
            // Update nextEntityIndex if needed
            if (entityIndex < nextEntityIndex) {
                nextEntityIndex = entityIndex;
            }
        }
    }
    
    int findEntityIndex(Entity entity) {
        for (int i = 0; i < entities.length; i++) {
            if (entities[i] == entity) {
                return i;
            }
        }
        return -1;
    }
    
    Entity getEntityAtPosition(float x, float y) {
        for (Entity e : entities) {
            if (e != null && e.isMouseOver(x, y)) {
                return e;
            }
        }
        return null;
    }
    
        // Find first available slot
    private int findFirstAvailableSlot() {
        for (int i = 0; i < entities.length; i++) {
            if (entities[i] == null) {
                return i;
            }
        }
        return -1;
    }
    
    void setSelectedEntity(Entity entity) {
        selectedEntity = entity;
    }
    
    void setDragging(boolean isDragging) {
        dragging = isDragging;
    }
    
    void reset() {
        for (int i = 0; i < entities.length; i++) {
            entities[i] = null;
        }
        nextEntityIndex = 0;  // Reset to 0
        selectedEntity = null;
        dragging = false;
    }
    

    
    // Getters
    Entity getSelectedEntity() { return selectedEntity; }
    Entity[] getEntities() { return entities; }
    int getNextEntityIndex() { return nextEntityIndex; }
    boolean isDragging() { return dragging; }
}
