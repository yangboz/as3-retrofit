package eu.powdermonkey.composure
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	public class PreperationSignals
	{
		public const error:Signal = new Signal(String)
		
		public const completed:Signal = new Signal()
		
		private var _classes:Array
		
		public function PreperationSignals(classes:Array)
		{
			_classes = classes
		}
	}
}