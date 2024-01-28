class LeaningHandler : EventHandler
{
	const LEAN_FORCE = 12.0;
	
	bool last_strafelean;
	
	double[MAXPLAYERS] leantilt;
	double[MAXPLAYERS] sidemove1;
	double[MAXPLAYERS] sidemove2;
	double[MAXPLAYERS] attackzoffset;
	
	double map(double v, double min1, double max1, double min2, double max2)
	{
		double ratio = (v - min1) / (max1 - min1);
		return (max2 - min2) * ratio + min2;
	}
	
	double lerp(double start, double dest, double amt)
	{
		return start + (dest - start) * amt;
	}
	
	override void OnRegister()
	{
		for (int i = 0; i < MAXPLAYERS; i++)
			leantilt[i] = 0.0;
	}
	
	override void PlayerEntered(PlayerEvent e)
	{
		sidemove1[e.PlayerNumber] = players[e.PlayerNumber].mo.sidemove1;
		sidemove2[e.PlayerNumber] = players[e.PlayerNumber].mo.sidemove2;
		attackzoffset[e.PlayerNumber] = players[e.PlayerNumber].mo.attackzoffset;
	}
	
	override void WorldTick()
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i])
				continue;
				
			let player = players[i].mo;
			
			bool alive = (player.health > 0);
			bool strafelean = (alive && CVar.GetCVar('cl_strafelean',players[i]).GetBool());
			let input = players[i].cmd.buttons;
			let oldinput = players[i].oldbuttons;
			
			bool strafe_left = (input & BT_MOVELEFT) && !(oldinput & BT_MOVELEFT);
			bool strafe_right = (input & BT_MOVERIGHT) && !(oldinput & BT_MOVERIGHT);
			bool unstrafe_left = !(input & BT_MOVELEFT) && (oldinput & BT_MOVELEFT);
			bool unstrafe_right = !(input & BT_MOVERIGHT) && (oldinput & BT_MOVERIGHT);
			
			if (alive && strafelean && !last_strafelean)
			{
				if (input & BT_MOVELEFT)
					SendNetworkEvent("lean_left");
				if (input & BT_MOVERIGHT)
					SendNetworkEvent("lean_right");
				player.sidemove1 = 0.0;
				player.sidemove2 = 0.0;
			}
			else if (alive && strafelean)
			{
				if (strafe_right)
					SendNetworkEvent("lean_right");
				if (strafe_left)
					SendNetworkEvent("lean_left");
				if (unstrafe_right)
					SendNetworkEvent("unlean_right");
				if (unstrafe_left)
					SendNetworkEvent("unlean_left");
			}
			else if (last_strafelean)
			{
				if (alive && players[i].onground)
				{
					if (leantilt[i] < 0.0)
						player.Thrust(LEAN_FORCE, player.angle - 90.0);
					else if (leantilt[i] > 0.0)
						player.Thrust(LEAN_FORCE, player.angle + 90.0);
				}
				leantilt[i] = 0.0;
				player.sidemove1 = sidemove1[i];
				player.sidemove2 = sidemove2[i];
			}
			last_strafelean = strafelean;
			
			player.A_SetRoll(lerp(player.roll, leantilt[i], 0.2), SPF_INTERPOLATE);
			players[i].viewz += map
			(
				abs(player.roll),
				0.0,
				90.0,
				0.0,
				-player.viewheight * players[i].CrouchFactor
			);
			player.attackzoffset = map
			(
				abs(player.roll),
				0.0,
				90.0,
				attackzoffset[i],
				player.height * -0.4
			);
			player.height = map
			(
				abs(player.roll),
				0.0,
				90.0,
				player.FullHeight * players[i].CrouchFactor,
				player.radius
			);
			player.scale.y = map
			(
				abs(player.roll),
				0.0,
				90.0,
				1.0,
				double(player.radius) / player.FullHeight
			);
			if (abs(player.roll) > 1.0 && players[i].onground)
			{
				player.vel *= 0.75;
			}
		}
	}
	
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player < 0 || !playeringame[e.Player] || !players[e.Player].mo)
			return;
			
		let player = players[e.Player].mo;
		
		double LEAN_ANGLE = CVar.GetCVar('cl_leanangle',players[e.Player]).GetFloat();
		
		if (e.Name ~== "lean_left")
		{
			leantilt[e.Player] -= LEAN_ANGLE;
			if (players[e.Player].onground)
				player.Thrust(LEAN_FORCE, player.angle + 90.0);
		}
		else if (e.Name ~== "unlean_left")
		{
			leantilt[e.Player] += LEAN_ANGLE;
			if (players[e.Player].onground)
				player.Thrust(LEAN_FORCE, player.angle - 90.0);
		}
		else if (e.Name ~== "lean_right")
		{
			leantilt[e.Player] += LEAN_ANGLE;
			if (players[e.Player].onground)
				player.Thrust(LEAN_FORCE, player.angle - 90.0);
		}
		else if (e.Name ~== "unlean_right")
		{
			leantilt[e.Player] -= LEAN_ANGLE;
			if (players[e.Player].onground)
				player.Thrust(LEAN_FORCE, player.angle + 90.0);
		}
	}
}