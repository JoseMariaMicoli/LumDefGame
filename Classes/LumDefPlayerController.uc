class LumDefPlayerController extends UDKPlayerController;

var Vector2D    PlayerMouse;                //Hold calculated mouse position (this is calculated in HUD)

var Actor TraceActor;       //this is the name of the object under the mouse cursor... if there is one.

//mouse locations and normalised vectors
var Vector  MouseHitWorldLocation;
var Vector  MouseHitWorldNormal;

var Vector  MousePositionWorldLocation;
var Vector  MousePositionWorldNormal;

//where our pawn was looking last
var Vector  LastLookLocation;

var vector PawnEyeLocation;

//ray tracing
var Vector rayDir;

var Vector StartTrace;
var Vector EndTrace;

var float DistanceRemaining;
var bool bPawnNearDestination;

//======================================================
// Mouse clicking variables

var bool bLeftMousePressed; //leftmouse button 
var bool bRightMousePressed; //rightmouse button

var float totalDeltaTime;

var float ClickSensitivity;

event PlayerTick(float DeltaTime)
{
        Super.PlayerTick(DeltaTime);
        
        if(bRightMousePressed)
	{
		totalDeltaTime += deltaTime;

		SetDestinationPosition(MouseHitWorldLocation);

		if(totalDeltaTime >= ClickSensitivity)
		{
			//hold mouse click function
			if(!IsInState('MoveMousePressedAndHold'))
                        {
                                `Log("Pushed MoveMousePressedAndHold state");
                                PushState('MoveMousePressedAndHold');
                        }
                        else
                        {
                                //Specify execution of current state, starting from label Begin:, ignoring all events and
                                //keeping our current pushed state MoveMousePressedAndHold. To better understand why this
                                //continually execute each frame from our Begin: label, see
                                //http://udn.epicgames.com/Three/MasteringUnrealScriptStates.html,
                                //11.3 - BASIC STATE TRANSITIONS
                                GotoState('MoveMousePressedAndHold', 'Begin', false, true);
                        }
		}
	}
	
	if(!isinstate('MoveMouseClick'))
	{
		Pawn.SetRotation(Rotator(LastLookLocation));
	}
}

exec function StartFire(optional byte FireModeNum)
{

	if(isinstate('MoveMouseClick'))
	{
		PopState(true); //removes all states
	}

	totalDeltaTime = 0; //clear delta timer
	SetDestinationPosition(MouseHitWorldLocation); //sets initial destination of location

	//begin our  target, this lets us know we are starting again
	bPawnNearDestination = false;

	// Initialise for the mouse over time funtionality
	bLeftMousePressed = FireModeNum == 0;
	bRightMousePressed = FireModeNum == 1;

	//for debug purposes - maybe call another function from here?
	if(bLeftMousePressed) `Log("Left Mouse Pressed");
	if(bRightMousePressed) `Log("Right Mouse Pressed");
}

//for long presses
simulated function Stopfire(optional byte FiremodeNum )
{
	if(bLeftMousePressed && FiremodeNum == 0)
	{
		bLeftMousePressed = false;
		`log("left mouse released");
	}
	if(bRightMousePressed && FiremodeNum == 1)
	{
		bRightMousePressed = false;
	}

	if(!bPawnNearDestination && totalDeltaTime < ClickSensitivity)
	{
		if(fastTrace(MouseHitWorldLocation, PawnEyeLocation,, true))
			{
				MovePawnToDestination();
			}
	}
	else
	{
	//	PopState();
	}

	if(bPawnNearDestination){PopState();}

	totalDeltaTime = 0;
}


function MovePawnToDestination()
{
	SetDestinationPosition(MouseHitWorldLocation);
	PushState('MoveMouseClick');
}


//BEGIN STATE BASED MOVEMENT HERE
state MoveMouseClick
{
	event PoppedState()
	{
		if(IsTimerActive(nameof(StopLingering)))
		{
			ClearTimer(nameof(StopLingering));
		}
	}

	event PushedState()
	{
		SetTimer(3, false, nameof(StopLingering));
		if (Pawn != none)
		{
			Pawn.SetMovementPhysics();
		}
	}


Begin:
	while(!bpawnNearDestination)
	{
		MoveTo(GetdestinationPosition());
	}
	PopState();

}

state MoveMousePressedAndHold
{
Begin:
        while(!bPawnNearDestination)
        {
                `Log("MoveMousePressedAndHold at pos"@GetDestinationPosition());
                MoveTo(GetDestinationPosition());

				
		}
        
                PopState();
}

function StopLingering()
{

	`Log("Stopped Lingering");
	PopState(true);
}

//handle the move function
function PlayerMove(float deltatime)
{
	local Vector PawnXYLocation; //where our pawn is
	local Vector DestinationXYLocation; //where it is going to be
	local Vector Destination;
	local Vector2D DistanceCheck; //see how far it is away

	super.PlayerMove(deltatime);

	Destination = GetDestinationPosition();
	DistanceCheck.X = Destination.X - Pawn.Location.X;
	DistanceCheck.Y = Destination.Y - Pawn.Location.Y;

	//calculate the remaining distance using pythagorean theorum :D
	DistanceRemaining = Sqrt((DistanceCheck.X*DistanceCheck.X) + (DistanceCheck.Y*DistanceCheck.Y));

	//are we close?
	bPawnNearDestination = DistanceRemaining < 50.0f;

	//update our location locally with our pawns location
	PawnXYLocation.X = Pawn.Location.X;
	PawnXYLocation.Y = Pawn.Location.Y;

	DestinationXYLocation.X = GetDestinationPosition().X;
	DestinationXYLocation.Y = GetDestinationPosition().Y;
	
	//face the right direction
	LastLookLocation = DestinationXYLocation - PawnXYLocation;
	Pawn.SetRotation(Rotator(DestinationXYLocation - PawnXYLocation));
}


/*Sobrescrevo a funcao UpdateRotation da classe mae apenas para
 deixar a rotacao da camera estatica enquanto se move o mouse*/
function UpdateRotation(float DeltaTime);

//overwrite camera adjust from key presses
function ProcessViewRotation(float DeltaTime, out rotator out_ViewRotation, rotator DeltaRot){//
}

DefaultProperties
{
        CameraClass=class'LumDefGame.LumDefCamera'
        //Definimous nossa propria classe PlayerInput
        InputClass=class'LumDefGame.LumDefPlayerInput'
        
        ClickSensitivity = 0.20f
}