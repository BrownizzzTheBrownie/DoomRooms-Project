class Almond_Water : inventory
{

	Default
	{
		Inventory.PickupMessage "Picked up an bottle of almond water.";
		Inventory.Amount 1;
		Inventory.MaxAmount 10;
		Inventory.Icon "OBJ1A0";
		+INVENTORY.INVBAR
	
	}
	States
	{
		Spawn:
			OBJ1 A -1;
			stop;
			
		/*Use:
			TNT1 A 0 A_GiveInventory("SanityAmount", 200);
			//OBJ1 A 1 Acs_NamedExecute("GiveSanity", 0);
			stop;*/
			
	}
	
	/*  override bool Use(Actor user)
    {
        // Give full health to the player
        user.Health = user.GetDefault().Health; // Restores to max health
        A_Log("Health Restored to Maximum!");  // Optional: Displays a message in the console

        // Give a specific item, e.g., give 5 units of "MySpecialItem"
        user.GiveInventory("SanityAmount", 300);
        A_Log("You received Half of your sanity.");  // Optional: Displays a message in the console

        // Play a sound or execute other effects here if needed

        return true;  // Item was successfully used
    }*/
	
	override bool Use(bool pickup)
	{
	
		owner.GiveInventory("SanityAmount", 200);
		A_Print("You drink almond water, you have restored some sanity.");
		return true;
	}

}