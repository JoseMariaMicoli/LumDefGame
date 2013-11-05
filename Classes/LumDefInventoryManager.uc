class LumDefInventoryManager extends InventoryManager;

simulated function Inventory CreateInventoryArchetype(Inventory NewInventoryItemArchetype, optional bool bDoNotActivate)
{
	local Inventory	Inv;
	
	// Ensure the inventory archetype is valid
	if (NewInventoryItemArchetype != None)
	{
		// Spawn the inventory archetype
		Inv = Spawn(NewInventoryItemArchetype.Class, Owner,,,, NewInventoryItemArchetype);
		
		// Spawned the inventory, and add the inventory
		if (Inv != None && !AddInventory(Inv, bDoNotActivate))
		{
			// Unable to add the inventory, so destroy the spawned inventory
			Inv.Destroy();
			Inv = None;
		}
	}

	// Return the spawned inventory
	return Inv;
}

defaultproperties
{
	// Create the pending fire array
	PendingFire(0)=0
	PendingFire(1)=0
