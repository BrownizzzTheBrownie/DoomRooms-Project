//Handler
//Gives the player the flashlight item on game startup

class FlashLightPlusHandler : StaticEventHandler {
	
	FlashlightPlusHolder setupFlashlightHolder(PlayerPawn p)
	{
		FlashlightPlusHolder holder = FlashlightPlusHolder(p.GiveInventoryType("FlashlightPlusHolder"));
		holder.Init();
		return holder;
	}
	
	override void WorldLoaded(WorldEvent e)
    {
		if(e.IsReopen)
		{
			FlashlightPlusLight hl=null;
			for(let it=ThinkerIterator.Create("FlashlightPlusLight");hl=FlashlightPlusLight(it.next());)
			{
				hl.destroy();
				//prevents duplicate flashlights for hub-world maps
			}
		}
		for(int i=0;i<MAXPLAYERS;i++)
		{
			if(playeringame[i])
			{
				PlayerPawn p=players[i].mo;
				FlashlightPlusHolder holder=FlashlightPlusHolder(p.FindInventory("FlashlightPlusHolder"));
				if(holder)
				{
					holder.FixState();
				}
			}
		}
		FlashlightPlusHolder holder=null;
		for(let it=ThinkerIterator.Create("FlashlightPlusHolder");holder=FlashlightPlusHolder(it.next());)
		{
			holder.FixState();
		}
	}
	
	override void PlayerDisconnected(PlayerEvent e)
	{ 
	//reset state on player disconnect
		FlashlightPlusLight hl=null;
		for(let it=ThinkerIterator.Create("FlashlightPlusLight");hl=FlashlightPlusLight(it.next());)
		{
			hl.destroy();
		}
		FlashlightPlusHolder holder=null;
		for(let it=ThinkerIterator.Create("FlashlightPlusHolder");holder=FlashlightPlusHolder(it.next());)
		{
			if(holder.owner&&!playeringame[holder.owner.PlayerNumber()])continue;
			holder.FixState();
		}
	}
	
	override void NetworkProcess(ConsoleEvent e)
	{
		if(e.name=="flashlight_plus_toggle")
		{
			PlayerPawn p=players[e.player].mo;
			if(p)
            {
				FlashlightPlusHolder holder=FlashlightPlusHolder(p.FindInventory("FlashlightPlusHolder"));
				if(!holder)
				{
					holder=setupFlashlightHolder(p);
				}
				holder.ToggleFlashlight();
			}
		}
		else if(e.name=="flashlight_plus_uninstall")
		{
			PlayerPawn p=null;
			for(let it=ThinkerIterator.Create("PlayerPawn");p=PlayerPawn(it.next());)
			{
				FlashlightPlusHolder holder=FlashlightPlusHolder(p.FindInventory("FlashlightPlusHolder"));
				if(holder)
				{
					p.RemoveInventory(holder);
					holder.destroy();
				}
			}
			FlashlightPlusLight hl=null;
			for(let it=ThinkerIterator.Create("FlashlightPlusLight");hl=FlashlightPlusLight(it.next());)
			{
				hl.destroy();
			}
		}
	}
}
