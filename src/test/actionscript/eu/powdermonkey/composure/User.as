package eu.powdermonkey.composure
{
	public class User
	{
		public function User()
		{
		}
		
		private var _name:String = 'moomoo'
		
		public function get name():String
		{
			return _name
		}
		
		public function address():String
		{
			return 'place you live'
		} 
	}
}