/* Flashlight++, an extended version of Flashlight+ with extra customizability.
Copyright (C) 2024  generic name guy

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>. */

// Gives the player the flashlight holder item on game startup and handles the button presses
class FlashLightPlusHandler : StaticEventHandler 
{
	FlashlightPlusHolder setupFlashlightHolder( PlayerPawn p )
	{
		FlashlightPlusHolder holder = FlashlightPlusHolder( p.GiveInventoryType( "FlashlightPlusHolder" ) );
		holder.Init();
		return holder;
	}
	
	override void WorldLoaded( WorldEvent e )
    {
		if( e.IsReopen )
		{
			FlashlightPlusLight hl = null;
			for( let it = ThinkerIterator.Create( "FlashlightPlusLight" ); hl = FlashlightPlusLight( it.next() ); )
			{
				hl.destroy();
				//prevents duplicate flashlights for hub-world maps
			}
		}
		for( int i = 0; i < MAXPLAYERS; i++ )
		{
			if( playeringame[ i ] )
			{
				PlayerPawn p = players[ i ].mo;
				
				FlashlightPlusHolder holder = FlashlightPlusHolder( p.FindInventory( "FlashlightPlusHolder" ) );
				if( holder )
				{
					holder.FixState();
				}
			}
		}
		
		FlashlightPlusHolder holder = null;
		for( let it = ThinkerIterator.Create( "FlashlightPlusHolder" ); holder = FlashlightPlusHolder( it.next() ); )
		{
			holder.FixState();
		}
	}
	
	override void PlayerDisconnected( PlayerEvent e )
	{ 
	//reset state on player disconnect
		FlashlightPlusLight hl = null;
		for( let it = ThinkerIterator.Create( "FlashlightPlusLight" ); hl = FlashlightPlusLight( it.next() ); )
		{
			hl.destroy();
		}
		
		FlashlightPlusHolder holder = null;
		for( let it = ThinkerIterator.Create( "FlashlightPlusHolder" ); holder = FlashlightPlusHolder( it.next() ); )
		{
			if( holder.owner && !playeringame[ holder.owner.PlayerNumber() ] )
				continue;
				
			holder.FixState();
		}
	}
	
	override void NetworkProcess( ConsoleEvent e )
	{
		if( e.name == "flashlight_plus_toggle" )
		{
			PlayerPawn p = players[ e.player ].mo;
			if( p )
            {
				FlashlightPlusHolder holder = FlashlightPlusHolder( p.FindInventory( "FlashlightPlusHolder" ) );
				if( !holder )
				{
					holder = setupFlashlightHolder( p );
				}
				holder.ToggleFlashlight();
			}
		}
		else if( e.name == "flashlight_plus_uninstall" )
		{
			PlayerPawn p = null;
			for( let it = ThinkerIterator.Create( "PlayerPawn" ); p = PlayerPawn( it.next() ); )
			{
				FlashlightPlusHolder holder = FlashlightPlusHolder( p.FindInventory( "FlashlightPlusHolder" ) );
				if( holder )
				{
					p.RemoveInventory( holder );
					holder.destroy();
				}
			}
			
			FlashlightPlusLight hl = null;
			for( let it = ThinkerIterator.Create( "FlashlightPlusLight" ); hl = FlashlightPlusLight( it.next() ); )
			{
				hl.destroy();
			}
		}
	}
}
