package eu.powdermonkey.collections
{
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public class KeyedSet extends Proxy implements Iterator
	{
		private var _keyName:String
		
		private var elements:Dictionary = new Dictionary()
		
		private var array:Array = []
		
		private var isDirty:Boolean = false
		
		public function KeyedSet(keyName:String=null, elements:Array=null)
		{
			_keyName = keyName
			
			if (elements)
			{
				for each (var elem:* in new ArrayIterator(elements))
				{
					add(elem)
					array.push(elem)
				}
			}
		}
		
		public function add(elem:*):void
		{
			if (_keyName)
			{
				elements[elem[_keyName]] = elem
			}
			else
			{
				elements[elem] = elem
			}
			
			isDirty = true
		}
		
		public function remove(key:*):*
		{
			var removed:* = elements[key]
			delete elements[key]
			isDirty = true
			return removed
		}
		
		private function updateArray():void
		{
			if(isDirty)
			{
				array = DictionaryUtil.toArray(elements)
			}
		}
		
		public function get length():uint
		{
			updateArray()
			return array.length
		}
		
//		override flash_proxy  function callProperty(name:*, ...  rest):*
//		{
//			return '[Moo]'
//		}
		
		override flash_proxy function getProperty(name:*):*
		{
			updateArray()
			return array[name]
		}
		
		override flash_proxy function nextNameIndex(index:int):int
		{
			updateArray()
			if (index < array.length) 
			{
				return index + 1
			}
			else
			{
				return 0
			}
		}		
		
		override flash_proxy function nextValue(index:int):*
		{
			updateArray()
			return array[index - 1]		
		}
		
		public function toString():String
		{
			updateArray()
			return array[0]
		}
	}
}