/* Copyright 2017-2019 Nash Muhandes
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

//Adds tooltips to widgets

class OptionMenuItemFPPOption : OptionMenuItemOption
{
	String mTooltip;

	OptionMenuItemFPPOption Init(String label, String tooltip, Name command, Name values, CVar graycheck = null, int center = 0)
	{
		mTooltip = tooltip;
		Super.Init(label, command, values, graycheck, center);
		return self;
	}
}

class OptionMenuItemFPPSlider : OptionMenuItemSlider
{
	String mTooltip;

	OptionMenuItemFPPSlider Init(String label, String tooltip, Name command, double min, double max, double step, int showval = 1)
	{
		mTooltip = tooltip;
		Super.Init(label, command, min, max, step, showval);
		return self;
	}
}

class NashTTFPPOptions : OptionMenu
{
	override void Drawer ()
	{
		Super.Drawer();

		String tt;

		if (mDesc.mSelectedItem > 0)
		{
			if (mDesc.mItems[mDesc.mSelectedItem] is "OptionMenuItemFPPOption")
			{
				tt = StringTable.Localize(OptionMenuItemFPPOption(mDesc.mItems[mDesc.mSelectedItem]).mTooltip);
			}

			if (mDesc.mItems[mDesc.mSelectedItem] is "OptionMenuItemFPPSlider")
			{
				tt = StringTable.Localize(OptionMenuItemFPPSlider(mDesc.mItems[mDesc.mSelectedItem]).mTooltip);
			}
		}

		if (tt.Length() > 0)
		{
			Screen.DrawText (OptionFont(), OptionMenuSettings.mFontColorValue,
				(Screen.GetWidth() - OptionFont().StringWidth (tt) * CleanXfac_1) / 2,
				BigFont.GetHeight() * CleanYfac_1 * 2.5,
				tt,
				DTA_CleanNoMove_1, true);
		}
	}
}
