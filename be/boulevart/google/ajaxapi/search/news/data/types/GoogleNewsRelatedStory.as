package be.boulevart.google.ajaxapi.search.news.data.types {	/**	 * @author joris	 */	public class GoogleNewsRelatedStory {		private var __unescapedUrl : String;		private var __url : String;		private var __visibleUrl : String;		private var __title : String;		private var __titleNoFormatting : String;		private var __publisher : String;		private var __location : String;		private var __published : String;		public  function get unescapedUrl() : String {			return __unescapedUrl;		}		public function set unescapedUrl(_unescapedUrl : String) : void {			__unescapedUrl = _unescapedUrl;		}		public function get url() : String {			return __url;		}		public function set url(_url : String) : void {			__url = _url;		}		public function get visibleUrl() : String {			return __visibleUrl;		}		public function set visibleUrl(_visibleUrl : String) : void {			__visibleUrl = _visibleUrl;		}		public function get title() : String {			return __title;		}		public function set title(_title : String) : void {			__title = _title;		}		public function get titleNoFormatting() : String {			return __titleNoFormatting;		}		public function set titleNoFormatting(_titleNoFormatting : String) : void {			__titleNoFormatting = _titleNoFormatting;		}		public function get publisher() : String {			return __publisher;		}		public function set publisher(_publisher : String) : void {			__publisher = _publisher;		}		public function get location() : String {			return __location;		}		public function set location(_location : String) : void {			__location = _location;		}		public function get published() : String {			return __published;		}		public function set published(_published : String) : void {			__published = _published;		}	}}