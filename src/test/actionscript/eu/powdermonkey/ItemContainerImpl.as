package eu.powdermonkey
{
	import eu.powdermonkey.collections.KeyedSet;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	public class ItemContainerImpl implements ItemContainer
	{
		private var _items:KeyedSet = new KeyedSet()
		public function get items():KeyedSet { return _items }
		
		private var _itemAdded:Signal = new Signal(Item)
		public function get itemAdded():ISignal { return _itemAdded }
		
		private var _itemRemoved:Signal = new Signal(Item)
	    public function get itemRemoved():ISignal { return _itemRemoved }
	    
	    public function addItem(item:Item):void {
	    	_items.add(item)
	    	_itemAdded.dispatch(item)
	    }
	    
	    public function removeItem(item:Item):void 
	    {
	    	_items.remove(item)
	    	_itemRemoved.dispatch(item)
	    }
	}
}