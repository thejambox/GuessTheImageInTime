package {
	import flash.events.Event;
	
	public class GoogleImageRetrieverEvent extends Event {
		
		public static const RETRIEVED:String = "retrieved";
		public static const SEARCH_FAILURE:String = "searchFailure";
		public static const LOAD_FAILURE:String = "loadFailure";
		public static const SEARCH_TIMEOUT:String = "searchTimeout";
		public static const LOAD_TIMEOUT:String = "loadTimeout";
		public static const ALL_RESULTS_SKIPPED:String = "allResultsSkipped";
		public static const NO_RESULTS:String = "noResults";
		
		public function GoogleImageRetrieverEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
	}
	
}