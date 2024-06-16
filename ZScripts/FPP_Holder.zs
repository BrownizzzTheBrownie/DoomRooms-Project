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

// Handles turning the flashlight on and off and any other effects that might run while the player has a flashlight item in their inventory
class FlashlightPlusHolder : Inventory 
{
	FlashlightPlusLight light1;
	FlashlightPlusLight light2;
	bool on;
	bool ifInertia;
	
    enum EOnOffSound
	{
	    DEFAULTCLICK = 0,
		OLDBOOP = 1,
		ALTCLICK = 2,
		SELACLICK = 3,
		HL1TOGGLE = 4,
		DDZTOGGLE = 5,
		OP4THING = 6, //What the fuck do i call this?
		PREYLIGHTER = 7,
        SEL2CLICK = 8,
        LITCLICK = 9,
        BDCLICK = 10
	};
	
	void Enable()
	{
		PlayerPawn pp = PlayerPawn( owner );
		if( pp )
		{
			if( light1 )
			{
				light1.destroy();
			}
			light1 = FlashlightPlusLight( owner.Spawn( "FlashlightPlusLight" ) ).Init( pp, false );
			
			if( CVar.GetCVar( "cl_flashlight_plus_second_beam", owner.player ).GetBool() )
			{
				if( light2 )
				{
					light2.destroy();
				}
				light2=FlashlightPlusLight( owner.Spawn( "FlashlightPlusLight" ) ).Init( pp, true );
    		}
		}
		on = true;
	}
	
	void Disable()
	{
		if( light1 )
		{
			light1.destroy();
			light1 = null;
		}
		if( light2 )
		{
			light2.destroy();
			light2 = null;
		}
		on = false;
	}
	
	FlashlightPlusHolder Init()
	{
		light1 = null;
		light2 = null;
		on = false;
		return self;
	}
	
	//ProydohaRupert code
    void PlayFlashlightToggleSound( bool toggleOn )
	{
		sound flon, floff;
		
		if( CVar.GetCVar( "cl_flashlight_plus_plus_playsound", owner.player ) )
		{
			switch( CVar.GetCVar( "cl_flashlight_plus_plus_sound",owner.player ).GetInt() )
			{
				case DEFAULTCLICK:
					flon = "flashlightOn"; 
					floff = "flashlightOff"; 
					break;
					
				case ALTCLICK:
					flon = "altflashlightOn"; 
					floff = "altflashlightOff"; 
					break;
					
				case OLDBOOP:
					flon = "oldflashlightOn"; 
					floff = "oldflashlightOff"; 
					break; 
					
				case SELACLICK:
					flon = "selacoflashlightOn"; 
					floff = "selacoflashlightOff"; 
					break;
					
				case HL1TOGGLE:
					flon = "hl1flashlightToggle"; 
					floff = flon; 
					break;
					
				case DDZTOGGLE:
					flon = "darkdoomzflashlightToggle"; 
					floff = flon; 
					break;
					
				case OP4THING:
					flon = "op4flashlightOn"; 
					floff = "op4flashlightOff"; 
					break;
					
				case PREYLIGHTER:
					flon = "preyflashlightOn"; 
					floff = "preyflashlightOff"; 
					break;
					
				case SEL2CLICK:
					flon = "selaco2flashlightOn"; 
					floff = "selaco2flashlightOff"; 
					break;
					
				case LITCLICK:
					flon = "litdoomflashlightOn"; 
					floff = "litdoomflashlightOff"; 
					break;
					
				case BDCLICK:
					flon = "brutaldoomflashlightOn"; 
					floff = "brutaldoomflashlightOff"; 
					break;
			}
		}
    		
		if( toggleOn ) 
			owner.A_StartSound( flon, CHAN_AUTO );
		else 
			owner.A_StartSound( floff, CHAN_AUTO );
	}
	
	void ToggleFlashlight()
	{
		if( on )
		{
			Disable();
			PlayFlashlightToggleSound( false );
			return;
		}
		Enable();
		PlayFlashlightToggleSound( true );
	}
	
	void FixState()
	{
		if( !owner )
		{
			destroy();
		}
		else
		{
			if( on )
				Enable();
			else
				Disable();
		}
	}
}