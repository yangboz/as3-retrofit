package eu.powdermonkey.composure
{
	public class Product
	{
		private var _name:String
		public function get name():String { return _name }
		
		public function Product(name:String)
		{
			_name = name
		}
	}
}