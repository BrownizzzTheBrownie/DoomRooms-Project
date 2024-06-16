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

// This is the spotlight itself, what the Holder turns on and off
class FlashlightPlusLight : Spotlight
{
	double vela, velp;
	double spring, damping;
	int inertia;
	bool shouldSway;
	
	bool alertMonstersWithLight;
	
	vector3 posToSet;
	double pitchToSet;
	double angleToSet;
	
	bool thisIsLight2;
	
	color baseColor;
	bool noise;
	double minNoise;
	
	Default 
	{
		+NOINTERACTION;
	}
	
	enum ELocation 
	{
		LOC_HELMET = 0,
		LOC_RIGHT_SHOULDER = 1,
		LOC_LEFT_SHOULDER = 2,
		LOC_CAMERA = 3,
		LOC_GUN = 4,
		LOC_CUSTOM = 5
	};
	
	enum ESwayType 
	{
		SWT_NONE = 0,
		SWT_SPRINGY = 1,
		SWT_STIFF = 2,
		SWT_CUSTOM = 3
	};
	
	PlayerPawn toFollow;
	
	Vector3 offset;
	
	// This is run whenever the flashlight is turned on.
	FlashlightPlusLight Init( PlayerPawn p, bool second )
	{
		toFollow = p;
		
		Color c = CVar.GetCVar( "cl_flashlight_plus_color", toFollow.player ).GetString();
		
		if( second )
		{
			float mult = CVar.GetCVar( "cl_flashlight_plus_color_2_mult", toFollow.player ).GetFloat();
			args[0] = c.r * mult;
			args[1] = c.g * mult;
			args[2] = c.b * mult;
		}
		else
        {
			args[0] = c.r;
			args[1] = c.g;
			args[2] = c.b;
		}
		
		baseColor = c;
		
		thisIsLight2 = second;
		
		noise = CVar.GetCVar( "cl_flashlight_plus_plus_noise", toFollow.player ).GetBool();
		minNoise = CVar.GetCVar( "cl_flashlight_plus_plus_noise_min", toFollow.player ).GetFloat();
		bATTENUATE = CVar.GetCVar( "cl_flashlight_plus_plus_attenuated", toFollow.player ).GetBool();
		
		string suffix = second ? "_2" : "";
		
		// [gng] This is the intensity, i don't think there's a nicely named variable for it, and i'm too lazy to check
		args[3] = CVar.GetCVar( "cl_flashlight_plus_intensity"..suffix, toFollow.player ).GetInt();
		
		SpotInnerAngle = CVar.GetCVar( "cl_flashlight_plus_inner"..suffix, toFollow.player ).GetFloat();
		SpotOuterAngle = CVar.GetCVar( "cl_flashlight_plus_outer"..suffix, toFollow.player ).GetFloat();
		
		alertMonstersWithLight = CVar.GetCVar( "cl_flashlight_plus_plus_alertmonsters", toFollow.player ).GetBool();
		
		double zBump = toFollow.height / 15.0;
		
		switch( CVar.GetCVar( "cl_flashlight_plus_plus_sway_type", toFollow.player ).GetInt() )
		{
			default:
			case SWT_NONE:
				shouldSway = false;
				inertia = 1;
				spring = 1;
				damping = 1;
				break;
				
			case SWT_SPRINGY:
				shouldSway = true;
				spring = 0.25;
				damping = 0.2;
				inertia = 4;
				break;
		
			case SWT_STIFF:
				shouldSway = true;
				spring = 0.35;
				damping = 0.75;
				inertia = 2;
				break;
				
			case SWT_CUSTOM:
				shouldSway = true;
				spring = CVar.GetCVar( "cl_flashlight_plus_plus_sway_spring", toFollow.player ).GetFloat();
				damping = CVar.GetCVar( "cl_flashlight_plus_plus_sway_damping", toFollow.player ).GetFloat();
				inertia = CVar.GetCVar( "cl_flashlight_plus_plus_sway_inertia", toFollow.player ).GetInt();
				break;
		}
			
		if( shouldSway )
		{
			angle = toFollow.angle;
			pitch = toFollow.pitch;
		}
		
		switch( CVar.GetCVar( "cl_flashlight_plus_location", toFollow.player ).GetInt() ) 
		{
			case LOC_HELMET:
				offset = ( 0, 0, zBump );
				break;
				
			case LOC_RIGHT_SHOULDER:
				offset = ( toFollow.radius, 0, -zBump );
				break;
				
			case LOC_LEFT_SHOULDER:
				offset = ( -toFollow.radius, 0, -zBump );
				break;
				
			case LOC_CAMERA:
				offset = ( 0, 0, 0 );
				break;
				
			case LOC_GUN:
	            offset = ( 0, 0, -8 );
	            break;
	            
	        case LOC_CUSTOM:
	        	int custOffsetX = CVar.GetCVar( "cl_flashlight_plus_plus_custpos_x", toFollow.player ).GetInt();
		        int custOffsetY = CVar.GetCVar( "cl_flashlight_plus_plus_custpos_y", toFollow.player ).GetInt();
		        int custOffsetZ = CVar.GetCVar( "cl_flashlight_plus_plus_custpos_z", toFollow.player ).GetInt();
		        
	            offset = ( custOffsetX, custOffsetY, custOffsetZ );
	            break;
	            
			default:
				offset = ( 0, 0, 0 );
				break;
		}

		return self;
	}
	
	override void Tick() 
	{
		Super.Tick();
		
		if( !( toFollow && toFollow.player ) )
			return;
	
        if( shouldSway )
		{
		    // [gng] This is the DarkDoomZ position code, it's a whole lot more complicated than the original one, but it's a lot fancier, taking the player velocity into account to create a pretty neat swaying effect.
		    // Created by Caligari87, available at https://github.com/caligari87/darkdoomz/blob/bcaaab81d335b1b9544cb984ea05d2f20642cd86/zscript.zsc#L336, i did not write any of this.
			if( inertia == 0 ) 
				inertia = 1;
				
			vel.x += DampedSpring( pos.x, toFollow.pos.x, vel.x, 1, 1 );
			vel.y += DampedSpring( pos.y, toFollow.pos.y, vel.y, 1, 1 );
			vel.z += DampedSpring( pos.z, toFollow.pos.z, vel.z, 1, 1 );
			vela  += DampedSpring( angle, toFollow.angle, vela, spring, damping );
			velp  += DampedSpring( pitch, toFollow.pitch, velp, spring, damping );
			posToSet = pos + vel;
			angleToSet = angle + ( vela / inertia );
			pitchToSet = pitch + ( velp / inertia );
		}
		else
		{
	        // [gng] This is the original position code, it's pretty simple, just snap the light actor to where the player is looking.
    	    posToSet = toFollow.pos;
    	    angleToSet = toFollow.angle;
    		pitchToSet = toFollow.pitch;
		}
		
		if( noise )
		{
			float flicker = frandom( minNoise, 1 );
			args[0] = baseColor.r * flicker;
			args[1] = baseColor.g * flicker;
			args[2] = baseColor.b * flicker;
		}
		
		A_SetAngle( angleToSet, SPF_INTERPOLATE );
		A_SetPitch( pitchToSet, SPF_INTERPOLATE );
		SetOrigin( posToSet + ( RotateVector( ( offset.x, offset.y * ( ( 90 + -abs( toFollow.pitch ) ) / 90.0 ) ), toFollow.angle - 90.0 ), toFollow.player.viewheight + offset.z + ( offset.y * ( -toFollow.Pitch / 90.0 ) ) ), true );

        // [gng] BD:BE monster alerting stuff, this was a nightmare to implement
        // Credits to Blackmore1014 for this
        if( !thisIsLight2 && level.time % 15 == 0 && alertMonstersWithLight && SpotOuterAngle > 0 && level.time > 5 * TICRATE )
        {
		    // look for monsters around you and alert them depending on beam width.
			double cosBeamAngle = cos( SpotOuterAngle );
				
			double distanceToWake = args[3] / sqrt( 1.0 - cosBeamAngle );
			Vector3 vectorBeamDirection = ( cos( angle ), sin( angle ), sin( -pitch ) ).unit();
						
			BlockThingsIterator it = BlockThingsIterator.Create( self, distanceToWake );
			while ( it.Next() )
			{
					Actor mo = it.thing;
					
					//only consider monsters, not yet alerted:
					if( mo.bIsMonster )
					{
						Vector3 vectorToMonster = Vec3To( mo ).unit();
						
					//dot product is cos of angle between the vectors.
					double cosAngleMonsterBeam = vectorToMonster dot vectorBeamDirection;
						
					//also check real sight
					if( ( cosAngleMonsterBeam >= cosBeamAngle ) && ( distance3DSquared( mo ) <= distanceToWake ** 2 ) && CheckSight( mo ) )
					{
						//mark as last heard to ping them
						//no need to do: toFollow.SoundAlert( mo, false,1.0 );
						mo.lastheard = toFollow;
					}
				}
			}
		}
	}
	    
	double DampedSpring( double p, double r, double v, double k, double d ) 
	{
		return -( d * v ) - ( k * ( p - r ) );
	}
}
