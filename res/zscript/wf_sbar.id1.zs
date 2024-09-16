//-----------------------------------------------------------------------------
//
// Copyright 1993-2023 id Software, Randy Heit, Christoph Oelckers et.al.
// Copyright 2024 Owlet VII
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

class WadFusionStatusBarId24 : BaseStatusBar
{
	HUDFont mHUDFont;
	HUDFont mIndexFont;
	HUDFont mAmountFont;
	InventoryBarState diparms;
	

	override void Init()
	{
		Super.Init();
		SetSize(32, 320, 200);

		// Create the font used for the fullscreen HUD
		Font fnt = "HUDFONT_DOOM";
		mHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft, 1, 1);
		fnt = "INDEXFONT_DOOM";
		mIndexFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);
		mAmountFont = HUDFont.Create("INDEXFONT");
		diparms = InventoryBarState.Create();
	}

	override void Draw (int state, double TicFrac)
	{
		Super.Draw (state, TicFrac);

		if (state == HUD_StatusBar)
		{
			BeginStatusBar();
			DrawMainBar (TicFrac);
		}
		else if (state == HUD_Fullscreen)
		{
			BeginHUD();
			DrawFullScreenStuff ();
		}
	}

	protected void DrawMainBar (double TicFrac)
	{
		String mapName = level.MapName.MakeLower();
		if ( mapName.Left(3) == "lr_" && CVar.FindCVar("wf_id1_weapswap").GetBool() )
			DrawImage("STBRFUEL", (-53, 168), DI_ITEM_OFFSETS);
		else
			DrawImage("STBAR", (0, 168), DI_ITEM_OFFSETS);
		DrawImage("STTPRCNT", (90, 171), DI_ITEM_OFFSETS);
		DrawImage("STTPRCNT", (221, 171), DI_ITEM_OFFSETS);
		
		Inventory a1 = GetCurrentAmmo();
		if (a1 != null) DrawString(mHUDFont, FormatNumber(a1.Amount, 3), (44, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
		DrawString(mHUDFont, FormatNumber(CPlayer.health, 3), (90, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
		DrawString(mHUDFont, FormatNumber(GetArmorAmount(), 3), (221, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);

		DrawBarKeys();
		DrawBarAmmo();
		
		if (deathmatch || teamplay)
		{
			DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3), (138, 171), DI_TEXT_ALIGN_RIGHT);
		}
		else
		{
			DrawBarWeapons();
		}
		
		if (multiplayer)
		{
			DrawImage("STFBANY", (143, 168), DI_ITEM_OFFSETS|DI_TRANSLATABLE);
		}
		
		if (CPlayer.mo.InvSel != null && !Level.NoInventoryBar)
		{
			DrawInventoryIcon(CPlayer.mo.InvSel, (160, 198), DI_DIMDEPLETED);
			if (CPlayer.mo.InvSel.Amount > 1)
			{
				DrawString(mAmountFont, FormatNumber(CPlayer.mo.InvSel.Amount), (175, 198-mIndexFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
			}
		}
		else
		{
			DrawTexture(GetMugShot(5), (143, 168), DI_ITEM_OFFSETS);
		}
		if (isInventoryBarVisible())
		{
			DrawInventoryBar(diparms, (48, 169), 7, DI_ITEM_LEFT_TOP);
		}
		
	}
	
	protected virtual void DrawBarKeys()
	{
		bool locks[6];
		String image;
		for(int i = 0; i < 6; i++) locks[i] = CPlayer.mo.CheckKeys(i + 1, false, true);
		// key 1
		if (locks[1] && locks[4]) image = "STKEYS6";
		else if (locks[1]) image = "STKEYS0";
		else if (locks[4]) image = "STKEYS3";
		DrawImage(image, (239, 171), DI_ITEM_OFFSETS);
		// key 2
		if (locks[2] && locks[5]) image = "STKEYS7";
		else if (locks[2]) image = "STKEYS1";
		else if (locks[5]) image = "STKEYS4";
		else image = "";
		DrawImage(image, (239, 181), DI_ITEM_OFFSETS);
		// key 3
		if (locks[0] && locks[3]) image = "STKEYS8";
		else if (locks[0]) image = "STKEYS2";
		else if (locks[3]) image = "STKEYS5";
		else image = "";
		DrawImage(image, (239, 191), DI_ITEM_OFFSETS);
	}
	
	protected virtual void DrawBarAmmo()
	{
		String mapName = level.MapName.MakeLower();
		let cell = CPlayer.mo.FindInventory("Cell");
		let fuel = CPlayer.mo.FindInventory("Fuel");
		let plasmaRifle = CPlayer.mo.FindInventory("PlasmaRifle");
		let bfg9000 = CPlayer.mo.FindInventory("BFG9000");
		let incinerator = CPlayer.mo.FindInventory("Incinerator");
		let heatwave = CPlayer.mo.FindInventory("Heatwave");
		// Only show id24 style ammo if the player has both cell and fuel ammo, or if wf_hud_id24 is true
		if ( CVar.FindCVar("wf_hud_id24").GetBool() ||
			( mapName.Left(3) == "lr_" && CVar.FindCVar("wf_id1_weapswap").GetBool() && cell != null && (plasmaRifle || bfg9000) ) ||
			( mapName.Left(3) == "lr_" && !CVar.FindCVar("wf_id1_weapswap").GetBool() && fuel != null && (incinerator || heatwave) ) ||
			( mapName.Left(3) != "lr_" && fuel != null && (incinerator || heatwave) ) )
		{
			DrawImage("STAMMO24", (249, 168), DI_ITEM_OFFSETS);
			int amt1, maxamt;
			[amt1, maxamt] = GetAmount("Clip");
			DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 169), DI_TEXT_ALIGN_RIGHT);
			DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 169), DI_TEXT_ALIGN_RIGHT);
			
			[amt1, maxamt] = GetAmount("Shell");
			DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 175), DI_TEXT_ALIGN_RIGHT);
			DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 175), DI_TEXT_ALIGN_RIGHT);
			
			[amt1, maxamt] = GetAmount("RocketAmmo");
			DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 181), DI_TEXT_ALIGN_RIGHT);
			DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 181), DI_TEXT_ALIGN_RIGHT);
			
			[amt1, maxamt] = GetAmount("Cell");
			DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 187), DI_TEXT_ALIGN_RIGHT);
			DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 187), DI_TEXT_ALIGN_RIGHT);
			
			[amt1, maxamt] = GetAmount("Fuel");
			DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 193), DI_TEXT_ALIGN_RIGHT);
			DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 193), DI_TEXT_ALIGN_RIGHT);
		}
		else
		{
			int amt1, maxamt;
			[amt1, maxamt] = GetAmount("Clip");
			DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 173), DI_TEXT_ALIGN_RIGHT);
			DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 173), DI_TEXT_ALIGN_RIGHT);
			
			[amt1, maxamt] = GetAmount("Shell");
			DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 179), DI_TEXT_ALIGN_RIGHT);
			DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 179), DI_TEXT_ALIGN_RIGHT);
			
			[amt1, maxamt] = GetAmount("RocketAmmo");
			DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 185), DI_TEXT_ALIGN_RIGHT);
			DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 185), DI_TEXT_ALIGN_RIGHT);
			
			if ( mapName.Left(3) == "lr_" && CVar.FindCVar("wf_id1_weapswap").GetBool() )
			{
				[amt1, maxamt] = GetAmount("Fuel");
				DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 191), DI_TEXT_ALIGN_RIGHT);
				DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 191), DI_TEXT_ALIGN_RIGHT);
			}
			else
			{
				[amt1, maxamt] = GetAmount("Cell");
				DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 191), DI_TEXT_ALIGN_RIGHT);
				DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 191), DI_TEXT_ALIGN_RIGHT);
			}
		}
	}
	
	protected virtual void DrawBarWeapons()
	{
		DrawImage("STARMS", (104, 168), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(2)? "STYSNUM2" : "STGNUM2", (111, 172), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(3)? "STYSNUM3" : "STGNUM3", (123, 172), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(4)? "STYSNUM4" : "STGNUM4", (135, 172), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(5)? "STYSNUM5" : "STGNUM5", (111, 182), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(6)? "STYSNUM6" : "STGNUM6", (123, 182), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(7)? "STYSNUM7" : "STGNUM7", (135, 182), DI_ITEM_OFFSETS);
	}

	protected void DrawFullScreenStuff ()
	{
		// Set ultrawide
		int ultraWide = CVar.FindCVar("wf_hud_ultrawide").GetInt();
		
		Vector2 iconbox = (40, 20);
		// Draw health
		let berserk = CPlayer.mo.FindInventory("PowerStrength");
		int hudArmorOffset;
		if ( CVar.FindCVar("wf_hud_swaphealtharmor").GetBool() )
				hudArmorOffset = 20;
		DrawImage(berserk? "PSTRA0" : "MEDIA0", (20 + ultraWide, -2 - hudArmorOffset));
		DrawString(mHUDFont, FormatNumber(CPlayer.health, 3), (44 + ultraWide, -20 - hudArmorOffset));
		
		let armor = CPlayer.mo.FindInventory("BasicArmor");
		int hudHealthOffset;
		if ( CVar.FindCVar("wf_hud_swaphealtharmor").GetBool() )
				hudHealthOffset = 20;
		if (armor != null && armor.Amount > 0)
		{
			DrawInventoryIcon(armor, (20 + ultraWide, -22 + hudHealthOffset));
			DrawString(mHUDFont, FormatNumber(armor.Amount, 3), (44 + ultraWide, -40 + hudHealthOffset));
		}
		Inventory ammotype1, ammotype2;
		[ammotype1, ammotype2] = GetCurrentAmmo();
		int invY = -20;
		if (ammotype1 != null)
		{
			DrawInventoryIcon(ammotype1, (-14 - ultraWide, -4));
			DrawString(mHUDFont, FormatNumber(ammotype1.Amount, 3), (-30 - ultraWide, -20), DI_TEXT_ALIGN_RIGHT);
			invY -= 20;
		}
		if (ammotype2 != null && ammotype2 != ammotype1)
		{
			DrawInventoryIcon(ammotype2, (-14 - ultraWide, invY + 17));
			DrawString(mHUDFont, FormatNumber(ammotype2.Amount, 3), (-30 - ultraWide, invY), DI_TEXT_ALIGN_RIGHT);
			invY -= 20;
		}
		if (!isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.mo.InvSel != null)
		{
			DrawInventoryIcon(CPlayer.mo.InvSel, (-14 - ultraWide, invY + 17), DI_DIMDEPLETED);
			DrawString(mHUDFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (-30 - ultraWide, invY), DI_TEXT_ALIGN_RIGHT);
		}
		if (deathmatch)
		{
			DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3), (-3 - ultraWide, 1), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
		}
		else
		{
			DrawFullscreenKeys();
		}
		
		if (isInventoryBarVisible())
		{
			DrawInventoryBar(diparms, (0, 0), 7, DI_SCREEN_CENTER_BOTTOM, HX_SHADOW);
		}
	}
	
	protected virtual void DrawFullscreenKeys()
	{
		// Draw the keys. This does not use a special draw function like SBARINFO because the specifics will be different for each mod
		// so it's easier to copy or reimplement the following piece of code instead of trying to write a complicated all-encompassing solution.
		Vector2 keypos = (-10, 2);
		int rowc = 0;
		double roww = 0;
		for(let i = CPlayer.mo.Inv; i != null; i = i.Inv)
		{
			if (i is "Key" && i.Icon.IsValid())
			{
				DrawTexture(i.Icon, keypos, DI_SCREEN_RIGHT_TOP|DI_ITEM_LEFT_TOP);
				Vector2 size = TexMan.GetScaledSize(i.Icon);
				keypos.Y += size.Y + 2;
				roww = max(roww, size.X);
				if (++rowc == 3)
				{
					keypos.Y = 2;
					keypos.X -= roww + 2;
					roww = 0;
					rowc = 0;
				}
			}
		}
	}
}
