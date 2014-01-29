package 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import com.greensock.*;
	import com.greensock.easing.Expo;
	
	/**
	 * 		UM-Dearborn Bloggers 2010-2011 Accordian App
	 * 		
	 * 		@author 	Kyle Smith
	 * 		@version 	1.0
	 * 		
	 */
	[SWF(width = 600, height = 400, framerate = 30, backgroundColor=0xFFFFFF)]
	public class Main extends Sprite 
	{
		private static const contentWidth:Number = 370;
		private static const tPaneWidth:Number = 230;
		private static const numTasksTotal:uint = 2;
		private var numTasksLoaded:uint = 0;
		
		// private static const mainXMLName:String = "fileadmin/template/emsl/images/Blogger/2010/settings.xml";
		private static const mainXMLName:String = "settings.xml";
		private var mainXMLLoader:XMLLoader;
		
		private var currentPane:Number;
		private var bios:Vector.<Object>;
		private var panes:Vector.<Pane>;
		private var content:Sprite;
		private var contentArea:ContentArea;
		private var stageContain:Sprite;
		private var stageMask:Sprite;
		private var preloader:Preloader;
		private var settings:Object;
		private var tweenSlideTime:Number = .6;
		private var tweenFadeTime:Number = .4;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Prevent the stage from being warped in size
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			Security.allowDomain('https://www.umd.umich.edu');
			Security.allowDomain('http://www.umd.umich.edu');
			Security.allowDomain('www.umd.umich.edu');
			Security.allowDomain('www.umd.typepad.com');
			Security.allowInsecureDomain('https://www.umd.umich.edu');
			Security.allowInsecureDomain('http://www.umd.umich.edu');
			Security.allowInsecureDomain('www.umd.umich.edu');
			Security.allowInsecureDomain('www.umd.typepad.com');
			Security.allowDomain('*');
			Security.allowInsecureDomain('*');
			
			// Create a custom context menu
			var cm:ContextMenu = new ContextMenu();
			var menuItems:Array = new Array (
					new ContextMenuItem("UM-Dearborn 2010-2011 Bloggers", false, false, true),
					new ContextMenuItem("Home Page" , false, true, true)
			);
			menuItems[1].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function():void {
				navigateToURL(new URLRequest("http://www.umd.umich.edu"));
			});
			cm.hideBuiltInItems();
			cm.customItems = menuItems;
			contextMenu = cm;
			
			
			stageContain = new Sprite();
			content = new Sprite();
				content.graphics.beginFill(0xFFFFFF);
				content.graphics.drawRect(0, 0, contentWidth, stage.stageHeight);
				content.graphics.endFill();
				content.x = (stage.stageWidth * .5) - (content.width * .5);
			addChild(stageContain);
			stageContain.addChild(content);
			
			/**
			 * 	First thing's first, load the settings XML file,
			 * 	nothing can happen without that.
			 */
			mainXMLLoader = new XMLLoader(mainXMLName);
			mainXMLLoader.addEventListener(Event.COMPLETE, onMainLoadComplete);
			mainXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, onMainLoadError);
			mainXMLLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onMainLoadError);
		}
		
		private function setupStage():void {
			
			// this.addEventListener(Event.ENTER_FRAME, loop);
			
			var tweenTime:Number = 1.5;
			preloader.showComplete(tweenTime);
			TweenLite.to(content, tweenTime, { x: stage.stageWidth - content.width, ease: Expo.easeOut } );
			
			// Build the panes
			panes = new Vector.<Pane>();
			settings.paneWidth = tPaneWidth / settings.numPanes;
			
			for (var i:uint = 0; i < settings.numPanes; ++i) {
				
				var startX:Number = (i * settings.paneWidth);
				var endX:Number = stage.stageWidth - ((settings.numPanes - i) * settings.paneWidth);
				
				panes.push(new Pane(i, startX, endX, settings.numPanes, settings.startColor, settings.endColor, settings.highlightColor,
											bios[i].name, settings.paneWidth,stage.stageHeight, settings.fontSize));
				panes[i].x = panes[i].startX;
				panes[i].y = stage.stageHeight * .5;
				
				panes[i].addEventListener(MouseEvent.CLICK, handlePaneChange);
				
				// handle tweening and whatnot here
				panes[i].alpha = 0;
				stageContain.addChild(panes[i]);
				if (i == (settings.numPanes - 1)) {
					TweenLite.to(panes[i], .5, { alpha:1, y:0, ease:Expo.easeOut, delay:(i*.25), onComplete:enablePaneClick} );
				} else {
					TweenLite.to(panes[i], .5, { alpha:1, y:0, ease:Expo.easeOut, delay:i * .25 } );
				}
			}
			
			// Mask the stage
			stageMask = new Sprite();
			var cornerRadius:Number = settings.roundCorners == true ? 25 : 0;
			stageMask.graphics.beginFill(0xFFFFFF);
			stageMask.graphics.drawRoundRect(0, 0, stage.stageWidth, stage.stageHeight, cornerRadius, cornerRadius);
			stageMask.graphics.endFill();
			this.stageContain.mask = stageMask;
			
			// Build the content area
			contentArea = new ContentArea(contentWidth, stage.stageHeight, settings.titleColor, settings.postColor);
			contentArea.x = (content.width * .5) - (contentArea.width * .5);
			contentArea.y = (stage.stageHeight * .5) - (contentArea.height * .5);
			contentArea.alpha = 0;
			contentArea.visible = false;
			content.addChild(contentArea);
			
			// Set the inital slide value
			currentPane = -1;
		}
		
		private function onMainLoadComplete(e:Event):void {
			// Cleanup event listeners
			mainXMLLoader.removeEventListener(Event.COMPLETE, onMainLoadComplete);
			mainXMLLoader.removeEventListener(IOErrorEvent.IO_ERROR, onMainLoadError);
			mainXMLLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onMainLoadError);
			
			// Grab the XML and pull out the panes
			var xml:XML = mainXMLLoader.getXML();
			var panesList:XMLList = xml.pane;
			
			settings = new Object();
				settings.numPanes = panesList.length();
				settings.roundCorners 	= Boolean(stringToBool(xml.@roundCorners));
				settings.fontSize 		= Number(xml.@fontSize);
				settings.startColor 	= uint(hexStringToUint(xml.@startColor));
				settings.endColor 		= uint(hexStringToUint(xml.@endColor));
				settings.highlightColor = uint(hexStringToUint(xml.@highlightColor));
				settings.titleColor 	= uint(hexStringToUint(xml.@titleColor));
				settings.yearColor 		= uint(hexStringToUint(xml.@yearColor));
				settings.postColor 		= uint(hexStringToUint(xml.@postColor));
			
			// Loop through the panes and populate the bios vector
			bios = new Vector.<Object>();
			for (var i:uint = 0; i < settings.numPanes; ++i) {
				var bio:Object = new Object();
				bio.name = panesList[i].name;
				bio.tagline = panesList[i].tagline;
				bio.image = new Sprite();
				bio.imageurl = panesList[i].imageurl;
				bio.blogurl = panesList[i].blogurl;
				bio.feedurl = panesList[i].feedurl;
				bio.showFeed = Boolean(stringToBool(panesList[i].showFeed));
				bios.push(bio);
			}
			
			// Create the preloader
			preloader = new Preloader(settings.titleColor, settings.yearColor);
			content.addChild(preloader);
			preloader.x = (content.width * .5) - (preloader.width * .5);
			preloader.y = (content.height * .5) - (preloader.height * .55);
			preloader.startLoad();
			
			// Now we need to load in the profile images and feeds
			loadBioImages(0);
			loadBlogFeeds(0);
		}
		
		private function onMainLoadError(e:Event):void {
			preloader.setError('Failed to load the settings XML file. Please try again');
		}
		
		private function loadBioImages(numLoaded:Number):void {
			
			if (numLoaded < settings.numPanes) {				
				
				// Create a loader
				var loader:Loader = new Loader()
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE , onLoad);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
				
				var req:URLRequest = new URLRequest(bios[numLoaded].imageurl);
				loader.load(req);
				
				function onProgress(e:ProgressEvent):void
				{
					// Update total progress
					updateLoadProgress(e.bytesLoaded / e.bytesTotal, numLoaded);
				}
				
				function onLoad(e:Event):void
				{
					bios[numLoaded].image.addChild(e.target.content);
					loadBioImages(numLoaded + 1);
					
					// Cleanup
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE , onLoad);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
					loader = null;
					req = null;
				}
				
				function onError(e:Event):void {
					/**
					 * 	The image failed to load, this catches the error
					 * 	and allows us to keep going.
					 */
					loadBioImages(numLoaded + 1);
					
					// Cleanup
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE , onLoad);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
					loader = null;
					req = null;
				}
				
			}else {
				// All bio images are loaded
				updateLoadProgress(1, settings.numPanes - 1);
				checkDoneLoading();
			}
		}
		
		private function loadBlogFeeds(numFeedsLoaded:Number):void {
			
			// This is a recursive function, check if we're done
			if (numFeedsLoaded < settings.numPanes) {				
				
				// Determine if the feed should be displayed
				if (bios[numFeedsLoaded].showFeed) {
					
					// Create an XML Loader
					var blogXMLLoader:XMLLoader = new XMLLoader(bios[numFeedsLoaded].feedurl);
					blogXMLLoader.addEventListener(Event.COMPLETE, onXMLLoad);
					blogXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, onXMLError);
					blogXMLLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onXMLError);
					
					function onXMLLoad(e:Event):void
					{	
						// Cleanup event listeners
						blogXMLLoader.removeEventListener(Event.COMPLETE, onXMLLoad);
						blogXMLLoader.removeEventListener(IOErrorEvent.IO_ERROR, onXMLError);
						blogXMLLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onXMLError);
						
						// Grab the XML and parse it
						var xml:XML = blogXMLLoader.getXML();
						
						// Make sure XML is valid
						if(xml != null) {  
							var entries:XMLList = xml.channel.item;
							if (entries.length() > 0) {
								trace(entries);
								bios[numFeedsLoaded].postTitle = "Latest from " + bios[numFeedsLoaded].name;
								bios[numFeedsLoaded].postDesc = entries[0].description;
							} else {
								// The feed was empty
								bios[numFeedsLoaded].showFeed = false;
							}
						} else {
							// There was an error loading the feed, and it slipped through the cracks
							bios[numFeedsLoaded].showFeed = false;
						}
						
						// Keep going
						loadBlogFeeds(numFeedsLoaded + 1);
					}
					
					function onXMLError(e:Event):void {
						
						// Cleanup event listeners
						blogXMLLoader.removeEventListener(Event.COMPLETE, onXMLLoad);
						blogXMLLoader.removeEventListener(IOErrorEvent.IO_ERROR, onXMLError);
						blogXMLLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onXMLError);
						
						//trace('FAILED to load xml for ' + bios[numFeedsLoaded].name);
						
						// XML failed to load, set this bio's showFeed to FALSE, and keep going
						bios[numFeedsLoaded].showFeed = false;
						loadBlogFeeds(numFeedsLoaded + 1);
					}
					
				} else {
					// This bio's feed is disabled, keep going
					// trace('NOT loading the feed for ' + bios[numFeedsLoaded].name);
					loadBlogFeeds(numFeedsLoaded + 1);
				}
				
			}else {
				// All bio feeds are loaded
				// trace('all feeds loaded');
				checkDoneLoading();
			}
		}
		
		private function checkDoneLoading():void {
			/**
			 * 	This is just a dummy function that prevents the
			 * 	app from starting until a certain condition is met.
			 * 	This isn't the best way, but it's fast, and we're in
			 * 	a rush.
			 * 
			 * 	Each time this function is called, it simply checks if
			 * 	the number of tasks loaded = total number of tasks. These
			 * 	variables should be stored globally.
			 * 
			 * 	Sorry this is so sketchy.
			 */
			
			numTasksLoaded++;
			if (numTasksLoaded >= numTasksTotal) {
				setupStage();
			}
		}
		
		private function handlePaneChange(event:MouseEvent):void {
			var ind:int = event.currentTarget.index;

			// Disable mouse interaction
			disablePaneClick();
			
			// Fade out content area
			content.visible = false;
			content.alpha = 0;
			
			// Move the panes
			var newPaneInd:int = makePaneActive(ind);
			
			// Set the content area
			setContentArea(newPaneInd);
		}
		
		private function setContentArea(index:int):void {
			if (index == -1) {
				contentArea.visible = false;
				preloader.visible = true;
				contentArea.alpha = 0;
				preloader.alpha = 1;
			} else {
				contentArea.visible = true;
				preloader.visible = false;
				preloader.alpha = 0;
				contentArea.alpha = 1;
				contentArea.setContent(bios[index]);
				contentArea.x = (content.width * .5) - (contentArea.width * .5);
				contentArea.y = (stage.stageHeight * .5) - (contentArea.height * .5);
			}
			content.visible = true;
			TweenLite.to(content, tweenFadeTime*3, { alpha:1, delay: tweenSlideTime} );
		}
		
		private function makePaneActive(ind:int):int {
			
			if (currentPane !== -1) {
				panes[currentPane].setActive(false);
			}
			
			if (currentPane == -1) {
				for (var k:int = settings.numPanes -1 ; k >= ind ; --k) {
					TweenLite.to(panes[k], tweenSlideTime, { x:panes[k].endX, onComplete:enablePaneClick } );
				}
				currentPane = ind;
			} else {
				if (currentPane == ind) {
					for (var n:int = settings.numPanes - 1; n >= 0; n--) {
						TweenLite.to(panes[n], tweenSlideTime, { x: panes[n].startX, onComplete:enablePaneClick } );
					}
					currentPane = -1;
				}
				else if (ind > currentPane) {
					for (var l:int = ind - 1; l >= currentPane; --l) {
						TweenLite.to(panes[l], tweenSlideTime, { x:panes[l].startX, onComplete:enablePaneClick } );
					}
					currentPane = ind;
				}
				else if (ind == 0) {
					for (var o:int = currentPane - 1; o >= 0; o--) {
						TweenLite.to(panes[o], tweenSlideTime, { x:panes[o].endX, onComplete:enablePaneClick } );
					}
					currentPane = 0
				}
				else {
					for (var m:int = currentPane - 1; m >= ind; m--) {
						TweenLite.to(panes[m], tweenSlideTime, { x:panes[m].endX, onComplete:enablePaneClick } );
					}
					currentPane = ind;
				}
			}
			
			if (currentPane !== -1) {
				panes[ind].setActive(true);
				content.x = stage.stageWidth - (content.width + ((settings.numPanes - currentPane) * settings.paneWidth));
			} else {
				content.x = stage.stageWidth - content.width;
			}
			
			return currentPane;
		}
		
		private function disablePaneClick():void {
			// Disable mouse interaction
			for (var j:int = 0; j < panes.length; ++j) {
				panes[j].removeEventListener(MouseEvent.CLICK, handlePaneChange)
				panes[j].hidePointer();
			}
		}
		
		private function enablePaneClick(e:Event = null):void {
			// Re-enable mouse interaction
			for (var j:int = 0; j < panes.length; ++j) {
				panes[j].addEventListener(MouseEvent.CLICK, handlePaneChange)
				panes[j].showPointer();
			}
		}
		
		private function updateLoadProgress(perc:Number, numLoaded:Number):void {
			preloader.updateProgress((numLoaded / settings.numPanes) + (perc * (1 / settings.numPanes)));
		}
		
		private function stringToBool(str:String):Boolean {
			
			var val:Boolean;
			if ((str == 'yes') || (str == 'Yes') || (str == 'YES') || (str == 'true') || (str == 'True') || (str == 'TRUE')) {
				val = true;
			} else if ((str == 'no') || (str == 'No') || (str == 'NO') || (str == 'false') || (str == 'False') || (str == 'FALSE')) {
				val = false;
			}
			return val;
		}
		
		private function hexStringToUint(str:String):uint {
			var pattern:RegExp = /#/;
			var color:uint;
			color = uint(str.toString().replace(pattern, '0x'));
			return color;
		}
		
		private function loop(e:Event):void {
			trace("Content: " + content.alpha + " Preloader: " + preloader.alpha + " Content Area: " + contentArea.alpha);
		}
	}
	
}