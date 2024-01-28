//Light

//This is the light itself, what the Holder turns on and off


class FlashlightPlusLight : Spotlight
{
	double vela, velp;
	double spring, damping;
	double offsetAngle, offsetZ;
	vector3 targetPos;
	int inertia;
	bool ifInertia;
	
	bool alertMonstersWithLight;
    int currentTickCount;
    double beamDistance;
	
	Default 
	{
		+NOINTERACTION;
	}
	
	enum ELocation 
	{
		HELMET = 0,
		RIGHT_SHOULDER = 1,
		LEFT_SHOULDER = 2,
		CAMERA = 3,
		GUN = 4,
        DDZHAND = 5,
		CUSTOM = 6
	};
	
	PlayerPawn toFollow;
	
	Vector3 offset;
	
	//This is run whenever the flashlight is turned on.
	FlashlightPlusLight Init(PlayerPawn p,bool second)
	{
		toFollow=p;
		
		Color c=CVar.GetCVar("cl_flashlight_plus_color",toFollow.player).GetString();
		
		if(second)
		{
			float mult=CVar.GetCVar("cl_flashlight_plus_color_2_mult",toFollow.player).GetFloat();
			args[0]=c.r*mult;
			args[1]=c.g*mult;
			args[2]=c.b*mult;
		}
		else
        {
			args[0]=c.r;
			args[1]=c.g;
			args[2]=c.b;
		}
		
		args[3]=CVar.GetCVar(second?"cl_flashlight_plus_intensity_2":"cl_flashlight_plus_intensity",toFollow.player).GetInt();
		
		SpotInnerAngle=CVar.GetCVar(second?"cl_flashlight_plus_inner_2":"cl_flashlight_plus_inner",toFollow.player).GetFloat();
		SpotOuterAngle=CVar.GetCVar(second?"cl_flashlight_plus_outer_2":"cl_flashlight_plus_outer",toFollow.player).GetFloat();
        
        int custOffsetX = CVar.GetCVar("cl_flashlight_plus_plus_custpos_x",toFollow.player).GetInt();
    
        int custOffsetY = CVar.GetCVar("cl_flashlight_plus_plus_custpos_y",toFollow.player).GetInt();
    
        int custOffsetZ = CVar.GetCVar("cl_flashlight_plus_plus_custpos_z",toFollow.player).GetInt();
        
        //Could i do this in a prettier way? yes.
        
        ifInertia = ((CVar.GetCVar("cl_flashlight_plus_location",toFollow.player).GetInt()) == 5);
        
		self.beamDistance = CVar.GetCVar("cl_flashlight_plus_intensity",toFollow.player).GetInt();
		
		self.alertMonstersWithLight = CVar.GetCVar("cl_flashlight_plus_plus_alertmonsters",toFollow.player).GetBool();
		
		double zBump=toFollow.height / 15.0;
		
		switch(CVar.GetCVar("cl_flashlight_plus_location",toFollow.player).GetInt()) 
		{
		case (HELMET):
			offset=(0,0,zBump);
			break;
		case (RIGHT_SHOULDER):
			offset=(toFollow.radius,0,-zBump);
			break;
		case (LEFT_SHOULDER):
			offset=(toFollow.radius*-1,0,-zBump);
			break;
		case (CAMERA):
			offset=(0,0,0);
			break;
		case (GUN):
            offset=(0,0,-8);
            break;
        case (DDZHAND):
            //tweak the springiness here, if you make this a cvar it makes the light spin around frantically for some reason
            //for example, the shoulder positions in darkdoomz have inertia at 2, spring at 0.35, and damping at 0.75, while helmet has all of them at 1.
 			spring = 0.25;
			damping = 0.2;
			inertia = 4;
			offsetAngle = 0;
			//set this to 0 for a centered light
			offsetZ = -13;
			self.angle = toFollow.angle;
			self.pitch = toFollow.pitch;
			self.spring = spring;
			self.damping = damping;
			self.inertia = inertia;
			self.offsetAngle = offsetAngle;
		    self.offsetZ = offsetZ;
            break;
        case (CUSTOM):
            offset=(custOffsetX,custOffsetY,custOffsetZ);
                break;
		default:
			offset=(0,0,0);
			break;
		}
		
		return self;
	}
	
	override void Tick() 
	{
	    //Increment the tick count every tick, BD:BE says this is for "optimization", but i doubt it, so this pretty much creates a "reaction time" effect for the monsters.
	    currentTickCount++;
	    
		super.Tick();
		if(toFollow && toFollow.player && ifInertia) //check for player so it doesn't crash the game.
		{
		    //This is the DarkDoomZ position code, it's a whole lot more complicated than the original one, but it's a lot fancier, taking the player velocity into account to create a pretty neat swaying effect.
			if(inertia == 0) inertia = 1;
			targetpos = toFollow.vec3Angle(
				2 + (6 * abs(sin(offsetAngle))),
				toFollow.angle + offsetAngle,
				toFollow.player.viewz - toFollow.pos.z + offsetZ,
				false);
			vel.x += DampedSpring(pos.x, targetpos.x, vel.x, 1, 1);
			vel.y += DampedSpring(pos.y, targetpos.y, vel.y, 1, 1);
			vel.z += DampedSpring(pos.z, targetpos.z, vel.z, 1, 1);
			vela  += DampedSpring(angle, toFollow.angle, vela, spring, damping);
			velp  += DampedSpring(pitch, toFollow.pitch, velp, spring, damping);
			setOrigin(pos + vel, true);
			A_SetAngle(angle + (vela / inertia), true);
			A_SetPitch(pitch + (velp / inertia), true);
		}
		else
        {
    	    if (toFollow && toFollow.player) //same here.
    	    {
    	        //This is the original position code, it's pretty simple, just snap the light actor to where the player is looking.
        	    A_SetAngle(toFollow.angle,SPF_INTERPOLATE);
        		A_SetPitch(toFollow.pitch,SPF_INTERPOLATE);
        		SetOrigin(toFollow.pos+(RotateVector((offset.x,offset.y),toFollow.angle-90.0),toFollow.player.viewheight+offset.z),true);
        		Super.Tick();
        	}
    	}
        //BD:BE monster alerting stuff, this was a nightmare to implement
        //Credits to Blackmore1014 for this
        if (currentTickCount % 15 == 0 && self.alertMonstersWithLight && self.SpotOuterAngle > 0) //how to make your game run like shit 101
        {
				
		    // look for monsters around you and alert them depending on beam width.
			double cosBeamAngle = cos(self.SpotOuterAngle);
				
			double distanceToWake = self.beamDistance / sqrt(1.0 - cosBeamAngle);
			Vector3 vectorBeamDirection =(cos(self.angle), sin(self.angle), sin( - self.pitch)).unit();
						
			BlockThingsIterator it = BlockThingsIterator.Create(self, distanceToWake);
			while (it.Next())
			{
					Actor mo = it.thing;
					
					//only consider monsters, not yet alerted:
					if (mo.bIsMonster)
					{
						Vector3 vectorToMonster = self.Vec3To(mo).unit();
						
					//dot product is cos of angle between the vectors.
					double cosAngleMonsterBeam = vectorToMonster dot vectorBeamDirection;
						
					//also check real sight
					if ((cosAngleMonsterBeam >= cosBeamAngle) && (self.distance3DSquared(mo) <= distanceToWake **2) && self.CheckSight(mo))
					{
						//mark as last heard to ping them
						//no need to do: self.toFollow.SoundAlert(mo, false,1.0);
						mo.lastheard = self.toFollow;
					}
				}
			}
		}
	}
	    
	double DampedSpring(double p, double r, double v, double k, double d) 
	{
		return -(d * v) - (k * (p - r));
	}
}
