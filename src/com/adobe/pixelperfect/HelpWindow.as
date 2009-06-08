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
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.NativeWindowBoundsEvent;
	import flash.html.HTMLLoader;
	import flash.net.URLRequest;
	
	public class HelpWindow extends NativeWindow
	{
		private var html:HTMLLoader;
		private const WIDTH:uint = 300;
		private const HEIGHT:uint = 325;
		
		public function HelpWindow()
		{
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.type = NativeWindowType.UTILITY;
			winArgs.systemChrome = NativeWindowSystemChrome.STANDARD;
			winArgs.transparent = false;
			winArgs.resizable = false;
			super(winArgs);
			
			this.width = WIDTH;
			this.height = HEIGHT;
			
			this.addEventListener(NativeWindowBoundsEvent.RESIZING, onResize);
			
			this.html = new HTMLLoader();
			this.html.x = 0;
			this.html.y = 0;
			this.html.width = WIDTH;
			this.html.height = HEIGHT;
			this.html.navigateInSystemBrowser = true;
			this.html.load(new URLRequest("help.html"));
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.addChild(this.html);
		}
		
		private function onResize(e:NativeWindowBoundsEvent):void
		{
			this.html.width = this.width;
			this.html.height = this.height;
		}
	}
}