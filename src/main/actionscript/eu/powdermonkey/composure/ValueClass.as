package eu.powdermonkey.composure
{
	import org.flemit.reflection.Type;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.bytecode.DynamicClass;

	public class ValueClass extends DynamicClass
	{
		public function ValueClass(qname:QualifiedName, baseClass:Type, interfaces:Array)
		{
			super(qname, baseClass, interfaces);
		}
	}
}