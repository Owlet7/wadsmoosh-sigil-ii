//-----------------------------------------------------------------------------
//
// Copyright 2024 jdbrowndev, Owlet VII
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/
//
//-----------------------------------------------------------------------------
//

class Incinerator : DoomWeapon
{
    Default
    {
		Weapon.SelectionOrder 200;
		Weapon.SlotNumber 6;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 20;
		Weapon.AmmoType "Fuel";
		Inventory.PickupMessage "$ID24_GOTINCINERATOR";
		Tag "$TAG_INCINERATOR";
    }

    States
    {
		Ready:
			FLMG A 1 A_WeaponReady;
			Loop;
		Deselect:
			FLMG A 1 A_Lower;
			Loop;
		Select:
			FLMG A 1 A_Raise;
			Loop;
		Fire:
			FLMF A 0 Bright A_Jump(128, "FireSound2");
			FLMF A 0 Bright A_StartSound("weapons/incinerator/incfi1");
			Goto FireReal;	
		FireSound2:
			FLMF A 0 Bright A_StartSound("weapons/incinerator/incfi2");
			Goto FireReal;
		FireReal:
			FLMF A 0 Bright A_GunFlash;
			FLMF A 1 Bright A_FireIncinerator();
			FLMF B 1 Bright;
			FLMG A 1;
			FLMG A 0 A_ReFire;
			Goto Ready;
		Flash:
			TNT1 A 2 A_Light2;
			TNT1 A 1 A_Light1;
			Goto LightDone;
		Spawn:
			INCN A -1;
			Stop;
    }

	action void A_FireIncinerator()
	{
		if (player == null)
		{
			return;
		}

		Weapon weap = player.ReadyWeapon;
		if (weap != null && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
		{
			if (!weap.DepleteAmmo(weap.bAltFire, true))
				return;
		}
		
		SpawnPlayerMissile("IncineratorFlame");
	}
}

class IncineratorFlame : Actor
{
	const INCINERATOR_FLAME_DAMAGE = 5;
	const INCINERATOR_FLAME_VELOCITY = 40;
	const INCINERATOR_BURN_DAMAGE = 5;
	const INCINERATOR_BURN_RADIUS = 64;

	Default
	{
		Damage INCINERATOR_FLAME_DAMAGE;
		Speed INCINERATOR_FLAME_VELOCITY;
		Radius 13;
		Height 8;
		RenderStyle "Translucent";
		Alpha 0.65;

		+NOBLOCKMAP
		+NOGRAVITY
		+DROPOFF
		+MISSILE
		+FORCERADIUSDMG
	}

	States
	{
		Spawn:
			TNT1 A 1 Bright;
			IFLM A 2 Bright;
			IFLM B 2 Bright A_StartSound("weapons/incinerator/incbrn");
			IFLM CDEFGH 2 Bright;
			Stop;
		Death:
			IFLM A 0 Bright A_Jump(128, "DeathSound2");
			IFLM A 0 Bright A_StartSound("weapons/incinerator/incht1");
			Goto Burninate;
		DeathSound2:
			IFLM A 0 Bright A_StartSound("weapons/incinerator/incht2");
			Goto Burninate;
		Burninate:
			IFLM I 2 Bright A_Explode(INCINERATOR_BURN_DAMAGE, INCINERATOR_BURN_RADIUS);
			IFLM J 2 Bright;
			IFLM I 2 Bright;
			IFLM J 2 Bright A_Explode(INCINERATOR_BURN_DAMAGE, INCINERATOR_BURN_RADIUS);
			IFLM K 2 Bright;
			IFLM J 2 Bright;
			IFLM K 2 Bright A_Explode(INCINERATOR_BURN_DAMAGE, INCINERATOR_BURN_RADIUS);
			IFLM L 2 Bright;
			IFLM K 2 Bright A_StartSound("weapons/incinerator/incht3");
			IFLM L 2 Bright A_Explode(INCINERATOR_BURN_DAMAGE, INCINERATOR_BURN_RADIUS);
			IFLM M 2 Bright;
			IFLM L 2 Bright;
			IFLM M 2 Bright A_Explode(INCINERATOR_BURN_DAMAGE, INCINERATOR_BURN_RADIUS);
			IFLM N 2 Bright;
			IFLM M 2 Bright;
			IFLM N 2 Bright A_Explode(INCINERATOR_BURN_DAMAGE, INCINERATOR_BURN_RADIUS);
			IFLM O 2 Bright;
			IFLM N 2 Bright;
			IFLM O 2 Bright;
			IFLM POP 2 Bright;
			Stop;
	}
}

//temp weap

class Heatwave : BFG9000
{
	Default
	{
		Weapon.AmmoType "Fuel";
		Weapon.SlotNumber 7;
	}
}

//ammo

class Fuel : Ammo
{
	Default
	{
		Inventory.PickupMessage "$ID24_GOTFUELCAN";
		Inventory.Amount 10;
		Inventory.MaxAmount 150;
		Ammo.BackpackAmount 10;
		Ammo.BackpackMaxAmount 300;
		Inventory.Icon "FCPUA0";
		Tag "$AMMO_FUEL";
	}
	States
	{
	Spawn:
		FCPU A -1;
		Stop;
	}
}

class FuelTank : Fuel
{
	Default
	{
		Inventory.PickupMessage "$ID24_GOTFUELTANK";
		Inventory.Amount 50;
	}
	States
	{
	Spawn:
		FTNK A -1;
		Stop;
	}
}

class Id1WeaponHandler : EventHandler
{
	override void CheckReplacement (ReplaceEvent e)
	{
		string mapName = level.MapName.MakeLower();
		if ( CVar.FindCVar("wf_id1_weapswap").GetBool() )
		{
			if ( mapName.Left(3) == "id_" )
			{
				if (e.Replacee is "PlasmaRifle")
					e.Replacement = "Incinerator";
				if (e.Replacee is "BFG9000")
					e.Replacement = "Heatwave";
				if (e.Replacee is "Cell")
					e.Replacement = "Fuel";
				if (e.Replacee is "CellPack")
					e.Replacement = "FuelTank";
			}
			else
			{
				if (e.Replacee is "Incinerator")
					e.Replacement = "PlasmaRifle";
				if (e.Replacee is "Heatwave")
					e.Replacement = "BFG9000";
				if (e.Replacee is "Fuel")
					e.Replacement = "Cell";
				if (e.Replacee is "FuelTank")
					e.Replacement = "CellPack";
			}
		}
	}
}
