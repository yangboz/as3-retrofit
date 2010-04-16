package eu.powdermonkey.composure
{
	import org.osflash.signals.Signal;
	
	public class PreperationSignals
	{
		public const error:Signal = new Signal(String)
		public const completed:Signal = new Signal()
	}
}