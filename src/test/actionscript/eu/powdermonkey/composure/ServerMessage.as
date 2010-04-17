package eu.powdermonkey.composure
{
	public interface ServerMessage
	{
		function get id():int
		function get data():String
		function get timestamp():int
	}
}