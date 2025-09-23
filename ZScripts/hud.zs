class DRP_HUD : BaseStatusBar
{

	HudFont csmallfont;

	override void Init()
	{
	
		Super.Init();
		
		csmallfont = HUDFont.create("bigfont");
	
	}
	
	override void Draw(int state, double TicFrac)
	{
	
		Super.Draw (state, TicFrac);
		
		if (state == HUD_StatusBar)
		{
		
			BeginHUD();
			DrawMainBar (TicFrac);
		
		}
	
	}
	
	protected void DrawMainBar(double TicFrac)
	{
	
		DrawImage("MEDIA0", (30, 212));
		DrawString(csmallfont, FormatNumber(CPlayer.health, 3), (40, 200));
	
	}

}