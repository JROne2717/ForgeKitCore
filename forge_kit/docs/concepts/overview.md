# Overview

## What ForgeKit Is

ForgeKit is a data authoring framework. It gives you a set of structured resource types for building RPG content - stats, classes, enemies, items, abilities, loot tables, dialogues, quests, and so on - along with editor tooling to create and manage that content inside the Godot editor.

You define what your game contains. ForgeKit provides the scaffolding to keep that data organized, serialized correctly, and accessible at runtime through a database loader.

Everything is stored as standard Godot `.tres` resource files. They show up in the Inspector, they are version control friendly, and they work with all the normal Godot resource workflows.

## What ForgeKit Is Not

ForgeKit is not a game engine on top of Godot. It does not handle rendering, physics, input, or scene management. It does not contain player controllers, camera systems, or UI frameworks.

The Core layer (the free version) is specifically a design tool. It defines data structures but contains no runtime gameplay logic. It will not play battles for you, run dialogue sequences, or manage inventory at runtime. That is either your code or the Advanced layer.

ForgeKit is also not a visual scripting system. The visual editors (dialogue graph, skill tree editor) are for authoring content relationships, not for programming game logic. If you want visual scripting, look at something like Orchestrator. ForgeKit sits underneath as the data layer - the two can coexist.

## Who It Is For

ForgeKit is most useful if you are building an RPG (or RPG-adjacent game) and you do not want to spend weeks designing a data architecture before you start making content. The 14 resource types cover the most common RPG systems, and the editor dock lets you create and manage them without leaving the Godot editor.

If your game has non-standard needs, every resource type includes a `custom_data` Dictionary where you can store whatever additional properties your project requires. You can also subclass any resource type with your own script.

If you are building something that is not an RPG at all, ForgeKit probably is not what you need right now. Genre expansion modules (platformer, strategy, visual novel) are on the roadmap for v1.0.

## Core vs Advanced

ForgeKit has two tiers:

- **Core** is free and open source. It includes all 14 resource types, the editor dock, FKDatabase, FKSaveSystem, visual editors, Quick Setup, icons, and scene templates. This is the data layer.
- **Advanced** is a paid add-on available through Patreon. It will include runtime gameplay nodes (battle manager, dialogue player, quest tracker, inventory manager, encounter triggers) and advanced editor tools. This is the execution layer.

Core works on its own. Advanced depends on Core but Core never depends on Advanced. If you only use Core, you write your own runtime code that reads from the resources. If you use Advanced, you get pre-built nodes that do that for you.

The split is documented in the [Architecture](architecture.md) page.
