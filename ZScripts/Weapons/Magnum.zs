// This is a FAKE ammo used to track the amount of rounds in chamber
Class BPistolAmmo2 : Ammo
{
	Default
	{
		Inventory.Amount 6;
		Inventory.MaxAmount 6;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount 6;
		Decal "BulletChip";
	}
}

Class Ammo44 : Ammo
{
	//$Category ".44 Magnum"
	//$Title ".44 Ammo"
	Default
	{
		Scale 0.6;
		Inventory.Amount 6;
		Inventory.MaxAmount 120;
		Ammo.BackpackAmount 36;
		Ammo.BackpackMaxAmount 240;
		Inventory.Icon "HICAA0";
		Inventory.PickupMessage "Picked up some .44 ammo";
		Inventory.PickupSound "misc/i_pkup";
	}
	States
	{
		Spawn:
		HICA A -1;
		Loop;
	}
}

class magnumRespect : Inventory
{
	Default
	{
		//-INVBAR
		//Inventory.Amount 0;
		Inventory.MaxAmount 1;
	}
}

// A 6-shot Magnum revolver with strong damage.
class Magnum : DoomWeapon
{
	//$Category ".44 Magnum"
	//$Title ".44 Magnum"
 	Default
	{
		Weapon.SelectionOrder 1090;
		+WEAPON.NOALERT
		+WEAPON.NOAUTOAIM
		Weapon.slotnumber 2;
		Weapon.Ammogive 6;
		Weapon.AmmoUse1 0;
		Weapon.AmmoUse2 0;
		Weapon.AmmoType1 "Ammo44";
		Weapon.AmmoType2 "BPistolAmmo2";
		Inventory.PickupMessage "Picked up Colt Magnum";
		Tag "Colt Magnum";
		scale 0.45;
	}
	States
	{
	Ready:
		REVO A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		NULL A 0 A_JumpifInventory("magnumRespect", 1, "ready");
		NULL A 0 A_GiveInventory("magnumRespect", 1);
		NULL A 0 A_GiveInventory("Ammo44", 6);
		REVQ ABCD 2 A_WeaponReady(WRF_NOFIRE|WRF_NOSWITCH);
		REVR AB 2 A_WeaponReady(WRF_NOFIRE|WRF_NOSWITCH);
		NULL A 0 A_PlaySound("CHAMB");
		REVR CDEFGHI 2 A_WeaponReady(WRF_NOFIRE|WRF_NOSWITCH);
		NULL A 0 A_TakeInventory("Ammo44", 6);
		NULL A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		NULL A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		NULL A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		NULL A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		NULL A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		NULL A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		NULL A 0 A_PlaySound("DCASING",CHAN_BODY, 2.0);
		REVR JKLMNOPQ 2 A_WeaponReady(WRF_NOFIRE|WRF_NOSWITCH);
		NULL A 0 A_PlaySound("SNAP");
		REVR RSTUVWXYEDC 2 A_WeaponReady(WRF_NOFIRE|WRF_NOSWITCH);
		NULL A 0 A_PlaySound("pistol_u");
		REVR BA 2 A_WeaponReady(WRF_NOFIRE|WRF_NOSWITCH);
		REVQ DCBA 2 A_WeaponReady(WRF_NOFIRE|WRF_NOSWITCH);
		NULL A 0 A_GiveInventory("BPistolAmmo2", 6);
		Loop;
	Deselect:
		TNT1 A 0 A_PlaySound("DRAW", CHAN_WEAPON);
	PutAway:
		REVO C 1 A_Lower;
		Loop;
	Select:
		TNT1 A 0 A_Raise;
		Loop;
	Selectloop:
		TNT1 A 0 A_PlaySound("DRAW", CHAN_WEAPON);
		REVO C 1;
	PullOut:
		REVO A 1 A_Raise;
		Loop;
	Fire:
	    TNT1 A 0 A_JumpIfInventory("BPistolAmmo2",1,1);
        Goto NoAmmo;
		REVF A 2 BRIGHT;
		TNT1 A 0 A_TakeInventory("BPistolAmmo2",1);
		TNT1 A 0 A_AlertMonsters;
		TNT1 A 0 A_FireBullets (0, 0, 1, 30, "MagnumPuff", FBF_NORANDOM);
		TNT1 A 0 A_PlaySound("weapons/HeavyPistolfire", CHAN_WEAPON);
		REVO B 2;
		REVO C 2;
		REVO D 4;
		REVO C 2;
		REVO B 2;
		REVO A 5 A_ReFire;
		Goto Ready;
	NoAmmo:	
		REVO A 2 A_PlaySound("weapons/empty");
		REVO BCB 4;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIfInventory("Ammo44",1,1);
		Goto Ready;
		TNT1 A 0 A_JumpIfInventory("BPistolAmmo2",6,"Ready");
		// Uncomment the next line if you want it to waste extra bullets you didn't spend before reload (realistic but anti-player)
		TNT1 A 0 A_Takeinventory("BPistolAmmo2",6);
		REVQ ABCD 2;
		REVR AB 2;
		TNT1 A 0 A_PlaySound("CHAMB");
		REVR CDEFGHI 2;
		TNT1 A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		TNT1 A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		TNT1 A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		TNT1 A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		TNT1 A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		TNT1 A 0  A_SpawnItemEx("BulletCasing", frandom(15,20), 0,frandom(height/2,height/2+frandom(0.5,1.5)),0,frandom(1.5,3.5),frandom(-2,-5),0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("DCASING",CHAN_BODY, 2.0);
		REVR JKLMNOPQ 2;
		TNT1 A 0 A_PlaySound("SNAP");
		REVR RSTUVWXYEDC 2;
		TNT1 A 0 A_PlaySound("pistol_u");
		REVR BA 2;
		REVQ DCBA 2;
	ReloadRepeat:	
		TNT1 A 0 A_JumpIfInventory("BPistolAmmo2", 6, "ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("Ammo44", 1, 1);
		Goto ReloadFinish;
		TNT1 A 0 A_GiveInventory("BPistolAmmo2", 1);
		TNT1 A 0 A_Takeinventory("Ammo44",1);
		Goto ReloadRepeat;
	ReloadFinish:
		Goto Ready;
 	Spawn:
		REVI A -1;
		Stop;
	}
}

class MagnumPuff : BulletPuff //Pistol, MP40
{
	Default
	{
		+NOEXTREMEDEATH
		VSpeed 2;
		Decal "Bulletchip";
	}
	States
	{
		Spawn:
			TNT1 A 0;
			TNT1 AAAA 0 A_SpawnProjectile("RicochetSparks",1,0,random(0,360),2,random(0,360));
			PUFF A 1 Bright;
			PUFF B 2;
		Melee:
			PUFF CD 2;
			Stop;
	}
}

class RicochetSparks: Actor
{
	Default
		{
		+DOOMBOUNCE
		+NOGRAVITY
		+DONTSPLASH
		+NOBLOCKMAP
		+FORCEXYBILLBOARD
		+CLIENTSIDEONLY
		+Missile
		RenderStyle "ADD";
		Alpha 0.5;
		Speed 10;
		Radius 0;
		Height 0;
		Mass 0;
		Scale 0.125;
		Gravity 1;
		BounceFactor 0.5;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		PUFF A 1 Bright;
		PUFF AAAA 1 Bright A_FadeOut(0.09);
		Stop;
	}
}