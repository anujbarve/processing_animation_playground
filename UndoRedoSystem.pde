// UndoRedoSystem.pde
class UndoRedoSystem {
    private ArrayList<Operation> history;
    private int currentHistoryIndex;
    private final int maxHistory;
    
    UndoRedoSystem() {
        history = new ArrayList<>();
        currentHistoryIndex = -1;
        maxHistory = Constants.MAX_HISTORY;
    }
    
    boolean canUndo() {
        return currentHistoryIndex >= 0;
    }
    
    boolean canRedo() {
        return currentHistoryIndex < history.size() - 1;
    }
    
    void undo() {
        if (!canUndo()) return;
        
        Operation operation = history.get(currentHistoryIndex);
        operation.undo();
        currentHistoryIndex--;
    }
    
    void redo() {
        if (!canRedo()) return;
        
        currentHistoryIndex++;
        Operation operation = history.get(currentHistoryIndex);
        operation.redo();
    }
    
    void recordOperation(Operation operation) {
        // Clear any redoable operations
        if (currentHistoryIndex < history.size() - 1) {
            history.subList(currentHistoryIndex + 1, history.size()).clear();
        }
        
        // Add new operation
        history.add(operation);
        
        // Maintain history size limit
        if (history.size() > maxHistory) {
            history.remove(0);
        } else {
            currentHistoryIndex++;
        }
    }
    
    void clear() {
        history.clear();
        currentHistoryIndex = -1;
    }
}

// Operations.pde
interface Operation {
    void undo();
    void redo();
    String getDescription();
}

class MoveOperation implements Operation {
    private Entity entity;
    private float oldX, oldY;
    private float newX, newY;
    
    MoveOperation(Entity entity, float oldX, float oldY, float newX, float newY) {
        this.entity = entity;
        this.oldX = oldX;
        this.oldY = oldY;
        this.newX = newX;
        this.newY = newY;
    }
    
    void undo() {
        entity.x = oldX;
        entity.y = oldY;
        entity.targetX = oldX;
        entity.targetY = oldY;
        entity.isMoving = false;
    }
    
    void redo() {
        entity.x = newX;
        entity.y = newY;
        entity.targetX = newX;
        entity.targetY = newY;
        entity.isMoving = false;
    }
    
    String getDescription() {
        return String.format("Move %s from (%.0f,%.0f) to (%.0f,%.0f)", 
            entity.data, oldX, oldY, newX, newY);
    }
}

class CreateOperation implements Operation {
    private Entity entity;
    private int entityIndex;
    private EntityManager entityManager;
    
    CreateOperation(Entity entity, int entityIndex, EntityManager entityManager) {
        this.entity = entity;
        this.entityIndex = entityIndex;
        this.entityManager = entityManager;
    }
    
    void undo() {
        entityManager.getEntities()[entityIndex] = null;
        if (entityManager.getSelectedEntity() == entity) {
            entityManager.setSelectedEntity(null);
        }
    }
    
    void redo() {
        entityManager.getEntities()[entityIndex] = entity;
    }
    
    String getDescription() {
        return String.format("Create entity %s at (%.0f,%.0f)", 
            entity.data, entity.x, entity.y);
    }
}

class DeleteOperation implements Operation {
    private Entity entity;
    private int entityIndex;
    private ArrayList<Entity> connectedEntities;
    private EntityManager entityManager;
    
    DeleteOperation(Entity entity, int entityIndex, 
                   ArrayList<Entity> connectedEntities, 
                   EntityManager entityManager) {
        this.entity = entity;
        this.entityIndex = entityIndex;
        this.connectedEntities = new ArrayList<>(connectedEntities);
        this.entityManager = entityManager;
    }
    
    void undo() {
        entityManager.getEntities()[entityIndex] = entity;
        for (Entity connected : connectedEntities) {
            entity.connectTo(connected);
        }
    }
    
    void redo() {
        for (Entity connected : connectedEntities) {
            entity.disconnectFrom(connected);
        }
        entityManager.getEntities()[entityIndex] = null;
        if (entityManager.getSelectedEntity() == entity) {
            entityManager.setSelectedEntity(null);
        }
    }
    
    String getDescription() {
        return String.format("Delete entity %s from (%.0f,%.0f)", 
            entity.data, entity.x, entity.y);
    }
}

class ConnectionOperation implements Operation {
    private Entity source;
    private Entity target;
    private boolean isConnect;
    
    ConnectionOperation(Entity source, Entity target, boolean isConnect) {
        this.source = source;
        this.target = target;
        this.isConnect = isConnect;
    }
    
    void undo() {
        if (isConnect) {
            source.disconnectFrom(target);
        } else {
            source.connectTo(target);
        }
    }
    
    void redo() {
        if (isConnect) {
            source.connectTo(target);
        } else {
            source.disconnectFrom(target);
        }
    }
    
    String getDescription() {
        return isConnect ? 
            String.format("Connect %s to %s", source.data, target.data) :
            String.format("Disconnect %s from %s", source.data, target.data);
    }
}

class TypeChangeOperation implements Operation {
    private Entity entity;
    private int oldType;
    private int newType;
    
    TypeChangeOperation(Entity entity, int oldType, int newType) {
        this.entity = entity;
        this.oldType = oldType;
        this.newType = newType;
    }
    
    void undo() {
        entity.type = oldType;
    }
    
    void redo() {
        entity.type = newType;
    }
    
    String getDescription() {
        String oldTypeName = (oldType == Constants.TYPE_NODE) ? "Node" : "Data";
        String newTypeName = (newType == Constants.TYPE_NODE) ? "Node" : "Data";
        return String.format("Change type of %s from %s to %s", 
            entity.data, oldTypeName, newTypeName);
    }
}
