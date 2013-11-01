class SeqAct_GiveXP extends SequenceAction;

var() int Amount; // Amount of XP this action will give

DefaultProperties
{
	// Name that will apear in the Kismet Editor
	ObjName="Add XP"
 
	// Name of the function that will be called when this action is triggered
	HandlerName="AddXP"
 
	Amount = 0
 
	// Expose the Amount property in Kismet
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int', LinkDesc="Amount", bWriteable=true, PropertyName=Amount)
}