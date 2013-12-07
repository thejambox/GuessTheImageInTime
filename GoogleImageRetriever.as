package {
	import be.boulevart.google.ajaxapi.search.GoogleSearchResult;
	import be.boulevart.google.ajaxapi.search.images.data.GoogleImage;
	import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageFiletype;
	import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageSafeMode;
	import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageSize;
	import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageType;
	import be.boulevart.google.ajaxapi.search.images.GoogleImageSearch;
	import be.boulevart.google.events.GoogleAPIErrorEvent;
	import be.boulevart.google.events.GoogleApiEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	public class GoogleImageRetriever extends EventDispatcher {
		
		public var busy:Boolean;
		
		public var image:Bitmap;
		public var url:String;
		public var finalUrl:String;
		public var query:String;
		public var start:uint;
		public var restrictedDomain:Boolean;
		
		public var resultNumber:uint;
		
		public var useProxy:Boolean;
		public var proxyURLPrepend:String;
		public var proxyURLAppend:String;
		
		public var skiplist:Vector.<String>;
		
		public var safeMode:String;
		public var size:String;
		public var imageType:String;
		public var filetype:String;
		public var colorization:String;
		public var imageColor:String;
		
		public var searchTimeout:uint;
		public var loadTimeout:uint;
		
		public var searchFailures:uint;
		public var loadFailures:uint;
		public var searchTimeouts:uint;
		public var loadTimeouts:uint;
		
		private var _searchResults:GoogleSearchResult;
		private var _trackedObjects:Dictionary;
		
		internal var i:int, j:int, rand:int, lc:LoaderContext;
		
		
		public function GoogleImageRetriever(skiplist:Vector.<String> = null) {
			this.skiplist = skiplist;
			
			useProxy = false;
			proxyURLPrepend = "";
			proxyURLAppend = "";
			
			searchFailures = 0;
			loadFailures = 0;
			searchTimeouts = 0;
			loadTimeouts = 0;
			searchTimeout = 10;
			loadTimeout = 20;
			
			safeMode = "";
			size = "";
			imageType = "";
			filetype = "";
			colorization = "";
			imageColor = "";
			busy = false;
			_trackedObjects = new Dictionary;
			
			lc = new LoaderContext(true);
		}
		
		public function setProxy(enable:Boolean, urlPrepend:String = null, urlAppend:String = null):void {
			useProxy = enable;
			if (urlPrepend) proxyURLPrepend = urlPrepend;
			if (urlAppend) proxyURLAppend = urlAppend;
		}
		
		////////////////////////////////////////
		
		public function search(theQuery:String, theStart:uint = 0):void {
			abort();
			query = theQuery;
			if (theStart > 50) this.start = 50;
			else this.start = theStart;
			var googleSearch:GoogleImageSearch = new GoogleImageSearch;
			googleSearch.search(query, start, safeMode, size, colorization, imageColor, imageType, filetype);
			track(googleSearch);
			
			searchFailures = 0;
			loadFailures = 0;
			searchTimeouts = 0;
			loadTimeouts = 0;
		}
		
		public function retrySearch():Boolean {
			if (query) {
				search(query, start);
				return true;
			}
			return false;
		}
		
		public function retryLoad():Boolean {
			if (url) {
				abort();
				load();
				return true;
			}
			return false;
		}
		
		public function loadNextResult():void {
			loadResult(resultNumber + 1);
		}
		
		public function abort():void {
			busy = false;
			for each (var o:* in _trackedObjects) {
				untrack(o);
			}
			//resultNumber = 0;
		}
		
		////////////////////////////////////////
		
		private function onSearchResults(e:GoogleApiEvent):void {
			searchFailures = 0;
			searchTimeouts = 0;
			untrack(e.target);
			_searchResults = e.data as GoogleSearchResult;
			loadResult(0);
		}
		
		private function loadResult(num:uint):void {
			if (_searchResults.results.length < num) {
				dispatchEvent(new GoogleImageRetrieverEvent(GoogleImageRetrieverEvent.NO_RESULTS));
				return;
			}
			
			url = "";
			finalUrl = "";
			restrictedDomain = false;
			var validURL:Boolean = false;
			for (i = num; i < _searchResults.results.length; i++) {
				resultNumber = i;
				url = _searchResults.results[num].url;
				if (isValidURL()) {
					validURL = true;
					break;
				}
			}
			
			if (!validURL) {
				dispatchEvent(new GoogleImageRetrieverEvent(GoogleImageRetrieverEvent.ALL_RESULTS_SKIPPED));
				url = "";
				return
			} else if (url.length <= 0) {
				dispatchEvent(new GoogleImageRetrieverEvent(GoogleImageRetrieverEvent.NO_RESULTS));
				return;
			}
			
			load();
		}
		
		private function load():void {
			if (url) {
				var finalURL:String;
				if (useProxy) finalURL = proxyURLPrepend + escape(url) + proxyURLAppend;
				else finalURL = url;
				var loader:Loader = new Loader;
				var request:URLRequest = new URLRequest(finalURL);
				track(loader);
				loader.load(request, lc);
			}
		}
		
		private function onLoaded(e:Event):void {
			restrictedDomain = (!LoaderInfo(e.target).childAllowsParent);
			finalUrl = LoaderInfo(e.target).url;
			untrack(e.target.loader);
			
			loadFailures++;
			
			if (restrictedDomain) {
				dispatchEvent(new GoogleImageRetrieverEvent(GoogleImageRetrieverEvent.LOAD_FAILURE));
				return;
			}
			
			loadFailures = 0;
			loadTimeouts = 0;
			
			image = e.target.content;
			
			dispatchEvent(new GoogleImageRetrieverEvent(GoogleImageRetrieverEvent.RETRIEVED));
		}
		
		////////////////////////////////////////
		// ERRORS
		
		private function onSearchError(e:Event):void {
			searchFailures++;
			untrack(e.target);
			dispatchEvent(new GoogleImageRetrieverEvent(GoogleImageRetrieverEvent.SEARCH_FAILURE));
		}
		
		private function onHttpStatus(e:HTTPStatusEvent):void {
			//
		}
		
		private function onLoadError(e:Event):void {
			loadFailures++;
			untrack(e.target.loader);
			dispatchEvent(new GoogleImageRetrieverEvent(GoogleImageRetrieverEvent.LOAD_FAILURE));
		}
		
		private function trackingTimeout(e:TimerEvent):void {
			if (_trackedObjects[e.target] is GoogleImageSearch) {
				searchTimeouts++;
				dispatchEvent(new GoogleImageRetrieverEvent(GoogleImageRetrieverEvent.SEARCH_TIMEOUT));
			} else {
				loadTimeouts++;
				dispatchEvent(new GoogleImageRetrieverEvent(GoogleImageRetrieverEvent.LOAD_TIMEOUT));
			}
			untrack(_trackedObjects[e.target]);
		}
		
		////////////////////////////////////////
		// OTHERS
		
		private function isValidURL():Boolean {
			var badUrl:Boolean = false, item:String;
			for each (item in skiplist) {
				if (url.indexOf(item) != -1) {
					badUrl = true;
					break;
				}
			}
			if (!badUrl && (url.length > 0)) return true;
			return false;
		}
		
		private function track(object:*):void {
			busy = true;
			var timeout:uint;
			if (object is GoogleImageSearch) {
				object.addEventListener(GoogleApiEvent.IMAGE_SEARCH_RESULT, onSearchResults);
				object.addEventListener(GoogleApiEvent.ON_ERROR, onSearchError);
				object.addEventListener(GoogleAPIErrorEvent.API_ERROR, onSearchError);
				timeout = searchTimeout * 1000;
			} else if (object is Loader) {
				object.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
				object.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				object.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
				timeout = loadTimeout * 1000;
			}
			var timer:Timer = new Timer(timeout, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, trackingTimeout);
			_trackedObjects[timer] = object;
			timer.start();
		}
		
		private function untrack(object:*):void {
			busy = false;
			for (var t:* in _trackedObjects) {
				if (_trackedObjects[t] == object) {
					t.stop();
					t.removeEventListener(TimerEvent.TIMER_COMPLETE, trackingTimeout);
					delete _trackedObjects[t];
					break;
				}
			}
			
			if (object is GoogleImageSearch) {
				object.removeEventListener(GoogleApiEvent.IMAGE_SEARCH_RESULT, onSearchResults);
				object.removeEventListener(GoogleApiEvent.ON_ERROR, onSearchError);
				object.removeEventListener(GoogleAPIErrorEvent.API_ERROR, onSearchError);
			} else if (object is Loader) {
				object.removeEventListener(Event.COMPLETE, onLoaded);
				object.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				object.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			}
		}
		
		
	}
	
}