package eu.powdermonkey
{
	import eu.powdermonkey.collections.KeyedSet;
	
	import org.osflash.signals.ISignal;
	
	public interface ItemContainer
	{
	    function get itemAdded():ISignal
	    function get itemRemoved():ISignal
	    function addItem(item:Item):void
	    function removeItem(item:Item):void
	    function get items():KeyedSet
	}
}