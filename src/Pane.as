package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import com.greensock.*;
	import com.greensock.easing.Expo;
	
	/**
	 * 	NO MORE BLUR FILTER FOR PANES
	 * 
	import com.greensock.plugins.*;
	TweenPlugin.activate([BlurFilterPlugin]);
	**/
	
	public class Pane extends Sprite 
	{
		public var index:Number;
		public var title:String;
		public var is_active:Boolean;
		public var startX:Number;
		public var endX:Number;
		
		private var container:Sprite;
		private var containHeight:Number;
		private var containWidth:Number;
		private var txfo:TextFormat;
		private var txfi:TextField;
		private var textColor:uint = 0xFFFFFF;
		private var overColor:uint;
		private var outColor:uint;
		
		// Embed the Highway Font
		[Embed(source='highway.TTF' ,fontName = 'Highway' ,mimeType = 'application/x-font')]
		private var Highway:Class;
		
		public function Pane(index:Number, startX:Number, endX:Number, total:Number, startCol:uint, endCol:uint, overCol:uint, name:String, width:Number, height:Number, fontSize:Number):void {
			this.index = index;
			this.title = name.toUpperCase();
			this.startX = startX;
			this.endX = endX;
			this.overColor = overCol;
			this.containHeight = height;
			this.containWidth = width;
			
			// this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMove);
			
			container = new Sprite();
			addChild(container);
			
			var perc:Number = ((index + 1) / total);
			this.outColor =  getBetweenColourByPercent(perc, startCol, endCol);
			container.graphics.beginFill(outColor);
			container.graphics.drawRect(0,0, containHeight, containWidth);
			container.graphics.endFill();
			
			txfo = new TextFormat();
				txfo.font = 'Highway';
				txfo.size = fontSize.toString();
				txfo.color = textColor;
				txfo.align = TextFormatAlign.JUSTIFY;
			
			txfi = new TextField();
				txfi.defaultTextFormat = txfo;
				txfi.filters = [new DropShadowFilter(3, 45, 0, .4, 7, 7, 1, 2, false) /** , new BlurFilter() **/];
				txfi.embedFonts = true;
				txfi.selectable = false;
				txfi.text = this.title;
				txfi.width = height;
				txfi.height = txfi.textHeight;
				txfi.alpha = .6;
			
			container.addChild(txfi);
				txfi.x = 5;
				txfi.y = (container.height * .5) - (txfi.height * .5);
			container.x = containWidth;
			container.rotation = 90;
			container.buttonMode = true;
			container.mouseChildren = false;
			
			this.is_active = false;
			this.onOut(null);
		}
		
		public function setActive(yn:Boolean):void {
			if (yn == true) {
				this.is_active = true;
				// this.setBlurOff();
				this.fadeIn();
			} else {
				this.is_active = false;
				// this.setBlurOn();
				this.fadeOut();
			}
		}
		
		public function showPointer():void {
			container.buttonMode = true;
			// this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		}
		
		public function hidePointer():void {
			container.buttonMode = false;
			// this.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		}
		
		/**
		private function onOver(event:MouseEvent):void {
			// this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			// this.setBlurOff();
			// this.fadeIn();
		}
		**/
		
		private function onMove(event:MouseEvent):void {
			// This is 'safer' than onOver
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			if(txfi.alpha != 1) {
				this.fadeIn();
			}
		}
		
		private function onOut(event:MouseEvent):void {
			// this.setBlurOn();
			this.fadeOut();
		}
		
		public function fadeIn():void {
			TweenLite.to(this.txfi, .5, { alpha:1 , ease: Expo.easeOut, onComplete:(function():void {
					// On complete...
				}) } );
			container.graphics.beginFill(overColor);
			container.graphics.drawRect(0,0, containHeight, containWidth);
			container.graphics.endFill();
		}
		
		public function fadeOut():void {
			if (!this.is_active) {
				TweenLite.to(this.txfi, .5, { alpha:.6 , ease: Expo.easeOut, onComplete:(function():void {
					// On complete...
				}) } );
				container.graphics.beginFill(outColor);
				container.graphics.drawRect(0,0, containHeight, containWidth);
				container.graphics.endFill();
			}
		}
		
		public function setBlurOn():void {
			if(!this.is_active) {
				TweenLite.to(this.txfi, .5, { blurFilter: { blurX:7, blurY:7 }, ease: Expo.easeOut} );
			}
		}
		
		public function setBlurOff():void {
			TweenLite.to(this.txfi, .2, { blurFilter: { blurX:0, blurY:0 }, ease: Expo.easeOut} );
		}
		
		private function getBetweenColourByPercent(value:Number = 0.5 /* 0-1 */, highColor:uint = 0xFFFFFF, lowColor:uint = 0x000000):uint {
			var r:uint = highColor >> 16;
			var g:uint = highColor >> 8 & 0xFF;
			var b:uint = highColor & 0xFF;

			r += ((lowColor >> 16) - r) * value;
			g += ((lowColor >> 8 & 0xFF) - g) * value;
			b += ((lowColor & 0xFF) - b) * value;

			return (r << 16 | g << 8 | b);
		}
	}
}