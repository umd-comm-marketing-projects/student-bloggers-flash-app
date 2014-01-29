package 
{
	import flash.filters.ColorMatrixFilter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import com.greensock.*;
	import com.greensock.easing.Expo;
	
	public class Preloader extends Sprite 
	{
		private var emblem:Sprite;
		private var emblemMask:Sprite;
		private var logo:Sprite;
		private var tfo:TextFormat;
		private var tfi:TextField;
		
		// Embed the logo
		[Embed(source = 'logo2.png')]
		private var preloaderLogo:Class;
		
		// Embed the emblem
		[Embed(source = 'emblem.png')]
		private var emblemLogo:Class;
		
		// Embed the Highway Font
		[Embed(source='highway.TTF' ,fontName = 'Highway' ,mimeType = 'application/x-font')]
		private var Highway:Class;
		
		public function Preloader(titleColor:uint, yearColor:uint):void {
			
			logo = new Sprite();
				logo.graphics.beginFill(titleColor);
				logo.graphics.drawRect(1, 1, 180, 59);
				logo.graphics.endFill();
				logo.graphics.beginFill(yearColor);
				logo.graphics.drawRect(1, 60, 180, 30);
				logo.graphics.endFill();
			logo.addChild(Bitmap(new preloaderLogo()));
			addChild(logo);
			
			emblem = new Sprite();
			emblem.addChild(Bitmap(new emblemLogo()));
			emblem.x = (logo.width * .5) - (emblem.width * .5);
			emblem.y = logo.height + 5
			emblem.alpha = 0;
			addChild(emblem);
			
			tfo = new TextFormat();
				tfo.font = 'Highway';
				tfo.size = '16';
				tfo.bold = true;
				tfo.color = titleColor;
				tfo.align = TextFormatAlign.CENTER;
			
			tfi = new TextField();
				tfi.defaultTextFormat = tfo;
				tfi.embedFonts = true;
				tfi.selectable = false;
				tfi.text = 'Loading...';
				tfi.width = logo.width;
			
			tfi.alpha = 0;
			tfi.y = logo.height + 5;
			addChild(tfi);
		}
		
		public function startLoad():void {
			TweenLite.to(tfi, .5, { alpha:1, ease:Expo.easeOut } );
		}
		
		public function updateProgress(perc:Number):void {
			tfi.text = (Math.ceil(perc * 100)).toString() + "%";
			if (perc == 1) {
				// Load is complete, fade out
				TweenLite.to(tfi, .5, { alpha:0, onComplete:(function():void { 
							tfi.visible = false;
							removeChild(tfi);
							tfi = null; } ) } );
			}
		}
		
		public function showComplete(tweenTime:Number):void {
			TweenLite.to(emblem, tweenTime*.5, { alpha:1, delay: tweenTime*.5, ease:Expo.easeOut } );
		}
		
		public function setError(str:String):void {
			tfi.visible = true;
			tfi.alpha = 1;
			tfi.text = str.toString();
		}
		
	}
}