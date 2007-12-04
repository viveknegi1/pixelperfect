package
{
	import com.adobe.pixelperfect.Ruler;
	import flash.display.Sprite;
	import flash.desktop.NativeApplication;
	import flash.events.InvokeEvent;
	
	import flash.ui.*;
	
	public class PixelPerfect
		extends Sprite
	{
		public function PixelPerfect()
		{
			NativeApplication.nativeApplication.autoExit = true;
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
		}
		
		//Create a new Ruler window, then close this window
		private function onInvoke(e:InvokeEvent):void
		{
			new Ruler();
			stage.nativeWindow.close();  // Get rid of this window so the app will close when the last ruler is closed.
		}
	}
}