# Scene Generator and Templates

The Scenes tab in the ForgeKit dock provides pre-built scene templates and a configurable scene generator. Both produce `.tscn` files with a starting node structure that you customize with your own art, scripts, and gameplay logic.

## Scene Templates

The Scenes tab lists 9 template buttons. Click any button, choose a save location, and the scene opens in the editor.

| Template | What It Includes |
|----------|-----------------|
| Battle Scene | Enemy and party areas, command buttons, status display, battle log |
| Overworld Scene | Camera, TileMap placeholder, spawn points, NPC and interactable containers, HUD |
| Title Screen | Title label, menu buttons (New Game, Continue, Options, Quit) |
| Game Over | Game over message, retry and quit buttons |
| Dialogue Scene | Dialogue panel, speaker name, text area, choice container, portrait |
| Shop Scene | Shop and inventory split view, buy/sell buttons, gold display |
| Inventory Screen | Category tabs, item list, detail panel with use/equip/drop actions |
| Party Menu | Menu sidebar, 4-member party display with portraits and stats |
| Save/Load Screen | 10 save slots with save/load toggle |

Templates are starting points. They give you a node tree with the expected structure. You still need to attach scripts, connect signals, and add your own visuals.

## Scene Generator

For custom scenes beyond the templates, use the Scene Generator.

### Opening

1. Open the ForgeKit dock and go to the Scenes tab.
2. Click "Open Scene Generator..."

### Configuration

| Field | Description |
|-------|-------------|
| Scene Name | The filename for the generated scene (without extension) |
| Scene Type | One of 13 types (see below) |
| 2D / 3D | Whether the scene uses Node2D or Node3D as the root |
| Camera | Toggle to include a camera node |
| HUD | Toggle to include a HUD overlay |
| Music | Toggle to include a background music player |
| Transitions | Toggle to include scene transition nodes |

### Scene Types

The generator supports 13 scene types:

| Type | Description |
|------|-------------|
| Dungeon | Dungeon or cave layout |
| Town | Town or village |
| Arena | Battle arena or colosseum |
| Overworld | Open world or field |
| Interior | Indoor area |
| Shop | Shop or marketplace |
| Tavern | Tavern or inn |
| Castle | Castle or palace |
| Forest | Forest or woodland |
| Cave | Cave or mine |
| Beach | Beach or coastal area |
| Mountain | Mountain or cliff area |
| Ruins | Ruins or ancient site |

Each type generates a scene root with nodes appropriate for that environment. The specific nodes included depend on the 2D/3D toggle and the optional components you selected.

### Output

Generated scenes are saved to `res://scenes/` by default and open automatically in the editor. The node tree includes placeholder nodes named descriptively (e.g., `SpawnPoint`, `NPCContainer`, `EnemySpawner`) so you can see where to attach your own content.

### When to Use Templates vs Generator

**Templates** are best when you want a standard RPG screen (battle, inventory, shop, etc.) with a conventional layout. They include specific UI nodes and containers that match the expected functionality.

**Scene Generator** is best when you need a game world area (dungeon, town, forest) with configurable components. It focuses on spatial layout nodes rather than UI.
