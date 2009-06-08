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
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowResize;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
    /**
    * The Ruler class extends NativeWindow to add the ruler window
    * features. Because Ruler does not extend Sprite, it cannot be used
    * as the main class for an application.
    */
	public class Ruler
		extends NativeWindow
	{

		private static var GRIPPER_SIZE:uint = 20;
		private var xTicks:Array;
		private var yTicks:Array;
		private var sprite:Sprite;
		private var dimensions:TextField;

		private var cm:NativeMenu;
		private var newRulerMenuItem:NativeMenuItem;
		private var fullScreenMenuItem:NativeMenuItem;
		private var presetsMenuItem:NativeMenuItem;
		private var preset800x600MenuItem:NativeMenuItem;
		private var preset1024x768MenuItem:NativeMenuItem;
		private var preset1280x800MenuItem:NativeMenuItem;
		private var onTopMenuItem:NativeMenuItem;
		private var copyMenuItem:NativeMenuItem;
		private var copyWidthMenuItem:NativeMenuItem;
		private var copyHeightMenuItem:NativeMenuItem;
		private var closeMenuItem:NativeMenuItem;
		private var exitMenuItem:NativeMenuItem;
		private var hrMenuItem:NativeMenuItem;
		private var helpMenuItem:NativeMenuItem;
		
		private var tooltip:Tooltip;
		
		public function Ruler(width:uint = 300, height:uint = 300, x:int = 50, y:int = 50, alpha:Number = .4)
		{
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.type = NativeWindowType.UTILITY;
			winArgs.systemChrome = NativeWindowSystemChrome.NONE;
			winArgs.transparent = true;
			super(winArgs);
			
			this.title = "PixelWindow";
			this.activate();

			// Configure the window
			this.alwaysInFront = false;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			minSize = new Point(15,15);

			// Create the drawing sprite
			sprite = new Sprite();
			sprite.alpha = alpha;
			sprite.useHandCursor = true;
			sprite.buttonMode = true;

			// Configure the context menu
			this.cm = new NativeMenu();
			
			this.newRulerMenuItem = new NativeMenuItem("New");
			this.fullScreenMenuItem = new NativeMenuItem("Full Screen");
			this.presetsMenuItem = new NativeMenuItem("Presets");
			this.preset800x600MenuItem = new NativeMenuItem("800x600");
			this.preset1024x768MenuItem = new NativeMenuItem("1024x768");
			this.preset1280x800MenuItem = new NativeMenuItem("1280x800");
			this.onTopMenuItem = new NativeMenuItem("Keep On Top");
			this.copyMenuItem = new NativeMenuItem("Copy");
			this.copyWidthMenuItem = new NativeMenuItem("Width");
			this.copyHeightMenuItem = new NativeMenuItem("Height");
			this.exitMenuItem = new NativeMenuItem("Exit");
			this.closeMenuItem = new NativeMenuItem("Close Window");
			this.hrMenuItem = new NativeMenuItem(null, true);
			this.helpMenuItem = new NativeMenuItem("Help");

			this.newRulerMenuItem.addEventListener(Event.SELECT, onNewRulerMenuItem);
			this.fullScreenMenuItem.addEventListener(Event.SELECT, onFullScreenMenuItem);
			this.preset800x600MenuItem.addEventListener(Event.SELECT, resizeTo);
			this.preset1024x768MenuItem.addEventListener(Event.SELECT, resizeTo);
			this.preset1280x800MenuItem.addEventListener(Event.SELECT, resizeTo);
			this.copyWidthMenuItem.addEventListener(Event.SELECT, onCopy);
			this.copyHeightMenuItem.addEventListener(Event.SELECT, onCopy);
			this.onTopMenuItem.addEventListener(Event.SELECT, toggleAlwaysInFront);
			this.closeMenuItem.addEventListener(Event.SELECT, onCloseMenuItem);
			this.exitMenuItem.addEventListener(Event.SELECT, onExitMenuItem);
			this.helpMenuItem.addEventListener(Event.SELECT, onHelpMenuItem);

			this.cm.addItem(this.newRulerMenuItem);
			this.cm.addItem(this.fullScreenMenuItem);
			this.presetsMenuItem.submenu = new NativeMenu();
			this.presetsMenuItem.submenu.addItem(this.preset800x600MenuItem);
			this.presetsMenuItem.submenu.addItem(this.preset1024x768MenuItem);
			this.presetsMenuItem.submenu.addItem(this.preset1280x800MenuItem);
			this.cm.addItem(this.presetsMenuItem);
			this.cm.addItem(this.onTopMenuItem);
			this.copyMenuItem.submenu = new NativeMenu();
			this.copyMenuItem.submenu.addItem(this.copyWidthMenuItem);
			this.copyMenuItem.submenu.addItem(this.copyHeightMenuItem);
			this.cm.addItem(this.copyMenuItem);
			this.cm.addItem(this.closeMenuItem);
			this.cm.addItem(this.exitMenuItem);
			this.cm.addItem(this.hrMenuItem);
			this.cm.addItem(this.helpMenuItem);

			// Configure the stage
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addChild(sprite);

			// Cache text fields for performance
			var tickFormat:TextFormat;
			tickFormat = new TextFormat();
			tickFormat.font = "Verdana";
			tickFormat.color = 0x000000;
			tickFormat.size = 10;
			xTicks = new Array();
			yTicks = new Array();
			var xNum:TextField;
			var yNum:TextField;
			for (var i:uint = 0; i < 40; ++i)
			{
				xNum = new TextField();
				xNum.defaultTextFormat = tickFormat;
				xNum.selectable = false;
				xNum.mouseEnabled = false;
				xNum.height = 15;
				xNum.text = String(i * 50);
				xTicks.push(xNum);
				yNum = new TextField();
				yNum.defaultTextFormat = tickFormat;
				yNum.selectable = false;
				yNum.mouseEnabled = false;
				yNum.height = 15;
				yNum.width = 10;
				yNum.text = String(i * 50);
				yTicks.push(yNum);
			}

			// Set up event listeners
			this.addEventListener(Event.RESIZE, onWindowResize);
			this.addEventListener(Event.CLOSING, onClosing);
			sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			sprite.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
			sprite.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			sprite.doubleClickEnabled = true;
			sprite.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			
			// Set up the dimensions text field
			var dimFormat:TextFormat;
			dimFormat = new TextFormat();
			dimFormat.font = "Verdana";
			dimFormat.color = 0x000000;
			dimFormat.size = 12;
			dimFormat.bold = true;
			dimFormat.align = "center";
			dimensions = new TextField();
			dimensions.width = 100;
			dimensions.height = 20;
			dimensions.border = false;
			dimensions.selectable = false;
			dimensions.mouseEnabled = false;
			dimensions.defaultTextFormat = dimFormat;
			this.stage.addChild(dimensions);
			updateDimensions(width, height);
			drawTicks(width, height);
			visible = true;
		}

		private function toggleAlwaysInFront(e:Event):void
		{
			this.alwaysInFront = !this.alwaysInFront;
			this.onTopMenuItem.checked = this.alwaysInFront;
		}
		
		// Handle the preset commands in the context menu
		private function resizeTo(e:Event):void
		{
			switch (e.target)
			{
				case preset800x600MenuItem:
					this.bounds = new Rectangle(this.x, this.y, 800, 600);
					break;
				case preset1024x768MenuItem:
					this.bounds = new Rectangle(this.x, this.y, 1024, 768);
					break;
				case preset1280x800MenuItem:
					this.bounds = new Rectangle(this.x, this.y, 1280, 800);
					break;
			}
		}

		// Handle copying to the clipboard
		private function onCopy(e:Event):void
		{
			var toCopy:String;
			var dimString:String = this.dimensions.text;
			switch (e.target)
			{
				case copyWidthMenuItem:
					toCopy = dimString.substring(0, dimString.indexOf("x") - 1);
					break;
				case copyHeightMenuItem:
					toCopy = dimString.substring(dimString.indexOf("x") + 2, dimString.length);
					break;
			}
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, toCopy);
		}
		
		// Handle the new ruler command in the context menu
		private function onNewRulerMenuItem(e:Event):void
		{
			createNewRuler();
		}
		
		// Handle the fullscreen mode toggle command in the context menu
		private function onFullScreenMenuItem(e:Event):void
		{
			stage.displayState = (stage.displayState == StageDisplayState.NORMAL) ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
		}

        // Handle the fullscreen event
		private function onFullScreen(e:FullScreenEvent):void
		{
			fullScreenMenuItem.label = (e.fullScreen) ? "Full Screen Off" : "Full Screen";
		}
		
		// Handle the close window command in the context menu
		private function onCloseMenuItem(e:Event):void
		{
			this.onClosing(e);
			 close();	
		}
		
		// Handling the closing event
		private function onClosing(e:Event):void
		{
			this.closeTooltip();
		}
		
		private function closeTooltip():void
		{
			if (this.tooltip != null)
			{
				this.tooltip.close();
				this.tooltip = null;
			}
		}
		
		// Handle the exit command in the context menu
		private function onExitMenuItem(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}

		// Handle the help command in the context menu
		private function onHelpMenuItem(e:Event):void
		{
			new HelpWindow().activate();
		}
		
		// Update the label for the window dimensions
		private function updateDimensions(_width:int, _height:int):void
		{
			if (_width < 70 || _height < 30)
			{
				if (this.tooltip == null)
				{
					this.dimensions.visible = false;
					this.tooltip = new Tooltip();
				}
			}
			else
			{
				this.dimensions.visible = true;
				if (this.tooltip != null)
				{
					this.closeTooltip();
				}
			}
			dimensions.x = (_width / 2) - (dimensions.width / 2);
			dimensions.y = (_height / 2) - (dimensions.height / 2);
			var dimString:String = _width + " x " + _height;
			dimensions.text = dimString;
			if (this.tooltip != null)
			{
				this.tooltip.text = dimString;
			}
		}
		
		// Handle the context menu
		private function onRightClick(e:MouseEvent):void
		{
			this.cm.display(this.stage, e.stageX, e.stageY);
		}
		
		// Change the window opacity when the mouse wheel is rotated
		private function onMouseWheel(e:MouseEvent):void
		{
			var delta:int = (e.delta < 0) ? -1 : 1;
			if (sprite.alpha >= .1 || e.delta > 0)
				sprite.alpha += (delta / 50);
		}
		
		// Handle window mouse down events
		private function onMouseDown(e:Event):void
		{
			if (stage.mouseX >= 0 && stage.mouseX <= GRIPPER_SIZE && stage.mouseY >= 0 && stage.mouseY <= GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.TOP_LEFT);
			}
			else if (stage.mouseX <= this.width && stage.mouseX >= this.width - GRIPPER_SIZE && stage.mouseY >= 0 && stage.mouseY <= GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.TOP_RIGHT);					
			}
			else if (stage.mouseX >= 0 && stage.mouseX <= GRIPPER_SIZE && stage.mouseY <= this.height && stage.mouseY >= this.height - GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.BOTTOM_LEFT);					
			}
			else if (stage.mouseX <= this.width && stage.mouseX >= this.width - GRIPPER_SIZE && stage.mouseY <= this.height && stage.mouseY >= this.height - GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.BOTTOM_RIGHT);					
			}
			else if (stage.mouseX >= 0 && stage.mouseX <= GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.LEFT);					
			}
			else if (stage.mouseX >= this.width - GRIPPER_SIZE && stage.mouseX <= this.width)
			{
				startResize(NativeWindowResize.RIGHT);					
			}
			else if (stage.mouseY >= 0 && stage.mouseY <= GRIPPER_SIZE)
			{
				startResize(NativeWindowResize.TOP);					
			}
			else if (stage.mouseY >= this.height - GRIPPER_SIZE && stage.mouseY <= this.height)
			{
				startResize(NativeWindowResize.BOTTOM);					
			}
			else
			{
				startMove();
			}
		}
		
		// Redraw the window when a resize event is dispatched
		private function onWindowResize(e:NativeWindowBoundsEvent):void
		{
			drawTicks(e.afterBounds.width, e.afterBounds.height);
			updateDimensions(e.afterBounds.width, e.afterBounds.height);
		}
		
		// Draw the ruler tick marks
		private function drawTicks(_width:int, _height:int):void
		{
			sprite.graphics.clear();
			sprite.graphics.beginFill(0x8597f3);
			sprite.graphics.drawRect(0, 0, _width, _height);
			sprite.graphics.endFill();
			
			var len:uint = 0;
			var num:TextField;
			var i:uint;

			for (i = 10; i < _width; i += 5)
			{
				if ((i % 50) == 0)
				{
					len = 15;
					num = TextField(xTicks[i/50]);
					if (sprite.contains(num))
					{
						this.stage.removeChild(num);
					}
					this.stage.addChild(num);
					num.width = 100;
					num.x = (i < 100) ? i - 9 : i - 12;
					num.y = 15;
				}
				else
				{
					len = 10;
				}
				
				// left black
				sprite.graphics.beginFill(0x000000);
				sprite.graphics.drawRect(i, 0, 1, len);

				// left white
				sprite.graphics.beginFill(0xffffff);
				sprite.graphics.drawRect(i+1, 1, 1, len);

				// black bottom
				if (i < _width - 5)
				{
					sprite.graphics.beginFill(0x000000);
					sprite.graphics.drawRect(i, _height - len, 1, len);
				}
			}

			len = 0;
			for (i = 10; i < _height; i += 5)
			{
				if ((i % 50) == 0)
				{
					len = 15;
					num = TextField(yTicks[i/50]);
					if (sprite.contains(num))
					{
						this.stage.removeChild(num);
					}
					this.stage.addChild(num);
					num.width = 100;
					num.x = 17,
					num.y = i - 8;
				}
				else
				{
					len = 10;
				}
				
				// top black
				sprite.graphics.beginFill(0x000000);
				sprite.graphics.drawRect(0, i, len, 1);
				
				// top white
				sprite.graphics.beginFill(0xffffff);
				sprite.graphics.drawRect(1, i+1, len, 1);

				// black right
				if (i < _height - 5)
				{
					sprite.graphics.beginFill(0x000000);
					sprite.graphics.drawRect(_width - len, i, len, 1);
				}
			}
			sprite.graphics.endFill();
		}
		
		// Close the window on a double-click event
		private function onDoubleClick(e:Event):void
		{
			this.onClosing(e);
			close();
		}
		
		private function createNewRuler():void
		{
			var r:Ruler = new Ruler(width, height, x+20, y+20, sprite.alpha);
		}
		
		// Handle keyboard events
		private function onKeyDown(e:KeyboardEvent):void
		{
			var delta:uint = (e.shiftKey) ? 5 : 1;
			switch (e.keyCode)
			{
				case Keyboard.DOWN:
					if (e.ctrlKey)
						this.height += delta;
					else
						this.y += delta;
					break;
				case Keyboard.UP:
					if (e.ctrlKey)
						this.height -= delta;
					else
						this.y -= delta;
					break;
				case Keyboard.RIGHT:
					if (e.ctrlKey)
						this.width += delta;
					else
						this.x += delta;
					break;
				case Keyboard.LEFT:
					if (e.ctrlKey)
						this.width -= delta;
					else
						this.x -= delta;
					break;
				case 78:
					if (e.ctrlKey)
					{
						this.createNewRuler();
					}
					break;
			}					
		}
	}
}