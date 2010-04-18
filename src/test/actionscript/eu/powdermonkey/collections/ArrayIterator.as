package eu.powdermonkey.collections
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public class ArrayIterator extends Proxy implements Iterator
	{
		private var array:Array
		
		private var index:uint = 0
		
		public function ArrayIterator(array:Array)
		{
			this.array = array
		}
		
		public function get hasNext():Boolean
		{
			return index < length
		}
		
		public function next():*
		{
			var nextElement:* = array[index]
			index++
			return nextElement
		}
		
		public function get length():uint
		{
			return array.length
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			return array[name]
		}
		
		override flash_proxy function nextNameIndex(index:int):int
		{
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
			return array[index - 1]		
		}
	}
}