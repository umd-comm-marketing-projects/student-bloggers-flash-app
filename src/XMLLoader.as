package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.Security;
	
	/**
	 * ...
	 * @author Kyle Smith
	 */
	public class XMLLoader extends Sprite {
		
		public var loader:URLLoader;
		public var req:URLRequest;
		public var xml:XML;
		public var url:String;
		
		public function XMLLoader(url:String):void {
			this.url = url;
			
			Security.allowDomain('*');
			Security.allowInsecureDomain('*');
			
			this.req = new URLRequest(this.url);
			this.req.method = URLRequestMethod.POST;
			this.req.data = true;
			
			/**
			 * 	Load the XML file
			 */
			this.loader = new URLLoader();
			this.loader.addEventListener(Event.COMPLETE, onComplete);
			this.loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			this.loader.load(this.req);
		}
		
		public function getXML():XML {
			return this.xml;
		}
		
		private function onComplete(event:Event):void {
			this.removeEventListeners();
			
			/**
			 * 	Capture the loaded XML and store it
			 */
			try {
				this.xml = XML(event.target.data);
				// trace(xml);
			} catch (e:Error) {
				// The XML was malformed, probably due to a faulty connection
				onLoadError(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			}
			
			/**
			 * 	Here we re-dispatch the complete event.
			 * 	
			 * 	This is an easy way to signal the Main timeline that
			 * 	it's time to progress with the file loading
			 */
			dispatchEvent(event);
		}
		
		private function onLoadError(event:IOErrorEvent):void {
			this.removeEventListeners();
			
			/**
			 * 	Re-Dispatch the IOErrorEvent
			 */
			dispatchEvent(event);
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void {
			this.removeEventListeners();
			
			/**
			 * 	Re-Dispatch the SecurityErrorEvent
			 */
			dispatchEvent(event);
		}
		
		private function removeEventListeners():void {
			this.loader.removeEventListener(Event.COMPLETE, onComplete);
			this.loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			this.loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}
		
	}	
}