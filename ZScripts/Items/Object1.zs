class Almond_Water : inventory
{

	Default
	{
		Inventory.PickupMessage "Picked up an bottle of almond water.";
		Inventory.Amount 1;
		Inventory.MaxAmount 1;
		Inventory.Icon "OBJ1B0";
		+INVENTORY.INVBAR
	
	}
	States
	{
		Spawn:
			OBJ1 A -1;
			stop;
					
	}
	override bool Use(bool pickup)
	{
	
		owner.GiveInventory("SanityAmount", 200);
		A_Print("You drinked your bottle of almond water, you have restored some sanity.");
		return true;
	}

}