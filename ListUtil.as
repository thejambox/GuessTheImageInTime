package {
	public class ListUtil {
		
		public static function isList(object:*):Boolean {
			if ((object is Array) || (object is Vector.<*> ) && (object.length > 0)) {
				return true;
			}
			return false;
		}
		
		public static function getRandomItem(list:*):* {
			if (isList(list)) {
				return list[HMSMath.random(list.length)];
			}
			return null;
		}
		
		public static function getRandomIndex(list:*):int {
			if (isList(list)) {
				return HMSMath.random(list.length);
			}
			return -1;
		}
		
		public static function indexIsWithinBounds(list:*, index:int):Boolean {
			if (isList(list)) {
				if (index < 0) return false;
				return (index < list.length);
			}
			return false;
		}
		
		public static function getNextItem(list:*, item:*, wrapAround:Boolean = true):* {
			return getNextOrPrevItem(list, item, true, wrapAround);
		}
		public static function getPrevItem(list:*, item:*, wrapAround:Boolean = true):* {
			return getNextOrPrevItem(list, item, false, wrapAround);
		}
		
		private static function getNextOrPrevItem(list:*, item:*, next:Boolean, wrapAround:Boolean):* {
			if (isList(list)) {
				var index:int = list.lastIndexOf(item);
				if (index < 0) return null;
				index += (next) ? 1 : -1;
				if (index < 0) {
					if (wrapAround) index = list.length - 1;
					else return null;
				} else if (index >= list.length) {
					if (wrapAround) index = 0;
					else return null;
				}
				return list[index];
			}
			return null;
		}
		
	}

}