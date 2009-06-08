/*
    Adobe Systems Incorporated(r) Source Code License Agreement
    Copyright(c) 2005 Adobe Systems Incorporated. All rights reserved.
    
    Please read this Source Code License Agreement carefully before using
    the source code.
    
    Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive, 
    no-charge, royalty-free, irrevocable copyright license, to reproduce,
    prepare derivative works of, publicly display, publicly perform, and
    distribute this source code and such derivative works in source or 
    object code form without any attribution requirements.  
    
    The name "Adobe Systems Incorporated" must not be used to endorse or promote products
    derived from the source code without prior written permission.
    
    You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
    against any loss, damage, claims or lawsuits, including attorney's 
    fees that arise or result from your use or distribution of the source 
    code.
    
    THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT 
    ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
    BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  ALSO, THERE IS NO WARRANTY OF 
    NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL ADOBE 
    OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
    OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
    OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.adobe.pixelperfect
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Tooltip extends NativeWindow
	{
		private var textField:TextField;
		private var canvas:Sprite;
		private const WIDTH:uint = 100;
		private const HEIGHT:uint = 30;
		
		public function Tooltip()
		{
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.type = NativeWindowType.LIGHTWEIGHT;
			winArgs.systemChrome = NativeWindowSystemChrome.NONE;
			winArgs.transparent = true;
			super(winArgs);
			var visibleBounds:Rectangle = Screen.mainScreen.visibleBounds;
			var myY:uint = visibleBounds.y + 2;
			var myX:uint = visibleBounds.x + 2;
			
			var tooltips:Array = TooltipRegistry.getInstance().getAll();
			for each (var tooltip:Tooltip in tooltips)
			{
				if (tooltip.y == myY)
				{
					myY += (HEIGHT + 2);
				}
			}
			this.x = myX;
			this.y = myY;
			this.width = WIDTH;
			this.height = HEIGHT;
			this.alwaysInFront = true;
			this.draw();
		}
		
		private function draw():void
		{
			this.canvas = new Sprite();
			this.canvas.x = 0;
			this.canvas.y = 0;
			this.canvas.graphics.beginFill(0x000000, .75);
			this.canvas.graphics.drawRoundRect(0, 0, WIDTH, HEIGHT, 10, 10);
			this.canvas.graphics.endFill();
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.addChild(this.canvas);

			var format:TextFormat = new TextFormat("Helvetica", 15, 0xffffff, true);

			this.textField = new TextField();
			this.textField.defaultTextFormat = format;
			this.alignText();
			this.canvas.addChild(this.textField);
			TooltipRegistry.getInstance().add(this);
			this.visible = true;
		}
		
		private function alignText():void
		{
			this.textField.x = ((WIDTH / 2) - (this.textField.textWidth / 2) - 2);
			this.textField.y = ((HEIGHT / 2) - (this.textField.textHeight / 2) - 2);
		}
		
		public function set text(text:String):void
		{
			this.textField.text = text;
			this.alignText();
		}
		
		public override function close():void
		{
			TooltipRegistry.getInstance().remove(this);
			super.close();
		}
	}
}