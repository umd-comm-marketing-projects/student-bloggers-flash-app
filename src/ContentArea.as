package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import com.greensock.*;
	
	public class  ContentArea extends Sprite {
		
		private var title:String;
		private var tagline:String;
		private var bioImage:Sprite;
		private var xmlUrl:String;
		private var bioUrl:String;
		private var blogXMLLoader:XMLLoader
		
		private var container:Sprite;
		private var titleField:TextField;
		private var taglineField:TextField;
		private var regBlogButton:Sprite;
		private var blogButton:Sprite;
		private var postTitle:TextField;
		private var postDesc:TextField;
		private var innerContain:Sprite;
		private var titleDivider:Sprite;
		
		// Embed the Highway Font
		[Embed(source='highway.TTF' ,fontName = 'Highway' ,mimeType = 'application/x-font')]
		private var Highway:Class;
		
		// Embed the blog button
		[Embed(source = 'blogButton3.png')]
		private var blogButtonClass:Class;
		
		// Embed the emergency blog button
		[Embed(source = 'blogButton2.png')]
		private var EmergencyblogButtonClass:Class;
		
		public function ContentArea(width:Number, height:Number, tColor:uint, pColor:uint):void {
			
			container = new Sprite();
				container.graphics.beginFill(0xFFFFFF);
				container.graphics.drawRect(0, 0, width, height);
				container.graphics.endFill();
			addChild(container);
			
			titleField = new TextField();
				titleField.defaultTextFormat = new TextFormat('Highway','24', tColor,null,null,null,null,null, TextFormatAlign.LEFT, 10);
				titleField.embedFonts = true;
				titleField.selectable = false;
				titleField.text = "Name goes here";
				titleField.width = width;
			titleField.y = 5;
			container.addChild(titleField);
			
			titleDivider = new Sprite();
				titleDivider.graphics.beginFill(tColor, .7);
				titleDivider.graphics.drawRect(0, 0, width - 20, 2);
				titleDivider.graphics.endFill();
				titleDivider.filters = [new DropShadowFilter(1,45,0x222222,.4)];
			titleDivider.x = 10;
			titleDivider.y = 32;
			container.addChild(titleDivider);
			
			taglineField = new TextField();
				taglineField.defaultTextFormat = new TextFormat('Highway','16', tColor,null,null,null,null,null, TextFormatAlign.RIGHT,null, 10);
				taglineField.embedFonts = true;
				taglineField.selectable = false;
				taglineField.text = "Tagline goes here";
				taglineField.width = width;
			taglineField.y = 35;
			container.addChild(taglineField);
			
			innerContain = new Sprite();
			innerContain.y = 70;
			innerContain.buttonMode = true;
			innerContain.mouseChildren = false;
			innerContain.addEventListener(MouseEvent.CLICK, goToBlog);
			container.addChild(innerContain);
			
			postTitle = new TextField();
				postTitle.defaultTextFormat = new TextFormat('Highway','14', 0x222222,true,null,null,null,null, TextFormatAlign.LEFT,10,10);
				postTitle.embedFonts = true;
				postTitle.selectable = false;
				postTitle.text = "Recent post title goes here";
				postTitle.width = width - 30;
				
			innerContain.addChild(postTitle);
			
			postDesc = new TextField();
				postDesc.defaultTextFormat = new TextFormat('Highway','12', 0x444444,false,null,null,null,null, TextFormatAlign.JUSTIFY, 10, 10);
				postDesc.embedFonts = true;
				postDesc.selectable = false;
				postDesc.multiline = true;
				postDesc.wordWrap = true;
				postDesc.text = "Recent post description goes here";
				postDesc.width = width;
				
			// postDesc.y = 20;
			postDesc.y = 20;
			innerContain.addChild(postDesc);
			
			regBlogButton = new Sprite();
			regBlogButton.addChild(Bitmap(new blogButtonClass()));
			regBlogButton.buttonMode = true;
			regBlogButton.x = width - regBlogButton.width - 5;
			regBlogButton.y = 5;
			regBlogButton.addEventListener(MouseEvent.CLICK, goToBlog);
			container.addChild(regBlogButton);
			
			blogButton = new Sprite();
			blogButton.addChild(Bitmap(new EmergencyblogButtonClass()));
			blogButton.x = (container.width * .5) - (blogButton.width * .5);
			blogButton.y = 70;
			blogButton.buttonMode = true;
			blogButton.visible = false;
			blogButton.alpha = 0;
			blogButton.addEventListener(MouseEvent.CLICK, goToBlog);
			// container.addChild(blogButton);
			container.addChild(blogButton);
			
			bioImage = new Sprite();
			container.addChild(bioImage);
		}
		
		private function goToBlog(e:MouseEvent):void {
			navigateToURL(new URLRequest(this.bioUrl))
		}
		
		public function setContent(bio:Object):void {
			
			container.removeChild(bioImage);
			bioImage = new Sprite();
			bioImage.addChild(bio.image);
			
			this.title = bio.name;
			this.tagline = bio.tagline;
			this.xmlUrl = bio.feedurl;
			this.bioUrl = bio.blogurl;
			
			trace(bio.postTitle + " - " + bio.postDesc);
			
			if (bio.showFeed) {
				this.regBlogButton.visible = true;
				this.innerContain.alpha = .4;
				
				this.innerContain.addEventListener(MouseEvent.MOUSE_OVER, (function(e:MouseEvent = null):void {
					TweenLite.to(innerContain, .5, { alpha:.7 } );
				}));
				
				this.innerContain.addEventListener(MouseEvent.MOUSE_OUT, (function(e:MouseEvent = null):void {
					TweenLite.to(innerContain, .3, { alpha:.4 } );
				}));
				
				this.blogButton.visible = false;
				this.blogButton.alpha = 0;
				this.postTitle.visible = true;
				this.postDesc.visible = true;
				this.postTitle.text = bio.postTitle;
				this.postDesc.text = bio.postDesc;
				
				if (this.postDesc.length > 200) {
					var newDesc:String = this.postDesc.text.slice(0, 200);
					newDesc = newDesc.concat('...');
					this.postDesc.text = newDesc;
				}
				
			} else {
				// Handle bios with no feed here
				this.regBlogButton.visible = false;
				this.innerContain.alpha = 1;
				this.postTitle.visible = false;
				this.postDesc.visible = false;
				this.blogButton.visible = true;
				this.blogButton.alpha = 1;
			}
			
			titleField.text = this.title;
			taglineField.text = this.tagline;
			
			bioImage.x = 	(container.width*.5) - (bioImage.width*.5);
			bioImage.y = 	(container.height) - (bioImage.height);
			container.addChild(bioImage);
		}
		
	}
}