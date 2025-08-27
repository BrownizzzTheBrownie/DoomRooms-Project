class NewInvHandler : DRP_ZF_Handler
{

	NewInv menu;
	
	override void buttonClickCommand(DRP_ZF_Button caller, Name command)
	{
	
		//Console.printf("Button %p sent event \"%s\"", caller, command); //Debug
		if (command == 'obj1')
		{
		
			let player = players[consoleplayer].mo;
			if (player != null)
			{
			
				EventHandler.SendNetworkEvent("use:Almond_Water", 1);
			
			}
		
		}
	
	}

}

class NewInvEvent : EventHandler
{

	override void NetworkProcess(ConsoleEvent e)
	{
	
		if (e.name.IndexOf("use") >= 0)
		{
		
			let ppawn = players[e.Player].mo;
			Array<string> command;
			e.Name.Split(command, ":");
			
			if (command.Size() == 2)
			{
			
				class<Inventory> cls = command[1];
				
				if (ppawn.FindInventory(cls))
				{
				
					let item = ppawn.FindInventory(cls);
					ppawn.UseInventory(item);
				
				}
			
			}
		
		}
	
	}

}

class NewInv : DRP_ZF_GenericMenu
{

	override void Init(Menu parent)
	{
	
		Super.init(parent);
		let baseRes = (1920, 1080);
		setBaseResolution(baseRes);
		
		let normal = DRP_ZF_BoxTextures.createTexturePixels(
		
			"graphics/CommonBackgroundNormal.png",
			(7, 7),
			(14, 14),
			true,
			true
		
		);
		
		let hover = DRP_ZF_BoxTextures.createTexturePixels(
		
			"graphics/CommonBackgroundHover.png",
			(7, 7),
			(14, 14),
			true,
			true
		
		);
		
		let click = DRP_ZF_BoxTextures.createTexturePixels(
		
			"graphics/CommonBackgroundClick.png",
			(7, 7),
			(14, 14),
			true,
			true
		
		);
		
		let cmdHandler = new("NewInvHandler");
		
		cmdHandler.menu = self;
		
		if (players[consoleplayer].mo.FindInventory("Almond_Water"))
		{
		
			let button = DRP_ZF_Button.create(
			
				(100, 200),
				(200, 50),
				text: "Almond Water",
				cmdHandler: cmdHandler,
				command: "obj1",
				inactive: normal,
				hover: hover,
				click: click,
				textScale: 2.0
			
			);
			button.pack(mainFrame);
			
			let image = DRP_ZF_Image.create(
			
				(80, 180),
				(100, 100),
				image: "Sprites/Items/OBJ1B0.png",
				alignment: 2 << 4,
				(2, 2)
			
			);
			image.pack(mainFrame);
			
			
		
		}
	
	}

}